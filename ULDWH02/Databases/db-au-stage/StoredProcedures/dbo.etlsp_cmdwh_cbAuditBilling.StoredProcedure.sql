USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbAuditBilling]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cbAuditBilling]
as
begin
/*
20131014, LS,   schema changes
20131121, LS,   remap columns
20140714, LS,   TFS12109
                cange Provider from encrypted to nvarchar
                remap BillItem to master data
20140715, LS,   use transaction (as carebase has intra-day refreshes)
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('[db-au-cmdwh].dbo.cbAuditBilling') is null
    begin

        create table [db-au-cmdwh].dbo.cbAuditBilling
        (
            [BIRowID] bigint not null identity(1,1),
            [AuditUser] nvarchar(255) null,
            [AuditDateTime] datetime null,
            [AuditDateTimeUTC] datetime null,
            [AuditAction] nvarchar(10) null,
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) not null,
            [BillingKey] nvarchar(20) not null,
            [AddressKey] nvarchar(20) null,
            [CaseNo] nvarchar(15) not null,
            [BillingID] int not null,
            [OpenDate] datetime null,
            [OpenTimeUTC] datetime null,
            [SentDate] datetime null,
            [SentTimeUTC] datetime null,
            [OpenedByID] nvarchar(30) null,
            [OpenedBy] nvarchar(55) null,
            [ProcessedBy] nvarchar(30) null,
            [BillingTypeCode] nvarchar(10) null,
            [BillingType] nvarchar(100) null,
            [InvoiceNo] nvarchar(50) null,
            [InvoiceDate] datetime null,
            [BillItem] nvarchar(20) null,
            [Provider] nvarchar(200) null,
            [Details] nvarchar(1500) null,
            [PaymentBy] nvarchar(50) null,
            [PaymentDate] datetime null,
            [LocalCurrencyCode] nvarchar(3) null,
            [LocalCurrency] nvarchar(20) null,
            [LocalInvoice] money null,
            [ExchangeRate] money null,
            [AUDInvoice] money null,
            [AUDGST] money null,
            [CostContainmentAgent] nvarchar(25) null,
            [BackFrontEnd] nvarchar(50) null,
            [CCInvoiceAmount] money null,
            [CCSaving] money null,
            [CCDiscountedInvoice] money null,
            [CustomerPayment] money null,
            [ClientPayment] money null,
            [PPOFee] money null,
            [TotalDueCCAgent] money null,
            [CCFee] money null,
            [isImported] bit null,
            [isDeleted] bit null
        )

        create clustered index idx_cbAuditBilling_BIRowID on [db-au-cmdwh].dbo.cbAuditBilling(BIRowID)
        create nonclustered index idx_cbAuditBilling_AuditDateTime on [db-au-cmdwh].dbo.cbAuditBilling(AuditDateTime)
        create nonclustered index idx_cbAuditBilling_BillingKey on [db-au-cmdwh].dbo.cbAuditBilling(BillingKey,AuditDateTime) include (AuditDateTimeUTC)
        create nonclustered index idx_cbAuditBilling_CaseKey on [db-au-cmdwh].dbo.cbAuditBilling(CaseKey,AuditDateTime)
        create nonclustered index idx_cbAuditBilling_CaseNo on [db-au-cmdwh].dbo.cbAuditBilling(CaseNo,CountryKey)

    end

    if object_id('tempdb..#cbAuditBilling') is not null
        drop table #cbAuditBilling

    select
        AUDIT_USERNAME AuditUser,
        dbo.xfn_ConvertUTCtoLocal(AUDIT_DATETIME, 'AUS Eastern Standard Time') AuditDateTime,
        AUDIT_DATETIME AuditDateTimeUTC,
        AUDIT_ACTION AuditAction,
        'AU' CountryKey,
        left('AU-' + bl.CASE_NO, 20) CaseKey,
        left('AU-' + convert(varchar, bl.ROWID), 20) BillingKey,
        left('AU-' + convert(varchar, Address_ID), 20) AddressKey,
        bl.CASE_NO CaseNo,
        bl.rowid BillingID,
        dbo.xfn_ConvertUTCtoLocal(OPEN_DATE, 'AUS Eastern Standard Time') OpenDate,
        OPEN_DATE OpenTimeUTC,
        dbo.xfn_ConvertUTCtoLocal(dep_date, 'AUS Eastern Standard Time') SentDate,
        dep_date SentTimeUTC,
        init_ac OpenedByID,
        OpenedBy,
        accauthby ProcessedBy,
        BillingTypeCode,
        BillingType,
        INVOICE_NO InvoiceNo,
        BILL_DATE InvoiceDate,
        isnull(bi.ITEM, bl.ITEM) BillItem,
        Provider,
        NOTES Details,
        PaymentBy,
        PFP_DATE PaymentDate,
        bl.CURRENCY LocalCurrencyCode,
        cr.DESCRIPT LocalCurrency,
        LOCAL_REV LocalInvoice,
        EXCHANGE ExchangeRate,
        AUD_REV AUDInvoice,
        AUD_GST AUDGST,
        PPO_NETWORK CostContainmentAgent,
        BACK_FRONT_END BackFrontEnd,
        LOCAL_ACT CCInvoiceAmount,
        NET_SAVING CCSaving,
        LOCAL_ACT - NET_SAVING CCDiscountedInvoice,
        CUST_PAYMENT CustomerPayment,
        CLIENT_PAYMENT ClientPayment,
        PPO_FEE PPOFee,
        LOCAL_REV TotalDueCCAgent,
        CCA_CCFEE CCFee,
        isImported,
        isDeleted
    into #cbAuditBilling
    from
        carebase_AUDIT_CBL_BILLING_aucm bl
        left join carebase_UCR_CURRENCY_aucm cr on
            cr.CURRENCY = bl.CURRENCY
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME OpenedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = bl.init_ac
        ) ob
        outer apply
        (
            select top 1
                bt.Code BillingTypeCode,
                bt.Description BillingType
            from
                carebase_tblBillingType_aucm bt
            where
                bt.BillingType_ID = bl.BillingType_ID
        ) bt
        outer apply
        (
            select top 1
                pb.Description PaymentBy
            from
                carebase_tblPaymentByDetails_aucm pb
            where
                pb.PaymentBy_ID = bl.PaymentBy_ID
        ) pb
        outer apply
        (
            select top 1
                ITEM
            from
                carebase_BILL_ITEMS_CV_aucm bi
            where
                bi.BILL_ITEM_ID = bl.BillingItem_ID
        ) bi


    begin transaction cbAuditBilling

    begin try

        delete bl
        from
            [db-au-cmdwh].dbo.cbAuditBilling bl
            inner join carebase_AUDIT_CBL_BILLING_aucm r on
                bl.BillingKey = left('AU-' + convert(varchar, r.ROWID), 20) collate database_default and
                bl.AuditDateTimeUTC = r.AUDIT_DATETIME

        insert into [db-au-cmdwh].dbo.cbAuditBilling with(tablock)
        (
            AuditUser,
            AuditDateTime,
            AuditDateTimeUTC,
            AuditAction,
            CountryKey,
            CaseKey,
            BillingKey,
            AddressKey,
            CaseNo,
            BillingID,
            OpenDate,
            OpenTimeUTC,
            SentDate,
            SentTimeUTC,
            OpenedByID,
            OpenedBy,
            ProcessedBy,
            BillingTypeCode,
            BillingType,
            InvoiceNo,
            InvoiceDate,
            BillItem,
            Provider,
            Details,
            PaymentBy,
            PaymentDate,
            LocalCurrencyCode,
            LocalCurrency,
            LocalInvoice,
            ExchangeRate,
            AUDInvoice,
            AUDGST,
            CostContainmentAgent,
            BackFrontEnd,
            CCInvoiceAmount,
            CCSaving,
            CCDiscountedInvoice,
            CustomerPayment,
            ClientPayment,
            PPOFee,
            TotalDueCCAgent,
            CCFee,
            isImported,
            isDeleted
        )
        select
            AuditUser,
            AuditDateTime,
            AuditDateTimeUTC,
            AuditAction,
            CountryKey,
            CaseKey,
            BillingKey,
            AddressKey,
            CaseNo,
            BillingID,
            OpenDate,
            OpenTimeUTC,
            SentDate,
            SentTimeUTC,
            OpenedByID,
            OpenedBy,
            ProcessedBy,
            BillingTypeCode,
            BillingType,
            InvoiceNo,
            InvoiceDate,
            BillItem,
            Provider,
            Details,
            PaymentBy,
            PaymentDate,
            LocalCurrencyCode,
            LocalCurrency,
            LocalInvoice,
            ExchangeRate,
            AUDInvoice,
            AUDGST,
            CostContainmentAgent,
            BackFrontEnd,
            CCInvoiceAmount,
            CCSaving,
            CCDiscountedInvoice,
            CustomerPayment,
            ClientPayment,
            PPOFee,
            TotalDueCCAgent,
            CCFee,
            isImported,
            isDeleted
        from
            #cbAuditBilling

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbAuditBilling

        exec syssp_genericerrorhandler 'cbAuditBilling data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbAuditBilling

end

GO
