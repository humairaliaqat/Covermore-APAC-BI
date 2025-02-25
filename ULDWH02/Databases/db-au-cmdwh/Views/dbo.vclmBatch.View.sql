USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vclmBatch]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vclmBatch]
as
select
    case
        when pb.BatchStatus in ('CANB', 'PPCO', 'PROC', 'REJB') then 'Audit'
        else 'ChqRunext'
    end BatchType,
    pb.CountryKey,
    pb.PaymentBatchKey BatchKey,
    pb.PaymentID PayID,
    pb.ClaimKey,
    pb.PaymentBatchID BatchID,
    pb.ClaimNo,
    pb.PayeeID,
    pb.AccountID,
    pb.OfficerID,
    pb.BatchNo,
    pb.isDeleted,
    pb.isSullied,
    pb.Pseudo,
    pb.ChequeNo,
    pb.BillAmount,
    pb.CurrencyCode,
    pb.ForeignExchangeRate,
    pb.AUDAmount,
    pb.Excess,
    pb.DepreciationValue DEPV,
    pb.Other,
    pb.GST,
    pb.TotalValue Value,
    pb.PaymentModifiedDate ModifyDateTime,
    pb.PaymentMethod PayMethod,
    pb.AddresseeID,
    pb.StartClaimNo,
    pb.EndClaimNo,
    pb.StartAccountingPeriod,
    pb.EndAccountingPeriod,
    pb.PaymentDate PayDate,
    pb.AccountNo,
    pb.AccountName,
    pb.BSB,
    pb.isAuthorised,
    pb.AuthorisedValue,
    pb.BatchStatus,
    pb.ITCAdjustment ITCAdj,
    pb.AuthorisedDate,
    pb.AuthorisedOfficerID,
    pb.AuthorisedOfficerName,
    pb.SecondaryAuthorisedDate,
    pb.SecondaryAuthorisedOfficerID,
    pb.SecondaryAuthorisedOfficerName,
    cs.SectionDescription SectionDesc,
    pb.PaymentStatus PayStatus
from
    clmPaymentBatch pb
    left join clmPayment cp on 
        cp.CountryKey = pb.CountryKey and
        cp.PaymentID = pb.PaymentID
    left join clmSection cs on
        cs.SectionKey = cp.SectionKey

GO
