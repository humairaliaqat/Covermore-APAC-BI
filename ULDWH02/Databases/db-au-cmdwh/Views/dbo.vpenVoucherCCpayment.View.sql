USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vpenVoucherCCpayment]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vpenVoucherCCpayment] AS

WITH a AS
(
SELECT v.*,pp.total,
       ROW_NUMBER() OVER (PARTITION BY pp.total,o.policynumber,o.issuedate ORDER BY v.Redemptiondate DESC) AS RN
FROM [dbo].[penVoucher] v
  join penpolicy o on v.PolicyNumber = o.PolicyNumber
  join penPolicyTransSummary pt on o.PolicyKey = pt.PolicyKey 
  join penpayment pp on pp.PolicyTransactionKey = pt.PolicyTransactionKey
where CAST(o.IssueDate AS DATE)>='2025-01-22'
--and o.PolicyNumber in ('725001452402')
)
SELECT a.DomainId,a.Partner, a.PolicyNumber,a.VoucherNumber,a.Total as 'Total Amount',  
case when a.VoucherType = 'Marketing' then redemptionvalue end 'Marketing',
case when a.VoucherType = 'Invoiceable' then redemptionvalue end 'Invoiceable',
a.RedemptionDate,a.StartDate,a.ExpiryDate,a.Status
FROM a 
WHERE RN=1

GO
