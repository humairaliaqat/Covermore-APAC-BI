USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_penMonthlyStatement]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_penMonthlyStatement] 
as

declare @rptStartDate datetime
declare @rptEndDate datetime
declare @companyName varchar(255)
declare @companyABN varchar(50)

select
  @rptStartDate = '2012-02-01',
  @rptEndDate = '2012-02-29',
  @companyName = 'Cover-More Insurance Services',
  @companyABN = '95 003 114 145'

;with cte_policy as
(
  select
    po.AlphaCode,
    po.ABN,
    po.OutletName,
    po.ContactStreet + ' '+ po.ContactSuburb + ' ' + po.ContactState + ' ' + po.ContactPostCode ContactAddress,
    case
      when po.PaymentTypeID = 249	then 'Direct Debit'
      when po.PaymentTypeID = 250	then 'Direct Credit'
      when po.PaymentTypeID = 251	then 'Offset'
      when po.PaymentTypeID = 252	then 'No Commission'
      when po.PaymentTypeID = 253	then 'Staff Discount'
    end AccountType,
    pp.PolicyNumber,
    pp.ProductCode,
    pptv.FirstName + ' ' + pptv.LastName Customer,
    ppt.PolicyNumber TransactionNo,
    ppt.TransactionType,
    ppt.TransactionStatus,
    ppt.IssueDate,
    pu.FirstName + ' ' + pu.LastName Consultant,
    ppt.GrossPremium,
    ppt.Commission,
    ppt.TaxOnAgentCommissionGST,
    ppt.AdjustedNet NettPremium,
    case 
      when ppy.PaymentID is null then 'Non Credit Card' 
      else 'Credit Card' 
    end PaymentType,
    case 
      when ppt.PaymentDate is not null then 'Y'
      else 'N'
    end Paid
  from 
    penOutlet po
    inner join penPolicy pp on pp.OutletAlphaKey = po.OutletAlphaKey
    inner join penPolicyTransSummary ppt on 
      ppt.PolicyKey = pp.PolicyKey and
      ppt.TransactionType in ('Base', 'Extend', 'Variation', 'Partial Refund')
    left join penPayment ppy on ppy.PolicyTransactionKey = ppt.PolicyTransactionKey
    inner join penUser pu on pu.UserKey = ppt.UserKey
    left join penPolicyTraveller pptv on pptv.PolicyKey = pp.PolicyKey and pptv.isPrimary = 1
  where
    po.CountryKey = 'AU' and
    po.AlphaCode = 'GEN0427' and
    ppt.IssueDate >= @rptStartDate and
    ppt.IssueDate <  dateadd(day, 1, @rptEndDate)
    
  union

  select 
    po.AlphaCode,
    po.ABN,
    po.OutletName,
    po.ContactStreet + ' '+ po.ContactSuburb + ' ' + po.ContactState + ' ' + po.ContactPostCode ContactAddress,
    case
      when po.PaymentTypeID = 249	then 'Direct Debit'
      when po.PaymentTypeID = 250	then 'Direct Credit'
      when po.PaymentTypeID = 251	then 'Offset'
      when po.PaymentTypeID = 252	then 'No Commission'
      when po.PaymentTypeID = 253	then 'Staff Discount'
    end AccountType,
    pp.PolicyNumber,
    pp.ProductCode,
    pptv.FirstName + ' ' + pptv.LastName Customer,
    ppt.PolicyNumber TransactionNo,
    ppt.TransactionType,
    ppt.TransactionStatus,
    ppt.IssueDate,
    pu.FirstName + ' ' + pu.LastName Consultant,
    ppt.GrossPremium,
    ppt.Commission,
    ppt.TaxOnAgentCommissionGST,
    ppt.AdjustedNet NettPremium,
    case 
      when ppy.PaymentID is null then 'Non Credit Card' 
      else 'Credit Card' 
    end PaymentType,
    case 
      when ppt.PaymentDate is not null then 'Y'
      else 'N'
    end Paid
  from 
    penOutlet po
    inner join penPolicy pp on pp.OutletAlphaKey = po.OutletAlphaKey
    inner join penPolicyTransSummary ppt on 
      ppt.PolicyKey = pp.PolicyKey and
      ppt.TransactionType in ('Price Beat')
    left join penPayment ppy on ppy.PolicyTransactionKey = ppt.PolicyTransactionKey
    inner join penUser pu on pu.UserKey = ppt.UserKey
    left join penPolicyTraveller pptv on pptv.PolicyKey = pp.PolicyKey and pptv.isPrimary = 1
  where
    po.CountryKey = 'AU' and
    po.AlphaCode = 'GEN0427' and
    pp.IssueDate >= @rptStartDate and
    pp.IssueDate <  dateadd(day, 1, @rptEndDate)
)
select
  @companyName CompanyName,
  @companyABN CompanyABN,
  AlphaCode,
  ABN,
  OutletName,
  ContactAddress,
  AccountType,
  PolicyNumber, 
  ProductCode,
  Customer,
  TransactionNo, 
  case
    when TransactionStatus like 'Cancelled%' then TransactionType + ' Cancellation'
    else TransactionType
  end TransactionType,
  convert(datetime, convert(date, IssueDate)) IssueDate,
  Consultant, 
  GrossPremium, 
  Commission, 
  TaxOnAgentCommissionGST, 
  NettPremium,
  PaymentType,
  Paid,
  @rptStartDate StartDate,
  @rptEndDate EndDate
from cte_policy    
--where PolicyNumber = 60902210
order by
  PolicyNumber,
  case
    when TransactionType = 'Base' then 1
    when TransactionType = 'Price Beat' then 2
    when TransactionType = 'Variation' then 3
    when TransactionType = 'Extend' then 4
    when TransactionType = 'Partial Refund' then 5
    else 6
  end,
  TransactionType
GO
