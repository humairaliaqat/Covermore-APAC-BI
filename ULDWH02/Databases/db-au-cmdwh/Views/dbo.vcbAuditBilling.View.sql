USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vcbAuditBilling]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vcbAuditBilling] as
select 
    cab.BIRowID,
    BillingKey,
    AuditDateTime,
    AuditDateTimeUTC,
    case
        when AuditAction = 'D' then 'Delete'
        else 'Update'
    end AuditAction,
    cu.FirstName + ' ' + cu.Surname AuditUser,
    CaseNo,
    BillingID,
    cab.BillingType,
    cab.InvoiceNo,
    cab.InvoiceDate,
    cab.BillItem,
    cab.Provider,
    cab.Details,
    cab.PaymentBy,
    cab.PaymentDate,
    cab.LocalCurrency,
    cab.LocalInvoice,
    cab.ExchangeRate,
    cab.AUDInvoice,
    cab.AUDGST,
    cab.CostContainmentAgent,
    cab.BackFrontEnd,
    cab.CCInvoiceAmount,
    cab.CCSaving,
    cab.CCDiscountedInvoice,
    cab.CustomerPayment,
    cab.ClientPayment,
    cab.PPOFee,
    cab.TotalDueCCAgent,
    cab.CCFee,
    OldBillingType,
    OldInvoiceNo,
    OldInvoiceDate,
    OldBillItem,
    OldProvider,
    OldDetails,
    OldPaymentBy,
    OldPaymentDate,
    OldLocalCurrency,
    OldLocalInvoice,
    OldExchangeRate,
    OldAUDInvoice,
    OldAUDGST,
    OldCostContainmentAgent,
    OldBackFrontEnd,
    OldCCInvoiceAmount,
    OldCCSaving,
    OldCCDiscountedInvoice,
    OldCustomerPayment,
    OldClientPayment,
    OldPPOFee,
    OldTotalDueCCAgent,
    OldCCFee
from
    cbAuditBilling cab
    inner join cbUser cu on
        cu.UserID = cab.AuditUser
    outer apply
    (
        select top 1
            BillingType OldBillingType,
            InvoiceNo OldInvoiceNo,
            InvoiceDate OldInvoiceDate,
            BillItem OldBillItem,
            Provider OldProvider,
            Details OldDetails,
            PaymentBy OldPaymentBy,
            PaymentDate OldPaymentDate,
            LocalCurrency OldLocalCurrency,
            LocalInvoice OldLocalInvoice,
            ExchangeRate OldExchangeRate,
            AUDInvoice OldAUDInvoice,
            AUDGST OldAUDGST,
            CostContainmentAgent OldCostContainmentAgent,
            BackFrontEnd OldBackFrontEnd,
            CCInvoiceAmount OldCCInvoiceAmount,
            CCSaving OldCCSaving,
            CCDiscountedInvoice OldCCDiscountedInvoice,
            CustomerPayment OldCustomerPayment,
            ClientPayment OldClientPayment,
            PPOFee OldPPOFee,
            TotalDueCCAgent OldTotalDueCCAgent,
            CCFee OldCCFee
        from
            cbAuditBilling old
        where
            old.CaseKey = cab.CaseKey and
            old.AuditDateTime < cab.AuditDateTime
        order by
            old.AuditDateTime desc
    ) old
where
    AuditAction in ('U', 'D')
GO
