USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0459_RecordCount]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0459_RecordCount]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt0459_recordCount
--  Author:         Saurabh Date
--  Date Created:   20190201
--  Description:    This stored procedure returns Medibank traveller record count for CRM Integration
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--   
--  Change History: 20190201 - SD - Created
/****************************************************************************************************/

--DECLARE
--	@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)
--SET @DateRange = 'Yesterday'

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
	count(distinct penPolicy.PolicyNumber) [Total records]
FROM
  penPolicyTraveller INNER JOIN penPolicy ON (penPolicy.PolicyKey=penPolicyTraveller.PolicyKey)
   INNER JOIN penPolicyTransSummary ON (penPolicyTransSummary.PolicyKey=penPolicy.PolicyKey)
   INNER JOIN penOutlet ON (penPolicyTransSummary.OutletAlphaKey=penOutlet.OutletAlphaKey)
   INNER JOIN vPenguinPolicyPremiums ON (vPenguinPolicyPremiums.PolicyTransactionKey=penPolicyTransSummary.PolicyTransactionKey)
  
WHERE
  (
   penPolicyTraveller.isPrimary  =  1
 --  AND
 --  case
 --   when isnull(penPolicyTraveller.MemberNumber, '') = '' then 0
 --   else 1
	--end   =  0
   AND
   penOutlet.GroupCode = 'MB'
   AND
   penPolicy.StatusDescription  IN  ( 'Active'  )
   AND
   penPolicyTransSummary.CountryKey  =  'AU'
   AND
   penPolicy.IssueDate  >= @rptStartDate and penPolicy.IssueDate < dateadd(day, 1, @rptEndDate)
   AND
   ( penOutlet.OutletStatus = 'Current'  )
  )
GO
