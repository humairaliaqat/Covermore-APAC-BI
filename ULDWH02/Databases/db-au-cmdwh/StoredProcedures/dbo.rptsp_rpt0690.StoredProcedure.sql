USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0690]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0690]	@Country varchar(3),
									@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0960
--  Author:         Linus Tor
--  Date Created:   20180111
--  Description:    This stored procedure returns policy sales for Virgin AU and NZ
--
--  Change History:
--                  20180111 - LT - Created
--					20180508 - LT - Added MemberNumber column to output (Velocity Number)
/****************************************************************************************************/

--uncoment to debug
--declare
--    @Country varchar(2),
--    @DateRange varchar(39),
--    @StartDate datetime,
--    @EndDate datetime
--select @Country = 'AU', @DateRange = 'Last Month', @StartDate = null, @EndDate = null



declare @rptStartDate date
declare @rptEndDate date

--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from vDateRange
	where DateRange = @DateRange


SELECT
  penPolicy.PolicyNumber,
  penPolicyTransSummary.PolicyNumber as TransactionNumber,
  penPolicyTransSummary.TransactionType,
  penPolicyTransSummary.TransactionStatus,
  penPolicyTransSummary.IssueDate as TransactionDate,
  sum(penPolicyTransSummary.GrossPremium) as SellPrice,
  penOutlet.SubGroupName as SalesChannel,
  penOutlet.AlphaCode,
  penPolicyTransSummary.ProductCode,
  penPolicy.PlanDisplayName as [Plan],
  penPolicyTraveller.MemberNumber
FROM
  penPolicy INNER JOIN penPolicyTransSummary ON (penPolicyTransSummary.PolicyKey=penPolicy.PolicyKey)
  inner join penPolicyTraveller ON (penPolicy.PolicyKey = penPolicyTraveller.PolicyKey and penPolicyTraveller.isPrimary=1)
   INNER JOIN penOutlet ON (penPolicyTransSummary.OutletAlphaKey=penOutlet.OutletAlphaKey)
   INNER JOIN Calendar ON ((
    'Posting Date' = 'Issue Date' and
    penPolicyTransSummary.IssueDate = Calendar.Date
) or
(
    'Posting Date' = 'Posting Date' and
    penPolicyTransSummary.PostingDate = Calendar.Date
))
  
WHERE
  (
   penOutlet.CountryKey = @Country
   AND
   penOutlet.SuperGroupName  = 'Virgin'
   AND
   Calendar.Date  >=  @rptStartDate 
   AND
   Calendar.Date  <=  @rptEndDate
   AND
   ( penOutlet.OutletStatus = 'Current'  )
  )
GROUP BY
  penPolicy.PolicyNumber,
  penPolicyTransSummary.PolicyNumber,
  penPolicyTransSummary.TransactionType,
  penPolicyTransSummary.TransactionStatus,
  penPolicyTransSummary.IssueDate,
  penOutlet.SubGroupName,
  penOutlet.AlphaCode,
  penPolicyTransSummary.ProductCode,
  penPolicy.PlanDisplayName,
  penPolicyTraveller.MemberNumber

GO
