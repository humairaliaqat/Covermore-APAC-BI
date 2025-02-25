USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL037_Bank_Migration_Update_penPayment]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL037_Bank_Migration_Update_penPayment]
as

SET NOCOUNT ON

--20150129_LT: converted PolicyNo to varchar(50) to cater for China alpha numeric policy number

update pt
set
    PaymentDate = p.PaymentDate,
    PaymentDateUTC = dbo.xfn_ConvertLocaltoUTC(p.PaymentDate, d.TimeZoneCode),
    AllocationNumber = p.BankPaymentRecord
from
    [db-au-cmdwh].dbo.penPolicyTransSummary pt
    inner join [db-au-cmdwh].dbo.penDomain d on
        d.DomainKey = pt.DomainKey
    inner join [db-au-cmdwh].dbo.Policy p on
        convert(varchar(50),p.PolicyNo) = pt.PolicyNumber and
        p.CountryKey = pt.CountryKey
where
    pt.PaymentDate is null and
    p.PaymentDate is not null

GO
