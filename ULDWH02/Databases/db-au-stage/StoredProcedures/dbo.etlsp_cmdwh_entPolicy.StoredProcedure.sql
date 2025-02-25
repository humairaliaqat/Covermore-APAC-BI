USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entPolicy]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entPolicy]
as
begin
/*
    20160817, LL, create
    20190405, LL, lighten up policy key update process. it's already on C_PARTY_PRODUCT_TXN
*/

--don't forget to update this block list
--update t
--set
--    t.CustomerID = r.CustomerID
--from
--    [db-au-workspace]..EnterpriseBlacklist t
--    cross apply
--    (
--        select top 1 
--            CustomerID
--        from
--            entPolicy p
--        where
--            p.PolicyKey = t.PolicyKey
--    ) r


    set nocount on

    exec etlsp_StagingIndex_EnterpriseMDM

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'EnterpriseMDM ODS',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh].dbo.entPolicy') is null
    begin
    
        create table [db-au-cmdwh].dbo.entPolicy
        (
            BIRowID bigint identity(1,1) not null,
            TransactionID bigint not null,
            CustomerID bigint not null,
            SourceSystem nchar(14),
            Reference nvarchar(300),
            ClaimKey varchar(40),
            PolicyKey varchar(41),
            FTS varchar(max),
            UpdateBatchID bigint
        )

        create unique clustered index idx_entPolicy_BIRowID on [db-au-cmdwh].dbo.entPolicy(BIRowID)
        create nonclustered index idx_entPolicy_CustomerID on [db-au-cmdwh].dbo.entPolicy(CustomerID) include(BIRowID,PolicyKey,Claimkey,Reference)
        create nonclustered index idx_entPolicy_PolicyKey on [db-au-cmdwh].dbo.entPolicy(PolicyKey)  include(BIRowID,CustomerID)
        create nonclustered index idx_entPolicy_ClaimKey on [db-au-cmdwh].dbo.entPolicy(ClaimKey)  include(BIRowID,CustomerID,PolicyKey)
        create nonclustered index idx_entPolicy_Reference on [db-au-cmdwh].dbo.entPolicy (Reference, SourceSystem) include (PolicyKey,ClaimKey,CustomerID,BIRowID)

    end

    if object_id('tempdb..#entPolicy') is not null
        drop table #entPolicy

    select --top 1000
        try_convert(bigint, rtrim(ROWID_OBJECT)) TransactionID,
        try_convert(bigint, rtrim(PRTY_FK)) CustomerID,
        LAST_ROWID_SYSTEM SourceSystem,
        PROD_REF_NO Reference,
        POLICY_KEY,
        case
            when LAST_ROWID_SYSTEM = 'CLAIMS' then left(PROD_REF_NO, charindex('-', PROD_REF_NO, 4) - 1)
            else null
        end  CLAIM_KEY
    into #entPolicy
    from
        ent_C_PARTY_PRODUCT_TXN_aucm tx
    where
        LAST_ROWID_SYSTEM in ('PENGUIN', 'CLAIMS') and
        HUB_STATE_IND = 1

    create index idx_1 on #entPolicy (CLAIM_KEY) include (CustomerID,POLICY_KEY)
    create index idx_2 on #entPolicy (POLICY_KEY) include (CustomerID)

