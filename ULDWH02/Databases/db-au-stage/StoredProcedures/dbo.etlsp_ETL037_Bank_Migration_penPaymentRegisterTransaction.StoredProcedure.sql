USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL037_Bank_Migration_penPaymentRegisterTransaction]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL037_Bank_Migration_penPaymentRegisterTransaction] 
    @Country varchar(10) = ''
    
as
begin
--TRIPS BankPayment table data migration to PENGUIN
--Transform and migration BankPayment data to penPaymentRegisterTransaction
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

    insert [db-au-cmdwh].dbo.penPaymentRegisterTransaction
    (
	    [CountryKey],
	    [CompanyKey],
	    [DomainKey],
	    [PaymentRegisterTransactionKey],
	    [PaymentRegisterKey],
	    [PaymentAllocationKey],
	    [PaymentRegisterTransactionID],
	    [PaymentRegisterID],
	    [PaymentAllocationID],
	    [Payer],
	    [BankDate],
	    [BankDateUTC],
	    [BSB],
	    [ChequeNumber],
	    [Amount],
	    [AmountType],
	    [Status],
	    [Comment],
	    [CreateDateTime],
	    [UpdateDateTime],
	    [CreateDateTimeUTC],
	    [UpdateDateTimeUTC],
	    [CreditNoteDepartmentID],
	    [CreditNoteDepartmentName],
	    [CreditNoteDepartmentCode],
	    [JointVentureID]
    )
    select 
	    bp.CountryKey,
	    isnull(o.CompanyKey, ax.CompanyKey) CompanyKey,
	    br.CountryKey + '-' + isnull(o.CompanyKey, ax.CompanyKey) + '-' + convert(varchar, isnull(o.DomainID, ax.DomainID)) DomainKey,
	    bp.CountryKey + '-T' + convert(varchar,bp.PaymentID) PaymentRegisterTransactionKey,	
        br.CountryKey + '-T' + convert(varchar, br.ReturnID) PaymentRegisterKey,
        br.CountryKey + '-T' + convert(varchar, b.RecordNo) PaymentAllocationKey,
	    bp.PaymentID PaymentRegisterTransactionID,
	    br.ReturnID PaymentRegisterID,
	    b.RecordNo PaymentAllocationID,
	    bp.Payer,
	    br.BankDate BankDate,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(br.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) BankDateUTC,
	    bp.BSB,
	    bp.ChequeNo ChequeNumber,
	    bp.Amount,
	    'NET' AmountType,
	    'DONE' [Status],
	    bp.Comment,
	    br.BankDate CreateDateTime,
	    br.BankDate UpdateDateTime,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(br.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) CreateDateTimeUTC,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(br.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) UpdateDateTimeUTC,
	    null CreditNoteDepartmentID,
	    null CreditNoteDepartmentName,
	    null CreditNoteDepartmentCode,
	    null JointVentureID
    from
        [db-au-cmdwh].dbo.BankPayment bp
        inner join [db-au-cmdwh].dbo.BankReturn br on 
            bp.ReturnKey = br.ReturnKey
        left join [db-au-cmdwh].dbo.Bank b on
            b.BankRecordKey = bp.BankRecordKey
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
                [db-au-cmdwh].dbo.penPaymentRegisterTransaction pr
            where
                pr.PaymentRegisterTransactionKey = bp.CountryKey + '-T' + convert(varchar,bp.PaymentID)
        )
        
    union all
    
    --adjustment without any payment
    select 
	    b.CountryKey,
	    isnull(o.CompanyKey, ax.CompanyKey) CompanyKey,
	    b.CountryKey + '-' + isnull(o.CompanyKey, ax.CompanyKey) + '-' + convert(varchar, isnull(o.DomainID, ax.DomainID)) DomainKey,
	    b.CountryKey + '-TA' + convert(varchar, b.RecordNo) PaymentRegisterTransactionKey,	
        b.CountryKey + '-TA' + convert(varchar, b.RecordNo) PaymentRegisterKey,
        b.CountryKey + '-T' + convert(varchar, b.RecordNo) PaymentAllocationKey,
	    b.RecordNo PaymentRegisterTransactionID,
	    b.RecordNo PaymentRegisterID,
	    b.RecordNo PaymentAllocationID,
	    'Adjustment' Payer,
	    b.BankDate,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) BankDateUTC,
	    '' BSB,
	    b.RefundChq ChequeNumber,
	    b.Adjustment Amount,
	    'NET' AmountType,
	    'DONE' [Status],
	    b.Comments Comment,
	    b.BankDate CreateDateTime,
	    b.BankDate UpdateDateTime,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) CreateDateTimeUTC,
	    [db-au-cmdwh].dbo.xfn_ConvertLocaltoUTC(b.BankDate, isnull(d.TimeZoneCode, 'AUS Eastern Standard Time')) UpdateDateTimeUTC,
	    null CreditNoteDepartmentID,
	    null CreditNoteDepartmentName,
	    null CreditNoteDepartmentCode,
	    null JointVentureID
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
                [db-au-cmdwh].dbo.penPaymentRegisterTransaction pr
            where
                pr.PaymentRegisterTransactionKey = b.CountryKey + '-TA' + convert(varchar, b.RecordNo)
        )
        
end
GO
