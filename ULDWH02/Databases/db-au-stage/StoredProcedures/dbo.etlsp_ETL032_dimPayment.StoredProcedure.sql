USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimPayment]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_dimPayment]  
    @DateRange nvarchar(30),
    @StartDate nvarchar(10),
    @EndDate nvarchar(10)
    
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131114
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penCountry table available
Description:    dimPayment dimension table contains destination attributes.
Parameters:     @LoadType: Required. Value is Migration or Incremental
                @DateRange: Required. Standard date range value or _User Defined
                @StartDate: Optional. if _User Defined enter start date. Format: YYYY-MM-DD
                @EndDate: Optional. If _User Defined enter end date. Format: YYYY-MM-DD
Change History:
                20131114 - LT - Procedure created
                20140710 - PW - Null handling for BatchNo and removed Domain references
                20140714 - PW - Removed type 2 references
                20140725 - LT - Amended Merged statement
                20140905 - LS - refactoring
                20150204 - LS - replace batch codes with standard batch logging
				20190228 - RS - MerchangeID width changed from 20 to 40

*************************************************************************************************************************************/

--uncomment to debug
/*
declare @DateRange nvarchar(30)
declare @StartDate nvarchar(10)
declare @EndDate nvarchar(10)
select @DateRange = '_User Defined', @StartDate = '2011-07-01', @EndDate = '2014-06-30'
*/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @rptStartDate date,
        @rptEndDate date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    select
        @name = object_name(@@procid)

    begin try
    
        --check if this is running on batch

        exec syssp_getrunningbatch
            @SubjectArea = 'Policy Star',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Running'

        select 
            @rptStartDate = @start, 
            @rptEndDate = @end

    end try
    
    begin catch
    
        --or manually
    
        set @batchid = -1

        --get date range
        if @DateRange = '_User Defined'
            select 
                @rptStartDate = @StartDate, 
                @rptEndDate = @EndDate
        else
            select 
                @rptStartDate = StartDate,
                @rptEndDate = EndDate
            from 
                [db-au-cmdwh].dbo.vDateRange
            where 
                DateRange = @DateRange

    end catch


    --create dimCRMUser if table does not exist
    if object_id('[db-au-star].dbo.dimPayment') is null
    begin
    
        create table [db-au-star].dbo.dimPayment
        (
            PaymentSK int identity(1,1) not null,
            Country nvarchar(10) not null,
            PaymentKey nvarchar(50) not null,
            PolicyTransactionKey nvarchar(50) null,
            PaymentRefID nvarchar(50) null,
            OrderID nvarchar(50) null,
            [Status] nvarchar(100) null,
            PaymentAmount money null,
            ClientID int null,
            TransactionDate datetime null,
            TransactionDateUTC datetime null,
			MerchantID nvarchar(100) null,
            ReceiptNo nvarchar(50) null,
            ResponseDescription nvarchar(50) null,
            TransactionNo nvarchar(50) null,
            AuthoriseID nvarchar(50) null,
            CardType nvarchar(50) null,
            BatchNo nvarchar(20) null,
            PaymentGatewayID nvarchar(50) null,
            PaymentMerchantID int null,
            PaymentMethod nvarchar(50) null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null,
            HashKey varbinary(30) null
        )
        
        create clustered index idx_dimPayment_PaymentSK on [db-au-star].dbo.dimPayment(PaymentSK)
        create nonclustered index idx_dimPayment_PaymentKey on [db-au-star].dbo.dimPayment(PaymentKey)
        create nonclustered index idx_dimPayment_PolicyTransactionKey on [db-au-star].dbo.dimPayment (PolicyTransactionKey) include (PaymentSK,Country)
        create nonclustered index idx_dimPayment_Country on [db-au-star].dbo.dimPayment(Country)
        create nonclustered index idx_dimPayment_TransactionDate on [db-au-star].dbo.dimPayment(TransactionDate)
        create nonclustered index idx_dimPayment_PaymentMethod on [db-au-star].dbo.dimPayment(PaymentMethod)
        create nonclustered index idx_dimPayment_PaymentGatewayID on [db-au-star].dbo.dimPayment(PaymentGatewayID)
        create nonclustered index idx_dimPayment_HashKey on [db-au-star].dbo.dimPayment(HashKey)

        set identity_insert [db-au-star].dbo.dimPayment on

        --populate dimension with default unknown values
        insert [db-au-star].dbo.dimPayment
        (
            PaymentSK,
            Country,
            PaymentKey,
            PolicyTransactionKey,
            PaymentRefID,
            OrderID,
            [Status],
            PaymentAmount,
            ClientID,
            TransactionDate,
            TransactionDateUTC,
            MerchantID,
            ReceiptNo,
            ResponseDescription,
            TransactionNo,
            AuthoriseID,
            CardType,
            BatchNo,
            PaymentGatewayID,
            PaymentMerchantID,
            PaymentMethod,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            -1,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            0,
            0,
            null,
            null,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            0,
            'UNKNOWN',
            getdate(),
            null,
            @batchid,
            null,
            binary_checksum(-1, -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',    'UNKNOWN', 0, 0, null, null, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 0, 'UNKNOWN')
        )

        set identity_insert [db-au-star].dbo.dimPayment off
        
    end


    if object_id('[db-au-stage].dbo.etl_dimPayment') is not null 
        drop table [db-au-stage].dbo.etl_dimPayment
        
    select
        p.PaymentKey,
        isnull(d.CountryCode,'UNKNOWN') as Country,
        p.PolicyTransactionKey,
        p.PaymentRefID,
        p.OrderID,
        p.[Status],
        p.Total as PaymentAmount,
        p.ClientID,
        p.TransTime as TransactionDate,
        p.TransTimeUTC as TransactionDateUTC,
        p.MerchantID,
        p.ReceiptNo,
        p.ResponseDescription,
        p.TransactionNo,
        p.AuthoriseID,
        p.CardType,
        isnull(p.BatchNo,'') BatchNo,
        p.PaymentGatewayID,
        p.PaymentMerchantID,
        case 
            when p.PaymentGatewayID = 'Paypal' then 'Credit Card'
            when p.CardType in ('Visa','Mastercard','Amex') then 'Credit Card'
            else 'Non Credit Card'
        end as PaymentMethod,
        convert(datetime,null) as LoadDate,
        convert(datetime,null) as updateDate,
        convert(int,null) as LoadID,
        convert(int,null) as updateID,
        convert(varbinary,null) as HashKey
    into [db-au-stage].dbo.etl_dimPayment
    from
        [db-au-cmdwh].dbo.penPayment p
        left join [db-au-star].dbo.dimDomain d on
            p.DomainID = d.DomainID
    where
        TransTime >= @rptStartDate and
        TransTime <  dateadd(d,1,@rptEndDate)


    --Update HashKey value
    update [db-au-stage].dbo.etl_dimPayment
    set 
        HashKey = 
            binary_checksum(
                Country, 
                PaymentKey, 
                PolicyTransactionKey, 
                PaymentRefID, 
                OrderID, 
                [Status], 
                PaymentAmount, 
                ClientID,
                TransactionDate, 
                TransactionDateUTC, 
                MerchantID, 
                ReceiptNo, 
                ResponseDescription, 
                TransactionNo,
                AuthoriseID, 
                CardType, 
                BatchNo, 
                PaymentGatewayID, 
                PaymentMerchantID, 
                PaymentMethod
            )


    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_dimPayment

    begin transaction
    begin try

        -- Merge statement
        merge into [db-au-star].dbo.dimPayment as DST
        using [db-au-stage].dbo.etl_dimPayment as SRC
        on (src.PaymentKey = DST.PaymentKey)

        -- inserting new records
        when not matched by target then
        insert
        (
            Country,
            PaymentKey,
            PolicyTransactionKey,
            PaymentRefID,
            OrderID,
            [Status],
            PaymentAmount,
            ClientID,
            TransactionDate,
            TransactionDateUTC,
            MerchantID,
            ReceiptNo,
            ResponseDescription,
            TransactionNo,
            AuthoriseID,
            CardType,
            BatchNo,
            PaymentGatewayID,
            PaymentMerchantID,
            PaymentMethod,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            SRC.Country,
            SRC.PaymentKey,
            SRC.PolicyTransactionKey,
            SRC.PaymentRefID,
            SRC.OrderID,
            SRC.[Status],
            SRC.PaymentAmount,
            SRC.ClientID,
            SRC.TransactionDate,
            SRC.TransactionDateUTC,
            SRC.MerchantID,
            SRC.ReceiptNo,
            SRC.ResponseDescription,
            SRC.TransactionNo,
            SRC.AuthoriseID,
            SRC.CardType,
            SRC.BatchNo,
            SRC.PaymentGatewayID,
            SRC.PaymentMerchantID,
            SRC.PaymentMethod,
            getdate(),
            null,
            @batchid,
            null,
            SRC.HashKey
        )
        
        -- update existing records where data has changed via HashKey
        when matched and SRC.HashKey <> DST.HashKey then
        update
        SET
            DST.PaymentKey = SRC.PaymentKey,
            DST.Country = SRC.Country,
            DST.PolicyTransactionKey = SRC.PolicyTransactionKey,
            DST.PaymentRefID = SRC.PaymentRefID,
            DST.OrderID = SRC.OrderID,
            DST.[Status] = SRC.[Status],
            DST.PaymentAmount = SRC.PaymentAmount,
            DST.ClientID = SRC.ClientID,
            DST.TransactionDate = SRC.TransactionDate,
            DST.TransactionDateUTC = SRC.TransactionDateUTC,
            DST.MerchantID = SRC.MerchantID,
            DST.ReceiptNo = SRC.ReceiptNo,
            DST.ResponseDescription = SRC.ResponseDescription,
            DST.TransactionNo = SRC.TransactionNo,
            DST.AuthoriseID = SRC.AuthoriseID,
            DST.CardType = SRC.CardType,
            DST.BatchNo = SRC.BatchNo,
            DST.PaymentGatewayID = SRC.PaymentGatewayID,
            DST.PaymentMerchantID = SRC.PaymentMerchantID,
            DST.PaymentMethod = SRC.PaymentMethod,
            DST.HashKey = SRC.HashKey,
            DST.UpdateDate = getdate(),
            DST.UpdateID = @batchid
            
        output $action into @mergeoutput;

        select
            @insertcount =
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount =
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
        from
            @mergeoutput

        if @batchid <> -1
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

        if @batchid <> -1
            exec syssp_genericerrorhandler
                @SourceInfo = 'data refresh failed',
                @LogToTable = 1,
                @ErrorCode = '-100',
                @BatchID = @batchid,
                @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