--select
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',
--    COLUMN_NAME + ',',
--    COLUMN_NAME + ' = s.' + COLUMN_NAME + ',',
--    's.' + COLUMN_NAME + ','
--from
--    tempdb.INFORMATION_SCHEMA.COLUMNS
--where
--    table_name like '#entPolicy%'

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        select 1 id
        into #test

        while @@rowcount > 0
            delete top (100000) t with(tablock)
            from
                [db-au-cmdwh].dbo.entPolicy t
                inner join #entPolicy r on
                    r.SourceSystem = t.SourceSystem and
                    r.Reference = t.Reference


        insert into [db-au-cmdwh].dbo.entPolicy with(tablock)
        (
            TransactionID,
            CustomerID,
            SourceSystem,
            Reference,
            PolicyKey,
            ClaimKey,
            UpdateBatchID
        )
        select
            TransactionID,
            CustomerID,
            SourceSystem,
            Reference,
            POLICY_KEY,
            CLAIM_KEY,
            -1
        from
            #entPolicy t
        where
            not exists
            (
                select
                    null
                from
                    [db-au-cmdwh]..entPolicy r
                where
                    t.Reference = r.Reference and
                    t.SourceSystem = r.SourceSystem and
                    t.CustomerID = r.CustomerID
            )

        while @@rowcount > 0
        begin

            update top(100000) tx 
            set
                tx.ClaimKey = cl.ClaimKey,
                tx.PolicyKey = isnull(p.PolicyKey, cl.PolicyKey)
            from
                [db-au-cmdwh]..entPolicy tx --with(nolock)
                outer apply
                (
                    select top 1 
                        cl.ClaimKey,
                        pt.PolicyKey,
                        cl.PolicyNo
                    from
                        [db-au-cmdwh].dbo.clmName cn with(nolock)
                        inner join [db-au-cmdwh].dbo.clmClaim cl with(nolock) on
                            cl.ClaimKey = cn.ClaimKey
                        left join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
                            pt.PolicyTransactionKey = cl.PolicyTransactionKey
                    where
                        tx.SourceSystem = 'CLAIMS' and
                        cn.NameKey = tx.Reference
                ) cl
                outer apply
                (
                    select top 1 
                        ptv.PolicyKey,
                        PolicyNumber
                    from
                        [db-au-cmdwh].dbo.penPolicyTraveller ptv with(nolock)
                        inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
                            p.PolicyKey = ptv.PolicyKey
                    where
                        tx.SourceSystem = 'PENGUIN' and
                        ptv.PolicyTravellerKey = tx.Reference
                ) p
            where
                tx.PolicyKey is null

        end


        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount



    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'entPolicy data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction




    --names
    if object_id('[db-au-cmdwh].dbo.entAlias') is null
    begin

        create table [db-au-cmdwh].dbo.entAlias
        (
            BIRowID bigint identity(1,1) not null,
            CustomerID bigint not null,
            Alias nvarchar(250)
        )

        create clustered index idx_entAccounts_BIRowID on [db-au-cmdwh].dbo.entAlias(BIRowID)
        create nonclustered index idx_entAccounts_CustomerID on [db-au-cmdwh].dbo.entAlias(CustomerID) include(BIRowID,Alias)
        create nonclustered index idx_entAccounts_Aliason on [db-au-cmdwh].dbo.entAlias(Alias) include(BIRowID,CustomerID)

    end

    if object_id('tempdb..#alias') is not null
        drop table #alias

    select 
        CustomerID,
        ltrim(rtrim(ptv.FirstName)) + ' ' + ltrim(rtrim(ptv.LastName)) Alias
    into #alias
    from
        [db-au-cmdwh]..entPolicy ep
        inner join [db-au-cmdwh]..penPolicyTraveller ptv on
            ptv.PolicyKey = ep.PolicyKey and
            ptv.PolicyTravellerKey = ep.Reference
    where
        ep.ClaimKey is null and
        CustomerID in
        (
            select
                CustomerID
            from
                #entPolicy
        )

    insert into #alias
    select 
        CustomerID,
        ltrim(rtrim(cn.Firstname)) + ' ' + ltrim(rtrim(cn.Surname)) Alias
    from
        [db-au-cmdwh]..entPolicy ep
        inner join [db-au-cmdwh]..clmName cn on
            cn.ClaimKey = ep.ClaimKey and
            cn.NameKey = ep.Reference
    where
        ep.ClaimKey is not null and
        CustomerID in
        (
            select
                CustomerID
            from
                #entPolicy
        )

        
    insert into [db-au-cmdwh]..entAlias
    (
        CustomerID,
        Alias
    )
    select distinct
        CustomerID,
        Alias
    from
        #alias t
    where
        not exists
        (
            select 
                null
            from
                [db-au-cmdwh]..entAlias r
            where
                r.CustomerID = t.CustomerID and
                r.Alias = t.Alias
        )


    --accounts
    if object_id('[db-au-cmdwh].dbo.entAccounts') is null
    begin

        create table [db-au-cmdwh].dbo.entAccounts
        (
            BIRowID bigint identity(1,1) not null,
            CustomerID bigint not null,
            AccountID nvarchar(30)
        )

        create clustered index idx_entAccounts_BIRowID on [db-au-cmdwh].dbo.entAccounts(BIRowID)
        create nonclustered index idx_entAccounts_CustomerID on [db-au-cmdwh].dbo.entAccounts(CustomerID) include(BIRowID,AccountID)
        create nonclustered index idx_entAccounts_AccountID on [db-au-cmdwh].dbo.entAccounts(AccountID) include(BIRowID,CustomerID)

    end

    insert into [db-au-cmdwh]..entAccounts 
    (
        CustomerID,
        AccountID
    )
    select distinct
        CustomerID,
        AccountID
    from
        (
            select
                cl.CustomerID,
                left('0000000000', 10 - len(dcs.BSBs)) + dcs.BSBs + left('00000000000000000000', 20 - len(dcs.Accounts)) + dcs.Accounts AccountID
            from
                [db-au-cmdwh]..entPolicy cl with(nolock)
                inner join [db-au-cmdwh]..clmName cn with(nolock) on
                    cn.ClaimKey = cl.ClaimKey and
                    cn.NameKey = cl.Reference
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
            where
                cn.EncryptAccount is not null and
                cl.CustomerID in
                (
                    select 
                        try_convert(bigint, rtrim(ORIG_ROWID_OBJECT))
                    from
                        ent_vC_PARTY_XREF_aucm
                ) and
                not exists
                (
                    select
                        null
                    from
                        [db-au-cmdwh]..entAccounts r
                    where
                        r.CustomerID = cl.CustomerID and
                        r.AccountID = (left('0000000000', 10 - len(dcs.BSBs)) + dcs.BSBs + left('00000000000000000000', 20 - len(dcs.Accounts)) + dcs.Accounts)
                )
        ) t
    where
        t.AccountID <> '000000000000000000000000000000'


    --audit data, paid but then changed to something else
    insert into [db-au-cmdwh]..entAccounts 
    (
        CustomerID,
        AccountID
    )
    select distinct
        CustomerID,
        AccountID
    from
        (
            select
                cl.CustomerID,
                left('0000000000', 10 - len(dcs.BSBs)) + dcs.BSBs + left('00000000000000000000', 20 - len(dcs.Accounts)) + dcs.Accounts AccountID
            from
                [db-au-cmdwh]..entPolicy cl with(nolock)
                inner join [db-au-cmdwh]..clmAuditName cn with(nolock) on
                    cn.ClaimKey = cl.ClaimKey and
                    cn.NameKey = cl.Reference
                outer apply
                (
                    select 
                        min(rcn.AuditDateTime) NextNameChange
                    from
                        [db-au-cmdwh]..clmAuditName rcn with(nolock)
                    where
                        rcn.NameKey = cn.NameKey and
                        rcn.AuditDateTime > cn.AuditDateTime and
                        rcn.BIRowID > cn.BIRowID
                ) ncn
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
            where
                cn.EncryptAccount is not null and
                cl.CustomerID in
                (
                    select 
                        try_convert(bigint, rtrim(ORIG_ROWID_OBJECT))
                    from
                        ent_vC_PARTY_XREF_aucm
                ) and
                not exists
                (
                    select
                        null
                    from
                        [db-au-cmdwh]..entAccounts r
                    where
                        r.CustomerID = cl.CustomerID and
                        r.AccountID = (left('0000000000', 10 - len(dcs.BSBs)) + dcs.BSBs + left('00000000000000000000', 20 - len(dcs.Accounts)) + dcs.Accounts)
                ) and
                exists
                (
                    select 
                        null
                    from
                        [db-au-cmdwh]..clmAuditPayment cp 
                    where
                        cp.ClaimKey = cn.ClaimKey and
                        cp.PayeeKey = cn.NameKey and
                        cp.PaymentStatus = 'PAID' and
                        cp.AuditDateTime >= cn.AuditDateTime and
                        cp.AuditDateTime <  ncn.NextNameChange
                ) 
        ) t
    where
        t.AccountID <> '000000000000000000000000000000'



    --claim flags
    update cf
    set
        cf.CustomerID = r.CustomerID
    from
        [db-au-cmdwh]..clmClaimFlags cf
        cross apply
        (
            select top 1
                CustomerID
            from
                #entPolicy r
            where
                r.CLAIM_KEY = cf.ClaimKey
        ) r
        
    update cf
    set
        cf.CustomerID = mc.CustomerID
    from
        [db-au-cmdwh]..clmClaimFlags cf
        cross apply
        (
            select top 1 
                CustomerID
            from
                [db-au-cmdwh]..entPolicy mc
            where
                mc.ClaimKey = cf.ClaimKey
        ) mc
    where
        cf.CustomerID is null

    update cf
    set
        cf.CustomerID = mp.CustomerID
    from
        [db-au-cmdwh]..clmClaimFlags cf
        inner join [db-au-cmdwh]..clmClaim cl on
            cl.ClaimKey = cf.ClaimKey
        inner join [db-au-cmdwh]..penPolicyTransSummary pt on
            pt.PolicyTransactionKey = cl.PolicyTransactionKey
        cross apply
        (
            select top 1 
                CustomerID
            from
                [db-au-cmdwh]..entPolicy mc
            where
                mc.PolicyKey = pt.PolicyKey
        ) mp
    where
        cf.CustomerID is null



    if datename(dw, getdate()) = 'Saturday'
    begin

        --emcApplicants
        update t
        set
            t.CustomerID = ec.CustomerID
        --select top 1000 
        --    ec.CustomerID,
        --    t.RelaxedApplicantHash
        from
            [db-au-cmdwh]..entCustomer ec with(nolock)
            cross apply
            (
                select distinct
                    ep.PolicyKey
                from
                    [db-au-cmdwh]..entPolicy ep with(nolock)
                where
                    ep.CustomerID = ec.CustomerID
            ) ep
            inner join [db-au-cmdwh]..penPolicyTraveller ptv with(nolock) on
                ptv.PolicyKey = ep.PolicyKey and
                ptv.FirstName = ec.FirstName
            inner join [db-au-cmdwh]..penPolicyTravellerTransaction ptt with(nolock) on
                ptt.PolicyTravellerKey = ptv.PolicyTravellerKey
            inner join [db-au-cmdwh]..penPolicyEMC pe with(nolock) on
                pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
            inner join [db-au-cmdwh]..emcApplicants ea on
                ea.ApplicationKey = pe.EMCApplicationKey
            inner join [db-au-cmdwh]..emcApplicants t on
                t.RelaxedApplicantHash = ea.RelaxedApplicantHash
        where
            ec.CustomerID in
            (
                select 
                    CustomerID
                from
                    #entPolicy
            )

	    --cbCase
	    update cc
	    --select 
	    --	top 100
	    --	cc.CaseNo,
	    --	cc.FirstName,
	    --	cc.Surname,
	    --	cc.DOB,
	    --	cp.CustomerID,
	    --	cp.CUstomerName
	    set
		    cc.CustomerID = ec.CustomerID
        from
            [db-au-cmdwh]..entCustomer ec with(nolock)
            cross apply
            (
                select distinct
                    ep.PolicyKey
                from
                    [db-au-cmdwh]..entPolicy ep with(nolock)
                where
                    ep.CustomerID = ec.CustomerID
            ) ep
            inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
			    pt.PolicyKey = ep.PolicyKey
            inner join [db-au-cmdwh]..cbPolicy cp with(nolock) on
			    cp.PolicyTransactionKey = pt.PolicyTransactionKey and
			    cp.isMainPolicy = 1
		    inner join [db-au-cmdwh]..cbCase cc on
			    cc.CaseKey = cp.CaseKey and
			    ec.CUstomerName like '%' + rtrim(ltrim(cc.FirstName)) + '%' and
			    ec.CUstomerName like '%' + rtrim(ltrim(cc.Surname)) + '%'
        where
            ec.CustomerID in
            (
                select 
                    CustomerID
                from
                    #entPolicy
            )

	    update cc
	    --select 
	    --	top 100
	    --	cc.CaseNo,
	    --	cc.FirstName,
	    --	cc.Surname,
	    --	cc.DOB,
	    --	cp.CustomerID,
	    --	cp.CUstomerName
	    set
		    cc.CustomerID = ec.CustomerID
        from
            [db-au-cmdwh]..entAlias ec with(nolock)
            cross apply
            (
                select distinct
                    ep.PolicyKey
                from
                    [db-au-cmdwh]..entPolicy ep with(nolock)
                where
                    ep.CustomerID = ec.CustomerID
            ) ep
            inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
			    pt.PolicyKey = ep.PolicyKey
            inner join [db-au-cmdwh]..cbPolicy cp with(nolock) on
			    cp.PolicyTransactionKey = pt.PolicyTransactionKey and
			    cp.isMainPolicy = 1
		    inner join [db-au-cmdwh]..cbCase cc on
			    cc.CaseKey = cp.CaseKey and
			    ec.Alias like '%' + rtrim(ltrim(cc.FirstName)) + '%' and
			    ec.Alias like '%' + rtrim(ltrim(cc.Surname)) + '%'
        where
            ec.CustomerID in
            (
                select 
                    CustomerID
                from
                    #entPolicy
            ) and
		    cc.CustomerID is null

        --;with 
        --cte_testsection
        --as
        --(
        --    select --top 100
        --        cf.CustomerID,
        --        cs.SectionCode,
        --        cl.ClaimKey,
        --        pt.PolicyKey
        --    from
        --        [db-au-cmdwh]..clmClaimFlags cf
        --        inner join [db-au-cmdwh]..clmClaim cl with(nolock) on
        --            cl.ClaimKey = cf.ClaimKey
        --        inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
        --            pt.PolicyTransactionKey = cl.PolicyTransactionKey
        --        inner join [db-au-cmdwh]..clmSection cs with(nolock) on
        --            cs.ClaimKey = cl.ClaimKey
        --    where
        --        CustomerID is not null
        --)
        --update [db-au-cmdwh]..clmClaimFlags
        --set
        --    MultipleClaimRedFlag = 1
        --where
        --    CustomerID in
        --    (
        --        select 
        --            CustomerID
        --            --,
        --            --SectionCode,
        --            --count(distinct ClaimKey) ClaimCount,
        --            --count(distinct PolicyKey) PolicyCount
        --        from
        --            cte_testsection
        --        group by
        --            CustomerID,
        --            SectionCode
        --        having 
        --            count(distinct PolicyKey) > 2 or
        --            count(distinct ClaimKey) > 3
        --    )

    end

end

GO
