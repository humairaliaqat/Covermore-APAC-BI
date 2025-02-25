USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0459]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0459]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           rptsp_rpt0459
--  Author:         Saurabh Date
--  Date Created:   20181120
--  Description:    This stored procedure returns Medibank non-member travel details for CRM Integration
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2016-01-01
--   
--  Change History: 20181120 - SD - Created
--					20190131 - SD - Removed the non-member filter and changed the date format to dd.mm.yyyy
--					20190404 - SD - Added "Title" field, as requested by Michelle in JIRA REQ-848
--					20190405 - SD - Changed the date filter from Departure date to Policy Issued Date
--					20190429 - SD - Changed AREA_DEST field to show Destination, instead of Area.
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
	convert(varchar, penPolicy.PolicyNumber) [POLICY_NUMBER],
	'0' [Business Partner Number],
	penPolicyTraveller.Title [TITLE],
	penPolicyTraveller.FirstName [FIRST_NAME],
	'' [MIDDLE_NAME],
	penPolicyTraveller.LastName [LAST_NAME],
	convert(varchar, penPolicyTraveller.DOB, 104) [DOB],
	case
	  when ltrim(rtrim(penPolicyTraveller.AddressLine1)) <> '' then penPolicyTraveller.AddressLine1
	  else ''
	end [STREET1], 
	case
	  when ltrim(rtrim(penPolicyTraveller.AddressLine2)) <> '' then penPolicyTraveller.AddressLine2
	  else ''
	end [STREET2], 
	penPolicyTraveller.Suburb [SUBURB],
	penPolicyTraveller.State [STATE],
	penPolicyTraveller.PostCode [POSTCODE],
	penPolicyTransSummary.CountryKey [COUNTRY],
	penPolicyTraveller.EmailAddress [EMAIL],
	'AU' [COUNTRY_CODE_PHONE],
	penPolicyTraveller.HomePhone [PHONE_HOME],
	penPolicyTraveller.WorkPhone [PHONE_OFFICE],
	penPolicyTraveller.MobilePhone [PHONE_MOBILE],
	penPolicy.TripType [TRIP_TYPE],
	penPolicy.PrimaryCountry [AREA_DEST],
	convert(varchar, penPolicy.TripStart, 104) [DEPARTDATE],
	convert(varchar, penPolicy.TripEnd, 104) [RETURNDATE],
	sum(penPolicyTransSummary.AdultsCount) [ADULTCOUNT],
	sum(penPolicyTransSummary.ChildrenCount) [CHILDCOUNT],
	penPolicy.StatusDescription [POLICY_STATUS],
	sum(vPenguinPolicyPremiums."Sell Price") [PREMIUM],
	penPolicy.Excess [EXCESS],
	convert(varchar, penPolicy.IssueDate, 104) [START_DATE]
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
GROUP BY
	convert(varchar, penPolicy.PolicyNumber),
	penPolicyTraveller.Title,
	penPolicyTraveller.FirstName,
	penPolicyTraveller.LastName,
	convert(varchar,penPolicyTraveller.DOB,104),
	case
	  when ltrim(rtrim(penPolicyTraveller.AddressLine1)) <> '' then penPolicyTraveller.AddressLine1
	  else ''
	end, 
	case
	  when ltrim(rtrim(penPolicyTraveller.AddressLine2)) <> '' then penPolicyTraveller.AddressLine2
	  else ''
	end, 
	penPolicyTraveller.Suburb,
	penPolicyTraveller.State,
	penPolicyTraveller.PostCode,
	penPolicyTransSummary.CountryKey,
	penPolicyTraveller.EmailAddress,
	penPolicyTraveller.HomePhone,
	penPolicyTraveller.WorkPhone,
	penPolicyTraveller.MobilePhone,
	penPolicy.TripType,
	penPolicy.PrimaryCountry,
	convert(varchar, penPolicy.TripStart, 104),
	convert(varchar, penPolicy.TripEnd, 104),
	penPolicy.StatusDescription,
	penPolicy.Excess,
	convert(varchar, penPolicy.IssueDate, 104)
GO
