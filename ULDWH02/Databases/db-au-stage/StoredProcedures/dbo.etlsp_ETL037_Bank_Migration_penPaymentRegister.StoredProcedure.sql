USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL037_Bank_Migration_penPaymentRegister]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL037_Bank_Migration_penPaymentRegister] 
    @Country varchar(10) = ''
    
as
begin
--TRIPS BankReturn table data migration to PENGUIN
--Transform and migration BankReturn data to penPaymentRegister
--PaymentRegisterKey will have a 'T' prefix to denote trips migrated data.

--2013-08-02, LS, fill in and map more columns

    set nocount on

    if object_id('tempdb..#Country') is null
	    create table #Country (Country varchar(2) null)
    else 
        truncate table #Country	

    if @Country = 'UK' 
        insert #Country values('UK')

    else
    begin
	    insert #Country values('AU')
	    insert #Country values('NZ')
	    insert #Country values('SG')
	    insert #Country values('MY')
    end

    insert [db-au-cmdwh].dbo.penPaymentRegister 
    (
        [CountryKey],
        [CompanyKey],
        [DomainKey],
        [PaymentRegisterKey],
        [OutletKey],
        [CRMUserKey],
        [BankAccountKey],
        [PaymentRegisterID],
        [OutletID],
        [CRMUserID],
        [BankAccountID],
        [PaymentStatus],
        [PaymentTypeID],
        [PaymentType],
        [PaymentCode],
        [PaymentSource],
        [PaymentCreateDateTime],
        [PaymentUpdateDateTime],
        [PaymentCreateDateTimeUTC],
        [PaymentUpdateDateTimeUTC],
        [TripsAccount]
    )
    select 
        br.CountryKey,
        isnull(o.CompanyKey, ax.CompanyKey) CompanyKey,
        br.CountryKey + '-' + isnull(o.CompanyKey, ax.CompanyKey) + '-' + convert(varchar, isnull(o.DomainID, ax.DomainID)) DomainKey,
        br.CountryKey + '-T' + convert(varchar, br.ReturnID) PaymentRegisterKey,
        o.OutletKey,
        cu.CRMUserKey,
        br.CountryKey + '-T' + isnull(o.CompanyKey, ax.CompanyKey) + '-' + upper(br.Account) BankAccountKey,	
        br.ReturnID PaymentRegisterID,
        o.OutletID,
        cu.CRMUserID,
        null BankAccountID,
        'NEW' PaymentStatus, --NEW? DONE?
        case
            when bp.PayType in ('C', 'CC', 'CH', 'CHE', 'CHQ') then 1
            when bp.PayType in ('CSH', 'DD', 'DDB', 'MO', 'TT') then 3
            else 4
        end PaymentTypeID,
        case
            when bp.PayType in ('C', 'CC', 'CH', 'CHE', 'CHQ') then 'Cheque'
            when bp.PayType in ('CSH', 'DD', 'DDB', 'MO', 'TT') then 'Direct Deposit'
            else 'System'
        end PaymentType,
        case
            when bp.PayType in ('C', 'CC', 'CH', 'CHE', 'CHQ') then 'CHQ'
            when bp.PayType in ('CSH', 'DD', 'DDB', 'MO', 'TT') then 'DDT'
            else 'SYS'
        end PaymentCode,
        'MIGRATION' PaymentSource,
        br.BankDate PaymentCreateDateTime,
        br.BankDate PaymentUpdateDateTime,
        [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(br.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) PaymentCreateDateTimeUTC,
        [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(br.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) PaymentUpdateDateTimeUTC,
        br.Account TripsAccount
    from
        [db-au-cmdwh].dbo.BankReturn br
        outer apply
        (
            select top 1 
                bp.PayType
            from
                [db-au-cmdwh].dbo.BankPayment bp
            where
                bp.ReturnKey = br.ReturnKey
        ) bp
        left join [db-au-cmdwh].dbo.Agency a on 
	        a.AgencyKey = br.AgencyKey and
	        a.AgencyStatus = 'Current'
        outer apply
        (
            select
                case 
                    when a.AgencySuperGroupName in ('AAA','Medibank','Australia Post') then 'TIP'
	                else 'CM'
                end CompanyKey,
                case a.CountryKey 
                    when 'AU' then 7
                    when 'NZ' then 8
                    when 'SG' then 10
                    when 'MY' then 9
                    else 7
                end DomainID
        ) ax
        left join [db-au-cmdwh].dbo.penOutlet o on
            o.CountryKey = a.CountryKey and
            o.AlphaCode = a.AgencyCode and
            --20130808, LS, RQQ0001, RQQ0002 duplicate alpha codes
            o.GroupCode = a.AgencyGroupCode and

            o.OutletStatus = 'Current'
        outer apply
        (
            select top 1 
                pcu.CRMUserID,
                pcu.CRMUserKey
            from
                [db-au-cmdwh].dbo.crmUser cu
                left join [db-au-cmdwh].dbo.penCRMUser pcu on
                    pcu.CountryKey = cu.CountryKey and
                    pcu.FirstName + ' ' + pcu.LastName = cu.Name
            where
                cu.CountryKey = br.CountryKey and
                cu.Initial = br.Op
        ) cu
        outer apply
        (
            select top 1 
                TimeZoneCode
            from
                [db-au-cmdwh].dbo.penDomain d
            where
                d.DomainID = isnull(o.DomainID, ax.DomainID)
        ) d
    where
        (
            @Country = '' or
            br.CountryKey in 
            (
                select 
                    Country 
                from 
                    #Country
            ) 
        ) and
        not exists
        (
            select null
            from
                [db-au-cmdwh].dbo.penPaymentRegister pr
            where
                pr.PaymentRegisterKey = br.CountryKey + '-T' + convert(varchar, br.ReturnID)
        )
        
    union all
    
    --adjustment without any payment
    select 
	    b.CountryKey,
	    isnull(o.CompanyKey, ax.CompanyKey) CompanyKey,
	    b.CountryKey + '-' + isnull(o.CompanyKey, ax.CompanyKey) + '-' + convert(varchar, isnull(o.DomainID, ax.DomainID)) DomainKey,
        b.CountryKey + '-TA' + convert(varchar, b.RecordNo) PaymentRegisterKey,
        o.OutletKey,
        cu.CRMUserKey,
        '' BankAccountKey,	
	    b.RecordNo PaymentRegisterID,
        o.OutletID,
        cu.CRMUserID,
        null BankAccountID,
        'DONE' PaymentStatus, --NEW? DONE?
        4 PaymentTypeID,
        'System' PaymentType,
        'SYS' PaymentCode,
        'ADJUSTMENT MIGRATION' PaymentSource,
        b.BankDate PaymentCreateDateTime,
        b.BankDate PaymentUpdateDateTime,
        [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) PaymentCreateDateTimeUTC,
        [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) PaymentUpdateDateTimeUTC,
        '' TripsAccount
    from
        [db-au-cmdwh].dbo.Bank b
        left join [db-au-cmdwh].dbo.BankPayment bp on
            bp.BankRecordKey = b.BankRecordKey
        left join [db-au-cmdwh].dbo.Agency a on 
            a.AgencyKey = b.AgencyKey and
            a.AgencyStatus = 'Current'
        outer apply
        (
            select
                case 
                    when a.AgencySuperGroupName in ('AAA','Medibank','Australia Post') then 'TIP'
                    else 'CM'
                end CompanyKey,
                case a.CountryKey 
                    when 'AU' then 7
                    when 'NZ' then 8
                    when 'SG' then 10
                    when 'MY' then 9
                    else 7
                end DomainID
        ) ax
        left join [db-au-cmdwh].dbo.penOutlet o on
            o.CountryKey = a.CountryKey and
            o.AlphaCode = a.AgencyCode and
            o.OutletStatus = 'Current'
        outer apply
        (
            select top 1 
                pcu.CRMUserID,
                pcu.CRMUserKey
            from
                [db-au-cmdwh].dbo.crmUser cu
                left join [db-au-cmdwh].dbo.penCRMUser pcu on
                    pcu.CountryKey = cu.CountryKey and
                    pcu.FirstName + ' ' + pcu.LastName = cu.Name
            where
                cu.CountryKey = b.CountryKey and
                cu.Initial = b.Op
        ) cu
        outer apply
        (
            select top 1 
                TimeZoneCode
            from
                [db-au-cmdwh].dbo.penDomain d
            where
                d.DomainID = isnull(o.DomainID, ax.DomainID)
        ) d    
    where
        bp.BankRecordKey is null and
        (
            @Country = '' or
            b.CountryKey in 
            (
                select 
                    Country 
                from 
                    #Country
            ) 
        ) and
        not exists
        (
            select null
            from
                [db-au-cmdwh].dbo.penPaymentRegister pr
            where
                pr.PaymentRegisterKey = b.CountryKey + '-TA' + convert(varchar, b.RecordNo)
        )
        
end
GO
