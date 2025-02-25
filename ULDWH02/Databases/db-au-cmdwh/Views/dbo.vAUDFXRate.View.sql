USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vAUDFXRate]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vAUDFXRate] as
select 
    convert(date, AuditDateTime) FXDate,
    CurrencyCode,
    min(Rate) minRate,
    max(Rate) maxRate,
    avg(Rate) AvgRate,
    count(*) RecordCount
from
    clmAuditPayment t
    outer apply
    (
        select top 1 
            Rate PreviousRate
        from
            clmAuditPayment r
        where
            r.PaymentKey = t.PaymentKey
        order by
            r.AuditDateTime desc
    ) r
where
    CountryKey = 'AU' and
    ModifiedDate is not null and
    paymentstatus in ('APPR', 'PAID') and
    isnull(r.PreviousRate, t.Rate) <> t.Rate
group by
    convert(date, AuditDateTime),
    CurrencyCode
GO
