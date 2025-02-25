USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL077_EnterpriseMDMLoader]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL077_EnterpriseMDMLoader]
    @DateRange varchar(30) = 'Yesterday-to-now',
    @StartDate date = null,
    @EndDate date = null,
    @ReloadCustomerID varchar(max) = null,
    @LoadMissingPolicy bit = 0,
    @LoadMissingClaim bit = 0,
    @Domain varchar(max) = 'AU'

as
begin


    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

	begin try
	
		exec syssp_getrunningbatch
			@SubjectArea = 'Enterprise MDM Loader',
			@BatchID = @batchid out,
			@StartDate = @start out,
			@EndDate = @end out
			
	end try
	
	begin catch
		
		set @batchid = -1
	
	end catch

    if @batchid = -1 
    begin

        if @DateRange <> '_User Defined'
            select
                @start = StartDate,
                @end = EndDate
            from
                [db-au-cmdwh]..vDateRange
            where
                DateRange = @DateRange

        else
            select
                @start = @StartDate,
                @end = @EndDate

    end

    select
        @name = object_name(@@procid)
	
    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'


    if @ReloadCustomerID = '0'
    begin

        --reset concolidation
        update [db_au_mdmenterprise]..C_PARTY
        set CONSOLIDATION_IND = 4
        where
            ROWID_OBJECT in
            (
                select 
                    CustomerID 
                from
                    [db-au-stage]..mdm_reload
            )

        update [db_au_mdmenterprise]..C_PARTY_ADDRESS
        set CONSOLIDATION_IND = 4
        where
            PRTY_FK in
            (
                select 
                    CustomerID 
                from
                    [db-au-stage]..mdm_reload
            )

        update [db_au_mdmenterprise]..C_PRTY_IND_DTL
        set CONSOLIDATION_IND = 4
        where
            PRTY_FK in
            (
                select 
                    CustomerID 
                from
                    [db-au-stage]..mdm_reload
            )

        update [db_au_mdmenterprise]..C_PARTY_PHONE
        set CONSOLIDATION_IND = 4
        where
            PRTY_FK in
            (
                select 
                    CustomerID 
                from
                    [db-au-stage]..mdm_reload
            )

        update [db_au_mdmenterprise]..C_PARTY_EMAIL
        set CONSOLIDATION_IND = 4
        where
            PRTY_FK in
            (
                select 
                    CustomerID 
                from
                    [db-au-stage]..mdm_reload
            )

    end


    if object_id('tempdb..#reload') is not null
        drop table #reload

    select distinct
        p.PolicyKey,
        p.ClaimKey
    into #reload
    from
        [db-au-cmdwh]..entPolicy p with(nolock)
    where
        @ReloadCustomerID <> '0' and
        p.CustomerID in
        (
            select
                Item
            from
                dbo.fn_DelimitedSplit8K(@ReloadCustomerID, ',')
        )

    insert into #reload (PolicyKey)
    select distinct
        PolicyKey
    from
        [db-au-cmdwh]..entPolicy ep
    where
        @ReloadCustomerID = '0' and
        ep.CustomerID in
        (
            select
                CustomerID
            from
                [db-au-stage]..mdm_reload
        )

    insert into #reload (Claimkey)
    select distinct
        ClaimKey
    from
        [db-au-cmdwh]..entPolicy ep
    where
        @ReloadCustomerID = '0' and

        ep.CustomerID in
        (
            select
                CustomerID
            from
                [db-au-stage]..mdm_reload
        )

    insert into #reload (PolicyKey)
    select
        pt.PolicyKey
    from
        [db-au-cmdwh]..penPolicyTransaction pt with(nolock)
        inner join [db-au-cmdwh]..penPolicy p with(nolock) on
            p.PolicyKey = pt.PolicyKey
    where
        @LoadMissingPolicy = 0 and
        p.ProductName not like '%Base' and
        isnull(@ReloadCustomerID, '0') = '0' and
        pt.CountryKey in ('AU', 'NZ') and
        pt.TransactionType in ('Base', 'Edit Traveller Detail') and
        pt.TransactionDateTime >= @start and
        pt.TransactionDateTime <  dateadd(day, 1, @end)

    insert into #reload (PolicyKey)
    select top 15000
        p.PolicyKey
    from
        [db-au-cmdwh]..penPolicy p with(nolock)
        inner join [db-au-cmdwh]..penpolicytraveller ptv with(nolock) on
            ptv.PolicyKey = p.PolicyKey
    where
        @LoadMissingPolicy = 1 and
        p.ProductName not like '%Base' and
        p.CountryKey in (select Item from dbo.fn_DelimitedSplit8K(@Domain, ',')) and
        p.IssueDate >= '2012-01-01' and
        --p.IssueDate <  convert(date, getdate()) and
        --p.StatusDescription = 'Active' and

        not exists
        (
            select 
                null
            from
                [db-au-cmdwh]..entPolicy ep with(nolock)
            where
                ep.PolicyKey = p.PolicyKey
        ) and

        ptv.FirstName not in ('', 'DUMMY', 'TOP-UP', 'TOPUP', 'TEST', 'test1', 'test2', 'test3', 'Traveller') and
        ptv.FirstName not like 'test %' and
        len(ptv.FirstName) > 1 and
        ptv.Lastname not in ('', 'DUMMY', 'TOP-UP', 'TOPUP', 'TEST', 'test1', 'test2', 'test3', 'Traveller') and
        ptv.Lastname not like 'test %' and
        len(ptv.Lastname) > 1 and
        ptv.DOB is not null and
        (
            rtrim(isnull(ptv.EmailAddress, '')) <> '' or
            rtrim(isnull(ptv.MobilePhone, '')) <> ''
        )
    order by
        p.IssueDate desc


    insert into #reload (ClaimKey)
    select 
        can.ClaimKey
    from
        [db-au-cmdwh]..clmAuditName can with(nolock)
    where
        @LoadMissingClaim = 0 and
        isnull(@ReloadCustomerID, '0') = '0' and
        can.CountryKey in ('AU', 'NZ') and
        can.AuditDateTime >= @start and
        can.AuditDateTime <  dateadd(day, 1, @end)

    insert into #reload (ClaimKey)
    select top 30000
        can.ClaimKey
    from
        [db-au-cmdwh]..clmAuditName can with(nolock)
    where
        @LoadMissingClaim = 1 and
        can.CountryKey in (select Item from dbo.fn_DelimitedSplit8K(@Domain, ',')) and
        can.AuditDateTime >= '2012-01-01' and
        --can.AuditDateTime <  convert(date, getdate()) and
        not exists
        (
            select 
                null
            from
                [db-au-cmdwh]..entPolicy ep with(nolock)
            where
                ep.ClaimKey = can.ClaimKey and
                ep.Reference = can.NameKey
        )
    order by
        can.AuditDateTime desc

    truncate table [db_au_mdmenterprise]..C_L_PARTY

    ;with 
    cte_traveller as
    (
        select --top 50000
            p.IssueDate LAST_UPDATE_DATE,
            'Penguin' SRC_SYS,
            'Individual' ENTITY_TYP,
            'ENT' DIST_CD,
            'ENTERPRISE' NOTATNL_DIST,
            case
                when isPrimary = 1 then 'Policy Holder'
                else 'Traveller'
            end PRTY_TYP,
            'Residential' ADDR_TYP,
            'Personal Primary' EMAIL_TYP,
            'Work Phone' PH_TYP,
            'Valid' PRTY_STATUS,
            left(do.SuperGroupName, 15) PRTY_ROLE,
            do.GroupCode PROD_TYP,
            p.CountryKey DOMAIN_CD,
            case
                when p.CountryKey = 'AU' then 'Australia'
                when p.CountryKey = 'NZ' then 'New Zealand'
            end DOMAIN_NM,
            p.PolicyKey POLICY_KEY,
            ptv.PolicyTravellerKey PARTY_PKEY,
            null TXN_STATUS,
            ptv.Title TITLE,
            case
                when rtrim(isnull(ptv.FirstName, '')) = '' then ptv.LastName
                else isnull(ptv.FirstName, '')
            end FRST_NM,
            null MID_NM,
            ptv.LastName LST_NM,
            case
                when rtrim(isnull(ptv.FirstName, '')) = '' then ptv.LastName
                else isnull(ptv.FirstName, '')
            end + ' ' + isnull(ptv.LastName, '') PRTY_NM,
            null OTHR_NM,
            ptv.Gender GNDR,
            convert(
                varchar(23),
                case
                    when 
                        p.CountryKey in ('AU', 'NZ') and
                        do.GroupCode = 'AZ' and
                        do.Channel = 'Integrated' and 
                        --datepart(yyyy, DOB) in (1998, 1999, 2000) and 
                        datepart(m, DOB) = 1 and 
                        datepart(d, DOB) = 1 and
                        Age = 17 then null
                    when 
                        p.CountryKey = 'AU' and
                        do.GroupCode = 'FL' and
                        do.Channel = 'Integrated' and 
                        --datepart(yyyy, DOB) in (2007, 2008) and 
                        datepart(m, DOB) = 1 and 
                        datepart(d, DOB) = 1 and
                        Age in (7, 8) then null
                    when 
                        p.CountryKey = 'AU' and
                        do.GroupCode = 'HI' and
                        do.Channel = 'Integrated' and 
                        datepart(yyyy, DOB) in (1970) and 
                        datepart(m, DOB) = 1 and 
                        datepart(d, DOB) = 1 then null
                    when 
                        p.CountryKey in ('AU', 'NZ') and
                        do.GroupCode = 'VA' and
                        do.Channel = 'Integrated' and 
                        --datepart(yyyy, DOB) in (1989) and 
                        datepart(m, DOB) = 1 and 
                        datepart(d, DOB) = 1 and
                        Age in (27, 28) then null
                    else DOB
                end,
                101 --US format 
            ) + ' 00:00:00.000000' DOB,
            ptv.AGE,
            null MARITL_STS,
            cast(null as nchar(1)) IS_DCSED,
            ptv.isPrimary,
            case
                when ptv.isPrimary = 1 then ptv.EmailAddress
                when ptv.EmailAddress = pptv.PrimaryEmailAddress then null
                else ptv.EmailAddress
            end EMAIL,
            left
            (
                case
                    when ptv.isPrimary = 1 then ptv.MobilePhone
                    when ptv.MobilePhone = pptv.PrimaryMobilePhone then null
                    else ptv.MobilePhone
                end,
                20
            ) FULL_PH_VAL,
            left
            (
                case
                    when ptv.isPrimary = 1 then ptv.HomePhone
                    when ptv.HomePhone = pptv.PrimaryHomePhone then null
                    else ptv.HomePhone
                end,
                20
            ) HOME_PHONE_NO,
            left
            (
                case
                    when ptv.isPrimary = 1 then ptv.WorkPhone
                    when ptv.WorkPhone = pptv.PrimaryWorkPhone then null
                    else ptv.WorkPhone
                end,
                20
            ) WORK_PHONE_NO,
            pptv.PrimaryAddressLine1 ADDR_LINE1,
            pptv.PrimaryAddressLine2 ADDR_LINE2,
            pptv.PrimarySuburb CITY,
            left(pptv.PrimaryState, 40) PRVNCE,
            left(pptv.PrimaryPostCode, 10) POST_CD,
            case
                when pptv.PrimaryCountry = 'Lao People''s Democratic Republic' then 'Laos'
                when co.ISO3Code is null and p.CountryKey = 'AU' then 'Australia'
                when co.ISO3Code is null and p.CountryKey = 'NZ' then 'New Zealand'
                else left(pptv.PrimaryCountry, 30)
            end CNTRY,
            case
                when co.ISO3Code is null and p.CountryKey = 'AU' then 'AUS'
                when co.ISO3Code is null and p.CountryKey = 'NZ' then 'NZL'
                else co.ISO3Code
            end CNTRY_CD,
            null DLVRY_PT_DPID,
            ptv.MemberNumber,
            case
                when isnull(ptv.PIDType, '') <> '' and len(ptv.PIDType) > 20 then isnull(left(ptv.PIDCode, 20), '')
                when isnull(ptv.PIDType, '') <> '' then left(ptv.PIDType, 20)
                when ptv.EmailAddress <> pptv.PrimaryEmailAddress then ''
                when ptv.isPrimary = 0 and isnull(pptv.PrimaryEmailAddress, '') <> '' then 'Primary Email'
                else left(ptv.PIDType, 20)
            end PIDType,
            case
                when isnull(ptv.PIDType, '') <> '' then ptv.PIDValue
                when ptv.EmailAddress <> pptv.PrimaryEmailAddress then ''
                when ptv.isPrimary = 0 and isnull(pptv.PrimaryEmailAddress, '') <> '' then pptv.PrimaryEmailAddress
                else ptv.PIDValue
            end PIDValue,
            cptv.Companion
        from
            [db-au-cmdwh]..penPolicyTraveller ptv with(nolock)
            inner join [db-au-cmdwh]..penPolicy p with(nolock) on
                p.PolicyKey = ptv.PolicyKey
            inner join [db-au-star]..dimOutlet do with(nolock) on 
                do.OutletAlphaKey = p.OutletAlphaKey and 
                islatest = 'Y'
            outer apply
            (
                select top 1 
                    pptv.AddressLine1 PrimaryAddressLine1,
                    pptv.AddressLine2 PrimaryAddressLine2,
                    pptv.Suburb PrimarySuburb,
                    pptv.State PrimaryState,
                    pptv.PostCode PrimaryPostCode,
                    pptv.Country PrimaryCountry,
                    pptv.EmailAddress PrimaryEmailAddress,
                    pptv.MobilePhone PrimaryMobilePhone,
                    pptv.HomePhone PrimaryHomePhone,
                    pptv.WorkPhone PrimaryWorkPhone
                from
                    [db-au-cmdwh]..penPolicyTraveller pptv with(nolock)
                where
                    pptv.PolicyKey = p.PolicyKey and
                    pptv.isPrimary = 1
            ) pptv
            outer apply
            (
                select top 1 
                    soundex(cptv.FirstName) + isnull(replace(convert(varchar(10), ptv.DOB, 120), '-', ''), '') Companion
                from
                    [db-au-cmdwh]..penPolicyTraveller cptv with(nolock)
                where
                    cptv.PolicyKey = p.PolicyKey and
                    cptv.PolicyTravellerKey <> ptv.PolicyTravellerKey and
                    rtrim(isnull(cptv.FirstName, '')) <> ''
            ) cptv
            outer apply
            (
                select top 1 
                    ISO3Code
                from
                    [db-au-cmdwh]..penCountry co with(nolock)
                where
                    co.CountryName = pptv.PrimaryCountry
            ) co
        where
            p.CountryKey in ('AU', 'NZ') and
            --p.IssueDate >= '2016-01-01' and

            p.PolicyKey in
            (
                select
                    r.PolicyKey
                from
                    #reload r
            ) and

            --not exists
            --(
            --    select 
            --        null
            --    from
            --        [db_au_mdmenterprise]..C_PARTY_PRODUCT_TXN r
            --    where
            --        r.PROD_REF_NO = ptv.PolicyTravellerKey and
            --        r.POLICY_KEY = p.PolicyKey and
            --        r.LAST_ROWID_SYSTEM = 'PENGUIN'
            --) and        

            --rtrim(isnull(ptv.FirstName, '')) <> '' and

            len(ptv.FirstName) > 1 and
            ptv.DOB is not null and

            ptv.FirstName <> 'test' and
            ptv.FirstName <> 'testing' and
            ptv.FirstName <> 'tester' and
            ptv.FirstName <> 'testlead' and
            ptv.FirstName <> 'DP' and
            ptv.FirstName not like 'traveller%' and
            ptv.FirstName not like 'test %' and
            ptv.FirstName not like 'test[0-9,a-z]' and
            ptv.FirstName not like '% test %' and
            ptv.FirstName not like '% test' and
            ptv.FirstName not like '%dummy%' and
            ptv.FirstName not like 'TOP_UP%' and
            ptv.FirstName not like 'ADJUSTMENT%' and
            ptv.LastName <> 'test' and
            ptv.LastName <> 'POLICY' and
            ptv.LastName not like 'policy-%' and
            ptv.LastName not like 'traveller%' and
            ptv.LastName not like 'test %' and
            ptv.LastName not like '% test %' and
            ptv.LastName not like '%dummy%' and
            isnull(ptv.Addressline1, '') not like '% test %' and
            isnull(ptv.Addressline1, '') <> 'test' and
            isnull(ptv.Addressline1, '') not like 'test %' and
            isnull(ptv.Addressline1, '') not like 'dummy %'
    ),
    cte_claim as
    (
        select --top 20000
            --isnull(mat.MaxAuditDateTime, getdate()) LAST_UPDATE_DATE,
            cl.CreateDate LAST_UPDATE_DATE,

            'Claims' SRC_SYS,
            'Individual' ENTITY_TYP,
            'ENT' DIST_CD,
            'ENTERPRISE' NOTATNL_DIST,
            'Claimant' PRTY_TYP,
            'Residential' ADDR_TYP,
            'Personal Primary' EMAIL_TYP,
            'Work Phone' PH_TYP,
            'Valid' PRTY_STATUS,
            left(do.SuperGroupName, 15) PRTY_ROLE,
            do.GroupCode PROD_TYP,
            p.CountryKey DOMAIN_CD,
            case
                when p.CountryKey = 'AU' then 'Australia'
                when p.CountryKey = 'NZ' then 'New Zealand'
            end DOMAIN_NM,
            p.PolicyKey POLICY_KEY,
            cn.NameKey PARTY_PKEY,
            null TXN_STATUS,
            cn.Title TITLE,
            case
                when rtrim(isnull(cn.Firstname, '')) = '' then cn.Surname
                else isnull(cn.Firstname, '')
            end FRST_NM,
            null MID_NM,
            cn.Surname LST_NM,
            case
                when rtrim(isnull(cn.Firstname, '')) = '' then cn.Surname
                else isnull(cn.Firstname, '')
            end + ' ' + isnull(cn.Surname, '') PRTY_NM,
            null OTHR_NM,
            null GNDR,
            convert(varchar(23), cn.DOB, 101) + ' 00:00:00.000000' DOB, --US format 
            null AGE,
            null MARITL_STS,
            cast(null as nchar(1)) IS_DCSED,
            cn.isPrimary isPrimary,
            cn.Email EMAIL,
            left(cn.HomePhone, 20) FULL_PH_VAL,
            null HOME_PHONE_NO,
            left(cn.WorkPhone, 20) WORK_PHONE_NO,
            cn.AddressStreet ADDR_LINE1,
            '' ADDR_LINE2,
            cn.AddressSuburb CITY,
            left(cn.AddressState, 40) PRVNCE,
            left(cn.AddressPostCode, 10) POST_CD,
            case
                when cn.AddressCountry = 'Lao People''s Democratic Republic' then 'Laos'
                when co.ISO3Code is null and cn.CountryKey = 'AU' then 'Australia'
                when co.ISO3Code is null and cn.CountryKey = 'NZ' then 'New Zealand'
                else left(cn.AddressCountry, 30)
            end CNTRY,
            case
                when co.ISO3Code is null and p.CountryKey = 'AU' then 'AUS'
                when co.ISO3Code is null and p.CountryKey = 'NZ' then 'NZL'
                else co.ISO3Code
            end CNTRY_CD,
            null DLVRY_PT_DPID,
            case
                when left('0000000000', 10 - len(dcs.BSBs)) + dcs.BSBs + left('00000000000000000000', 20 - len(dcs.Accounts)) + dcs.Accounts = '000000000000000000000000000000' then null
                when left('00000000000000000000', 20 - len(dcs.Accounts)) + dcs.Accounts = '00000000000000000000' then null
                else left('0000000000', 10 - len(dcs.BSBs)) + dcs.BSBs + left('00000000000000000000', 20 - len(dcs.Accounts)) + dcs.Accounts
            end Account
        from
            [db-au-cmdwh]..clmClaim cl with(nolock)
            inner join [db-au-cmdwh]..clmName cn with(nolock) on
                cn.ClaimKey = cl.ClaimKey
            cross apply
            (
                select
                    isnull(rtrim(ltrim(replace(convert(varchar(max), [db-au-stage].dbo.sysfn_DecryptClaimsString(EncryptBSB)), '-', ''))), '0') BSB,
                    isnull(rtrim(ltrim(convert(varchar(max), [db-au-stage].dbo.sysfn_DecryptClaimsString(EncryptAccount)))), '0') Account
            ) dc
            cross apply
            (
                select
                    [db-au-cmdwh].dbo.fn_StrToInt(dc.BSB) BSBi,
                    [db-au-cmdwh].dbo.fn_StrToInt(dc.Account) Accounti
            ) dci
            cross apply
            (
                select
                    convert(varchar(50), dci.BSBi) BSBs,
                    convert(varchar(50), dci.Accounti) Accounts
            ) dcs
            inner join [db-au-cmdwh]..penPolicyTransaction pt with(nolock) on
                pt.PolicyTransactionKey = cl.PolicyTransactionKey
            inner join [db-au-cmdwh]..penPolicy p with(nolock) on
                p.PolicyKey = pt.PolicyKey
            inner join [db-au-star]..dimOutlet do with(nolock) on 
                do.OutletAlphaKey = p.OutletAlphaKey and 
                islatest = 'Y'
            outer apply
            (
                select top 1 
                    ISO3Code
                from
                    [db-au-cmdwh]..penCountry co with(nolock)
                where
                    co.CountryName = cn.AddressCountry
            ) co
            --outer apply
            --(
            --    select 
            --        max(can.AuditDateTime) MaxAuditDateTime
            --    from
            --        [db-au-cmdwh]..clmAuditName can with(nolock)
            --    where
            --        can.NameKey = cn.NameKey
            --) mat
        where
            cl.CountryKey in ('AU', 'NZ') and
            --cl.CreateDate >= '2016-12-01' and

            cl.ClaimKey in
            (
                select
                    r.Claimkey
                from
                    #reload r
                where
                    r.ClaimKey is not null
            ) and

            --not exists
            --(
            --    select 
            --        null
            --    from
            --        [db_au_mdmenterprise]..C_PARTY_PRODUCT_TXN r
            --    where
            --        r.PROD_REF_NO = cn.NameKey and
            --        r.LAST_ROWID_SYSTEM = 'CLAIMS'
            --) and        

            isnull(cn.IsThirdParty, 0) = 0 and
            --rtrim(isnull(cn.FirstName, '')) <> '' and
            isnull(cn.FirstName, '') not like 'Traveller%' and
            isnull(cn.Surname, '') <> '' 
        --order by
        --    cl.CreateDate desc
    )
    insert into [db_au_mdmenterprise]..C_L_PARTY
    (
        LAST_UPDATE_DATE,
        PARTY_PKEY,
        SRC_SYS,
        TITLE,
        FRST_NM,
        MID_NM,
        LST_NM,
        PRTY_NM,
        OTHR_NM,
        GNDR,
        MARITL_STS,
        DOB,
        AGE,
        IS_DCSED,
        ENTITY_TYP,
        DIST_CD,
        NOTATNL_DIST,
        PRTY_TYP,
        ADDR_TYP,
        ADDR_LINE1,
        ADDR_LINE2,
        CITY,
        PRVNCE,
        CNTRY,
        CNTRY_CD,
        POST_CD,
        DLVRY_PT_DPID,
        PRTY_ROLE,
        PROD_TYP,
        DOMAIN_CD,
        DOMAIN_NM,
        TXN_STATUS,
        EMAIL,
        EMAIL_TYP,
        IDNTIFR_TYP,
        IDNTIFR_SUB_TYP,
        IDNTIFR_VAL,
        PH_CNTRY_CD,
        PH_VAL,
        FULL_PH_VAL,
        PH_TYP,
        PH_SUB_TYP,
        IDENT_SUB_DTL_TYP,
        IDENT_SUB_DTL_VAL,
        IND_NM,
        ORG_NM,
        PROD_REF_NO,
        PRTY_STATUS,
        PRTY_COMMENTS,
        POLICY_KEY,
        SRC_RECORD_ID,
        WORK_PHONE_NO,
        HOME_PHONE_NO,
        ACCOUNT_HASH
    )
    select
        case
            when @ReloadCustomerID = '0' then getdate()
            else LAST_UPDATE_DATE
        end LAST_UPDATE_DATE,
        PARTY_PKEY,
        SRC_SYS,
        TITLE,
        FRST_NM,
        MID_NM,
        LST_NM,
        PRTY_NM,
        OTHR_NM,
        GNDR,
        MARITL_STS,
        DOB,
        AGE,
        IS_DCSED,
        ENTITY_TYP,
        DIST_CD,
        NOTATNL_DIST,
        PRTY_TYP,
        ADDR_TYP,
        ADDR_LINE1,
        ADDR_LINE2,
        CITY,
        case
            when CNTRY_CD = 'AUS' and PRVNCE = 'NSW' then 'New South Wales'
            when CNTRY_CD = 'AUS' and PRVNCE = 'QLD' then 'Queensland'
            when CNTRY_CD = 'AUS' and PRVNCE = 'VIC' then 'Victoria'
            when CNTRY_CD = 'AUS' and PRVNCE = 'TAS' then 'Tasmania'
            when CNTRY_CD = 'AUS' and PRVNCE = 'WA' then 'Western Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'SA' then 'South Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'ACT' then 'Australian Capital Territory'
            when CNTRY_CD = 'AUS' and PRVNCE = 'NT' then 'Northern Territory'
            else PRVNCE
        end PRVNCE,
        CNTRY,
        CNTRY_CD,
        POST_CD,
        DLVRY_PT_DPID,
        PRTY_ROLE,
        PROD_TYP,
        DOMAIN_CD,
        DOMAIN_NM,
        TXN_STATUS,
        EMAIL,
        EMAIL_TYP,
        'Membership Number' IDNTIFR_TYP,
        null IDNTIFR_SUB_TYP,
        MemberNumber IDNTIFR_VAL,
        null PH_CNTRY_CD,
        null PH_VAL,
        FULL_PH_VAL,
        PH_TYP,
        null PH_SUB_TYP,
        null IDENT_SUB_DTL_TYP,
        null IDENT_SUB_DTL_VAL,
        PRTY_NM IND_NM,
        null ORG_NM,
        PARTY_PKEY PROD_REF_NO,
        PRTY_STATUS,
        null PRTY_COMMENTS,
        POLICY_KEY,
        null SRC_RECORD_ID,
        WORK_PHONE_NO,
        HOME_PHONE_NO,
        null ACCOUNT_HASH
    --into #policy
    from
        cte_traveller

    union all

    select 
        case
            when @ReloadCustomerID = '0' then getdate()
            else LAST_UPDATE_DATE
        end LAST_UPDATE_DATE,
        PARTY_PKEY,
        SRC_SYS,
        TITLE,
        FRST_NM,
        MID_NM,
        LST_NM,
        PRTY_NM,
        OTHR_NM,
        GNDR,
        MARITL_STS,
        DOB,
        AGE,
        IS_DCSED,
        ENTITY_TYP,
        DIST_CD,
        NOTATNL_DIST,
        PRTY_TYP,
        ADDR_TYP,
        ADDR_LINE1,
        ADDR_LINE2,
        CITY,
        case
            when CNTRY_CD = 'AUS' and PRVNCE = 'NSW' then 'New South Wales'
            when CNTRY_CD = 'AUS' and PRVNCE = 'QLD' then 'Queensland'
            when CNTRY_CD = 'AUS' and PRVNCE = 'VIC' then 'Victoria'
            when CNTRY_CD = 'AUS' and PRVNCE = 'TAS' then 'Tasmania'
            when CNTRY_CD = 'AUS' and PRVNCE = 'WA' then 'Western Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'SA' then 'South Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'ACT' then 'Australian Capital Territory'
            when CNTRY_CD = 'AUS' and PRVNCE = 'NT' then 'Northern Territory'
            else PRVNCE
        end PRVNCE,
        CNTRY,
        CNTRY_CD,
        POST_CD,
        DLVRY_PT_DPID,
        PRTY_ROLE,
        PROD_TYP,
        DOMAIN_CD,
        DOMAIN_NM,
        TXN_STATUS,
        EMAIL,
        EMAIL_TYP,
        PIDType IDNTIFR_TYP,
        null IDNTIFR_SUB_TYP,
        PIDValue IDNTIFR_VAL,
        null PH_CNTRY_CD,
        null PH_VAL,
        FULL_PH_VAL,
        PH_TYP,
        null PH_SUB_TYP,
        null IDENT_SUB_DTL_TYP,
        null IDENT_SUB_DTL_VAL,
        PRTY_NM IND_NM,
        null ORG_NM,
        PARTY_PKEY PROD_REF_NO,
        PRTY_STATUS,
        null PRTY_COMMENTS,
        POLICY_KEY,
        null SRC_RECORD_ID,
        WORK_PHONE_NO,
        HOME_PHONE_NO,
        null ACCOUNT_HASH
    from
        cte_traveller
    where
        PIDValue is not null

    union all

    select 
        case
            when @ReloadCustomerID = '0' then getdate()
            else LAST_UPDATE_DATE
        end LAST_UPDATE_DATE,
        PARTY_PKEY,
        SRC_SYS,
        TITLE,
        FRST_NM,
        MID_NM,
        LST_NM,
        PRTY_NM,
        OTHR_NM,
        GNDR,
        MARITL_STS,
        DOB,
        AGE,
        IS_DCSED,
        ENTITY_TYP,
        DIST_CD,
        NOTATNL_DIST,
        PRTY_TYP,
        ADDR_TYP,
        ADDR_LINE1,
        ADDR_LINE2,
        CITY,
        case
            when CNTRY_CD = 'AUS' and PRVNCE = 'NSW' then 'New South Wales'
            when CNTRY_CD = 'AUS' and PRVNCE = 'QLD' then 'Queensland'
            when CNTRY_CD = 'AUS' and PRVNCE = 'VIC' then 'Victoria'
            when CNTRY_CD = 'AUS' and PRVNCE = 'TAS' then 'Tasmania'
            when CNTRY_CD = 'AUS' and PRVNCE = 'WA' then 'Western Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'SA' then 'South Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'ACT' then 'Australian Capital Territory'
            when CNTRY_CD = 'AUS' and PRVNCE = 'NT' then 'Northern Territory'
            else PRVNCE
        end PRVNCE,
        CNTRY,
        CNTRY_CD,
        POST_CD,
        DLVRY_PT_DPID,
        PRTY_ROLE,
        PROD_TYP,
        DOMAIN_CD,
        DOMAIN_NM,
        TXN_STATUS,
        EMAIL,
        EMAIL_TYP,
        'COMPANION' IDNTIFR_TYP,
        null IDNTIFR_SUB_TYP,
        Companion IDNTIFR_VAL,
        null PH_CNTRY_CD,
        null PH_VAL,
        FULL_PH_VAL,
        PH_TYP,
        null PH_SUB_TYP,
        null IDENT_SUB_DTL_TYP,
        null IDENT_SUB_DTL_VAL,
        PRTY_NM IND_NM,
        null ORG_NM,
        PARTY_PKEY PROD_REF_NO,
        PRTY_STATUS,
        null PRTY_COMMENTS,
        POLICY_KEY,
        null SRC_RECORD_ID,
        WORK_PHONE_NO,
        HOME_PHONE_NO,
        null ACCOUNT_HASH
    from
        cte_traveller
    where
        isnull(Companion, '') <> ''

    union all

    select 
        case
            when @ReloadCustomerID = '0' then getdate()
            else LAST_UPDATE_DATE
        end LAST_UPDATE_DATE,
        PARTY_PKEY,
        SRC_SYS,
        TITLE,
        FRST_NM,
        MID_NM,
        LST_NM,
        PRTY_NM,
        OTHR_NM,
        GNDR,
        MARITL_STS,
        DOB,
        AGE,
        IS_DCSED,
        ENTITY_TYP,
        DIST_CD,
        NOTATNL_DIST,
        PRTY_TYP,
        ADDR_TYP,
        ADDR_LINE1,
        ADDR_LINE2,
        CITY,
        case
            when CNTRY_CD = 'AUS' and PRVNCE = 'NSW' then 'New South Wales'
            when CNTRY_CD = 'AUS' and PRVNCE = 'QLD' then 'Queensland'
            when CNTRY_CD = 'AUS' and PRVNCE = 'VIC' then 'Victoria'
            when CNTRY_CD = 'AUS' and PRVNCE = 'TAS' then 'Tasmania'
            when CNTRY_CD = 'AUS' and PRVNCE = 'WA' then 'Western Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'SA' then 'South Australia'
            when CNTRY_CD = 'AUS' and PRVNCE = 'ACT' then 'Australian Capital Territory'
            when CNTRY_CD = 'AUS' and PRVNCE = 'NT' then 'Northern Territory'
            else PRVNCE
        end PRVNCE,
        CNTRY,
        CNTRY_CD,
        POST_CD,
        DLVRY_PT_DPID,
        PRTY_ROLE,
        PROD_TYP,
        DOMAIN_CD,
        DOMAIN_NM,
        TXN_STATUS,
        EMAIL,
        EMAIL_TYP,
        'Account Number' IDNTIFR_TYP,
        null IDNTIFR_SUB_TYP,
        Account IDNTIFR_VAL,
        null PH_CNTRY_CD,
        null PH_VAL,
        FULL_PH_VAL,
        PH_TYP,
        null PH_SUB_TYP,
        null IDENT_SUB_DTL_TYP,
        null IDENT_SUB_DTL_VAL,
        PRTY_NM IND_NM,
        null ORG_NM,
        PARTY_PKEY PROD_REF_NO,
        PRTY_STATUS,
        null PRTY_COMMENTS,
        POLICY_KEY,
        null SRC_RECORD_ID,
        WORK_PHONE_NO,
        HOME_PHONE_NO,
        null ACCOUNT_HASH
    --into #claims
    from
        cte_claim



    --select *
    --from
    --    tempdb.information_schema.columns
    --where
    --    table_name like '#temp%'

    --select *
    --from
    --    [db_au_mdmenterprise].information_schema.columns
    --where
    --    table_name like 'C_L_PARTY'

    --select top 100
    --    PRVNCE,
    --    len(PRVNCE)
    --from
    --    #temp
    --order by
    --    len(PRVNCE) desc


    --select *
    --from
    --    tempdb.information_schema.columns
    --where
    --    table_name like '#policy%'

    --select *
    --from
    --    tempdb.information_schema.columns
    --where
    --    table_name like '#claims_____________________________________________________________________________________________________________00000000753F%'


end
GO
