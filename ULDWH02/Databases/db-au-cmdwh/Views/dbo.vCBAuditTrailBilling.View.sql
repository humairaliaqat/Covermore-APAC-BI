USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCBAuditTrailBilling]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vCBAuditTrailBilling] as
with 
cte_newvalue as
(
    select 
        BIRowID,
        convert(nvarchar(1024), BillingType) [Billing Type],
        convert(nvarchar(1024), InvoiceNo) [Invoice Number],
        convert(nvarchar(1024), InvoiceDate, 120) [Invoice Date],
        convert(nvarchar(1024), BillItem) [Item],
        convert(nvarchar(1024), convert(varchar(8000), decryptbykeyautocert(cert_id('EMCCertificate'), null, Provider, 0, null))) [Provider],
        convert(nvarchar(1024), Details) [Details],
        convert(nvarchar(1024), PaymentBy) [Pay By],
        convert(nvarchar(1024), PaymentDate, 120) [Paid Date],
        convert(nvarchar(1024), LocalCurrency) [Local Currency],
        convert(nvarchar(1024), LocalInvoice) [Amount],
        convert(nvarchar(1024), ExchangeRate) [Exchange Rate],
        convert(nvarchar(1024), AUDInvoice) [Amount (AUD)],
        convert(nvarchar(1024), AUDGST) [GST (AUD)],
        convert(nvarchar(1024), CostContainmentAgent) [Cost Cont Agent],
        convert(nvarchar(1024), BackFrontEnd) [Backend /Frontend],
        convert(nvarchar(1024), CCInvoiceAmount) [Invoice Amount],
        convert(nvarchar(1024), CCSaving) [Saving],
        convert(nvarchar(1024), CCDiscountedInvoice) [Discounted Invoice],
        convert(nvarchar(1024), CustomerPayment) [Customer Payment],
        convert(nvarchar(1024), ClientPayment) [Client Payment Made],
        convert(nvarchar(1024), PPOFee) [PPO Fee],
        convert(nvarchar(1024), TotalDueCCAgent) [Total Due to CC Agent],
        convert(nvarchar(1024), CCFee) [Cust Care Cont Fee]
    from
        vcbAuditBilling
    where
        AuditAction <> 'Delete'
),
cte_newunpivot as
(
    select 
        BIRowID,
        ColumnName,
        NewValue
    from
        cte_newvalue
        unpivot
        (
            NewValue for ColumnName in 
            (
                [Billing Type],
                [Invoice Number],
                [Invoice Date],
                [Item],
                [Provider],
                [Details],
                [Pay By],
                [Paid Date],
                [Local Currency],
                [Amount],
                [Exchange Rate],
                [Amount (AUD)],
                [GST (AUD)],
                [Cost Cont Agent],
                [Backend /Frontend],
                [Invoice Amount],
                [Saving],
                [Discounted Invoice],
                [Customer Payment],
                [Client Payment Made],
                [PPO Fee],
                [Total Due to CC Agent],
                [Cust Care Cont Fee]
            )
        ) c
),
cte_oldvalue as
(
    select 
        BIRowID,
        convert(nvarchar(1024), OldBillingType) [Billing Type],
        convert(nvarchar(1024), OldInvoiceNo) [Invoice Number],
        convert(nvarchar(1024), OldInvoiceDate, 120) [Invoice Date],
        convert(nvarchar(1024), OldBillItem) [Item],
        convert(nvarchar(1024), convert(varchar(8000), decryptbykeyautocert(cert_id('EMCCertificate'), null, OldProvider, 0, null))) [Provider],
        convert(nvarchar(1024), OldDetails) [Details],
        convert(nvarchar(1024), OldPaymentBy) [Pay By],
        convert(nvarchar(1024), OldPaymentDate, 120) [Paid Date],
        convert(nvarchar(1024), OldLocalCurrency) [Local Currency],
        convert(nvarchar(1024), OldLocalInvoice) [Amount],
        convert(nvarchar(1024), OldExchangeRate) [Exchange Rate],
        convert(nvarchar(1024), OldAUDInvoice) [Amount (AUD)],
        convert(nvarchar(1024), OldAUDGST) [GST (AUD)],
        convert(nvarchar(1024), OldCostContainmentAgent) [Cost Cont Agent],
        convert(nvarchar(1024), OldBackFrontEnd) [Backend /Frontend],
        convert(nvarchar(1024), OldCCInvoiceAmount) [Invoice Amount],
        convert(nvarchar(1024), OldCCSaving) [Saving],
        convert(nvarchar(1024), OldCCDiscountedInvoice) [Discounted Invoice],
        convert(nvarchar(1024), OldCustomerPayment) [Customer Payment],
        convert(nvarchar(1024), OldClientPayment) [Client Payment Made],
        convert(nvarchar(1024), OldPPOFee) [PPO Fee],
        convert(nvarchar(1024), OldTotalDueCCAgent) [Total Due to CC Agent],
        convert(nvarchar(1024), OldCCFee) [Cust Care Cont Fee]
    from
        vcbAuditBilling
),
cte_oldunpivot as
(
    select 
        BIRowID,
        ColumnName,
        OldValue
    from
        cte_oldvalue
        unpivot
        (
            OldValue for ColumnName in 
            (
                [Billing Type],
                [Invoice Number],
                [Invoice Date],
                [Item],
                [Provider],
                [Details],
                [Pay By],
                [Paid Date],
                [Local Currency],
                [Amount],
                [Exchange Rate],
                [Amount (AUD)],
                [GST (AUD)],
                [Cost Cont Agent],
                [Backend /Frontend],
                [Invoice Amount],
                [Saving],
                [Discounted Invoice],
                [Customer Payment],
                [Client Payment Made],
                [PPO Fee],
                [Total Due to CC Agent],
                [Cust Care Cont Fee]
            )
        ) c    
)
select 
    BillingKey,
    AuditDateTime,
    AuditDateTimeUTC,
    AuditAction,
    AuditUser,
    BillingId,
    o.BIRowID,
    o.ColumnName,
    isnull(NewValue, '') NewValue,
    OldValue,
    case
        when isnull(NewValue, 'null') <> OldValue then 'Yes'
        else 'No'
    end Changed
from
    cte_oldunpivot o
    left join cte_newunpivot n on
        o.BIRowID = n.BIRowID and
        o.ColumnName = n.ColumnName
    inner join vcbAuditBilling cab on
        cab.BIRowID = o.BIRowID
        
        
GO
