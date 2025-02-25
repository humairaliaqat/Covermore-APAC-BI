USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL037_Bank_Migration_penPaymentAllocation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL037_Bank_Migration_penPaymentAllocation] 
    @Country varchar(10) = ''
    
as
begin
--TRIPS Bank table data migration to PENGUIN
--Transform and migration Bank data to penPaymentAllocation
--PaymentAllocationKey will have a 'T' prefix to denote trips migrated data.

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

    insert [db-au-cmdwh].dbo.penPaymentAllocation with(tablockx)
    (
        [CountryKey],
        [CompanyKey],
        [DomainKey],
        [PaymentAllocationKey],
        [OutletKey],
        [CRMUserKey],
        [PaymentAllocationID],
        [OutletID],
        [AlphaCode],
        [AccountingPeriod],
        [AccountingPeriodUTC],
        [PaymentAmount],
        [AmountType],
        [Comments],
        [Status],
        [Source],
        [CreateDateTime],
        [UpdateDateTime],
        [CreateDateTimeUTC],
        [UpdateDateTimeUTC],
        [PolicyAmount]
    )
    select 
	    b.CountryKey,
	    isnull(o.CompanyKey, ax.CompanyKey) CompanyKey,
	    b.CountryKey + '-' + isnull(o.CompanyKey, ax.CompanyKey) + '-' + convert(varchar, isnull(o.DomainID, ax.DomainID)) DomainKey,
	    b.CountryKey + '-T' + convert(varchar, b.RecordNo) PaymentAllocationKey,
	    o.OutletKey,
	    cu.CRMUserKey,
	    b.RecordNo PaymentAllocationID,
	    o.OutletID,	
	    b.AgencyCode AlphaCode,
	    b.AccountingDate AccountingPeriod,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.AccountingDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) AccountingPeriodUTC,
	    b.Gross PaymentAmount,
	    'NET' AmountType,
	    b.Comments,
	    'DONE' [Status],
	    'MIGRATION' [Source],
	    b.BankDate CreateDateTime,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) CreateDateTimeUTC,
	    b.BankDate UpdateDateTime,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) UpdateDateTimeUTC,
	    null PolicyAmount
    from
	    [db-au-cmdwh].dbo.Bank b
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
            --20130808, LS, RQQ0001, RQQ0002 duplicate alpha codes
            o.GroupCode = a.AgencyGroupCode and
            
            o.OutletStatus = 'Current'
        outer apply
        (
            select top 1 
                TimeZoneCode
            from
                [db-au-cmdwh].dbo.penDomain d
            where
                d.DomainID = isnull(o.DomainID, ax.DomainID)
        ) d
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
    where
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
                [db-au-cmdwh].dbo.penPaymentAllocation pa
            where
                pa.PaymentAllocationKey = b.CountryKey + '-T' + convert(varchar, b.RecordNo)
        )

        
end
GO
