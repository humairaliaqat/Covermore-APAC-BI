USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0770]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0770]	@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0770
--  Author:         Linus Tor
--  Date Created:   20170119
--  Description:    This stored procedure produces sales data for Flight Center USA. 
--					Migrated from Universe to use UTC timezone datetime selection, and add UTC datetime columns
--  Parameters:     @DateRange: Required. Standard date range value or _User Defined
--                  @StartDate: Optional. Only required if _User Defined
--					@EndDate: Optional. Only required if _User Defined
--
--  Change History: 
--                  20170119 - LT - Created
--					20170602 - SD - Corrected bug on date selection, converted it to date format while comparing
--
/****************************************************************************************************/


--Uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


select
  penOutlet.CountryKey as Country,
  penOutlet.SuperGroupName as AgencySuperGroupName,
  penOutlet.SubGroupName as AgencySubGroupName,
  penOutlet.AlphaCode as AgencyCode,
  penOutlet.OutletName as AgencyName,
  penOutlet.ExtID as ExternalID,
  penPolicyTransSummary.PolicyNumber as PolicyNumber,
  penPolicy.PolicyNumber as ParentPolicyNumber,
  penPolicy.ProductCode,
  penPolicy.PlanDisplayName as [Plan],
  penPolicyTransSummary.TransactionType,
  penPolicy.IssueDateNoTime as ParentIssuedDate,
  penPolicy.IssueDateUTC as ParentIssuedDateUTC,
  penPolicyTransSummary.IssueTime as IssuedDate,
  penPolicyTransSummary.IssueTimeUTC as IssuedDateUTC,
  penUser.FirstName + ' ' + penUser.LastName as ConsultantName,
  penPolicy.AffiliateReference as AgentReference,
  penPolicyTransSummary.CurrencyCode,
  sum(vPenguinPolicyPremiums."Sell Price") as SellPrice,
  sum(penPolicyTransSummary.TravellersCount) as NumberOfTravellersCount,
  penOutlet.PaymentType as AccountCommissionType,
  penPolicyTraveller.Title,
  penPolicyTraveller.FirstName,
  penPolicyTraveller.LastName,
  penPolicyTransSummary.AllocationNumber as PaymentRecord,
  penPolicyTransSummary.TransactionStatus,
  @rptStartDate as rptStartDate,
  @rptEndDate as rptEndDate
FROM
  penUser RIGHT OUTER JOIN penPolicyTransSummary ON (penUser.UserKey=penPolicyTransSummary.UserKey and penUser.UserStatus = 'Current')
   INNER JOIN penPolicy ON (penPolicyTransSummary.PolicyKey=penPolicy.PolicyKey)
   INNER JOIN penPolicyTraveller ON (penPolicy.PolicyKey=penPolicyTraveller.PolicyKey)
   INNER JOIN penOutlet ON (penPolicyTransSummary.OutletAlphaKey=penOutlet.OutletAlphaKey)
   INNER JOIN penPolicyTransaction ON (penPolicyTransSummary.PolicyTransactionKey=penPolicyTransaction.PolicyTransactionKey)
   INNER JOIN vPenguinPolicyPremiums ON (vPenguinPolicyPremiums.PolicyTransactionKey=penPolicyTransSummary.PolicyTransactionKey)  
WHERE
  (
   penOutlet.CountryKey  IN  ( 'US'  )
   AND
   convert(date, penPolicyTransaction.TransactionDateTime) >= convert(date,dbo.xfn_ConvertLocaltoUTC(@rptStartDate,'Eastern Standard Time'))					--convert US Eastern Standard time to UTC
   AND
   convert(date,penPolicyTransaction.TransactionDateTime) < convert(date,dbo.xfn_ConvertLocaltoUTC(dateadd(d,1,@rptEndDate), 'Eastern Standard Time'))		--convert US Eastern Standard time to UTC
   AND
   penPolicyTraveller.isPrimary  =  1
   AND
   penOutlet.AlphaCode  NOT LIKE  '%TEST%'
   AND
   penOutlet.SuperGroupName  =  'Flight Center'
   AND
   ( isnull(penOutlet.OutletStatus, 'Current') = 'Current'  )
  )
GROUP BY
  penOutlet.CountryKey, 
  penOutlet.SuperGroupName, 
  penOutlet.SubGroupName, 
  penOutlet.AlphaCode, 
  penOutlet.OutletName, 
  penOutlet.ExtID, 
  penPolicyTransSummary.PolicyNumber, 
  penPolicy.PolicyNumber, 
  penPolicy.ProductCode, 
  penPolicy.PlanDisplayName, 
  penPolicyTransSummary.TransactionType, 
  penPolicy.IssueDateNoTime,
  penPolicy.IssueDateUTC,
  penPolicyTransSummary.IssueTime,
  penPolicyTransSummary.IssueTimeUTC,
  penUser.FirstName + ' ' + penUser.LastName, 
  penPolicy.AffiliateReference, 
  penPolicyTransSummary.CurrencyCode, 
  penOutlet.PaymentType, 
  penPolicyTraveller.Title, 
  penPolicyTraveller.FirstName, 
  penPolicyTraveller.LastName, 
  penPolicyTransSummary.AllocationNumber, 
  penPolicyTransSummary.TransactionStatus
GO
