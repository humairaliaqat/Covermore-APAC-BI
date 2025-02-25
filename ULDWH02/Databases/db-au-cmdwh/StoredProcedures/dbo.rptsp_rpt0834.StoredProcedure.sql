USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0834]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0834]
	@ReportingPeriod varchar(30) = 'Yesterday',
    @StartDate date = null,
    @EndDate date = null,
    @Country varchar(2) = 'AU'

AS
BEGIN

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0834
--  Author:         Ryan Lee
--  Date Created:   20161125
--  Description:    This stored procedure produces details of EMC assessments that match the criterias
--					required by Jenny Edwards on 20161120
--					TFS 28518
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  @Country (AU, NZ)
--  Change History: 
--                  20161125 - RL - Created
--
/****************************************************************************************************/

SET NOCOUNT ON


-- Creating agency email list
IF OBJECT_ID('tempdb..#temp_cte_RL') IS NOT NULL DROP TABLE #temp_cte_RL
	SELECT DISTINCT tpoe.Email INTO #temp_cte_RL FROM (
	SELECT poe.ContactEmail AS Email FROM dbo.penOutlet poe
	UNION SELECT poe.ContactManagerEmail AS Email FROM dbo.penOutlet poe
	UNION SELECT poe.GroupEmail AS Email FROM dbo.penOutlet poe
	UNION SELECT poe.SubGroupEmail AS Email FROM dbo.penOutlet poe
	UNION SELECT poe.AcctOfficerEmail AS Email FROM dbo.penOutlet poe
	UNION SELECT poe.AccountsEmail AS Email FROM dbo.penOutlet poe) tpoe
	CREATE INDEX index_ContactEmail ON #temp_cte_RL ([Email])



--DECLARE @ReportingPeriod varchar(30)
--DECLARE @StartDate date
--DECLARE @EndDate date
--DECLARE @Country varchar(2)

--SELECT @ReportingPeriod = '_User Defined'
--SELECT @StartDate = '2016-12-01'
--SELECT @EndDate = '2016-12-30'
--SELECT @Country = 'AU'

DECLARE @rptStartDate datetime
DECLARE @rptEndDate datetime

IF @ReportingPeriod = '_User Defined'
	SELECT @rptStartDate = @StartDate, @rptEndDate = @EndDate
	ELSE SELECT @rptStartDate = StartDate, @rptEndDate = EndDate
	FROM vDateRange
	WHERE DateRange = @ReportingPeriod


SELECT po.CountryKey AS Domain
, po.CompanyKey AS Company
, po.SuperGroupName, po.GroupCode, po.GroupName, po.SubGroupCode, po.SubGroupName
, po.Channel
, pp.AlphaCode, po.OutletName
, po.ContactPhone AS AgencyPhone
, po.ContactEmail AS AgencyEmail
, csr.FirstName AS ConsultantFirstName, csr.LastName AS ConsultantLastName
, csr.Email AS ConsultantEmail
, pp.PolicyNumber, pp.AreaName, pp.PrimaryCountry, pp.ProductDisplayName, pp.PurchasePath
, prem.SellPrice, prem.AgentRevenue, prem.NetPayable
, ptvct.TravellerCount
, DATEADD(dd, DATEDIFF(dd, 0, pp.IssueDate), 0) AS IssueDateOnly
, pp.TripStart, pp.TripEnd, pp.TripDuration, DATEDIFF(dd, GETDATE(), pp.TripStart) AS DaysBeforeDeparture
, ptv.Title AS rcpTitle, ptv.FirstName AS rcpFirstName, ptv.LastName AS rcpLastName, ptv.DisplayName AS rcpDisplayName
, ptv.DOB AS rcpDOB
, DATEDIFF(yy, ptv.DOB, pp.IssueDate) AS rcpAgeWhenPurchasing
, CASE WHEN ptv.isPrimary = 1 THEN 'Primary Taveller' ELSE 'Secondary Traveller' END AS rcpIsPrimary
, emc.EMCRef AS rcpEMCRef, emc.CreateDateOnly AS rcpEMCCreateDate
, pc.Title AS contactTitle, pc.FirstName AS contactFirstName, pc.LastName AS contactLastName, pc.DisplayName AS contactDisplayName
, pc.EmailAddress AS contactEmail
, CASE WHEN cte.Email IS NOT NULL THEN 'AgencyEmail'
	WHEN ltrim(rtrim(pc.EmailAddress)) = '' OR pc.EmailAddress IS NULL THEN 'NoEmail'
	WHEN pc.EmailAddress like '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%' THEN 'CustomerEmail'
	ELSE 'InvalidEmail' END AS contactEmailValidator
, pc.AddressLine1 AS contactAddressLine1
, pc.AddressLine2 AS contactAddressLine2
, pc.Suburb AS contactSuburb
, pc.[State] AS contactState
, pc.Country AS contactCountry
, pc.PostCode AS contactPostCode
, CASE WHEN pc.Country in ('Australia', 'New Zealand') 
	AND len(pc.Suburb) > 2 
	AND len(pc.AddressLine1) > 5 
	AND len(pc.PostCode) = 4 THEN 'GoodAddress' 
	ELSE 'IncompleteAddress' end AS contactAddressValidator
, pc.HomePhone AS contactHomePhone
, pc.WorkPhone AS contactWorkPhone
, pc.MobilePhone AS contactMobilePhone
, pc.OptFurtherContact, pc.MarketingConsent, pp.EmailConsent
, pp.PolicyKey, ptv.PolicyTravellerKey
, CASE WHEN pc.EmailAddress like '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%' AND cte.Email IS NULL THEN 'EDM'
	WHEN pc.Country in ('Australia', 'New Zealand') 
	AND len(pc.Suburb) > 2 
	AND len(pc.AddressLine1) > 5 
	AND len(pc.PostCode) = 4 THEN 'DM' 
	ELSE 'Other' END AS CampaignGroup
, @rptStartDate as ReportingFromDate
, @rptEndDate as ReportingToDate
, GETDATE() as ReportingRunDate

, CASE WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('AH', 'IH') THEN 'AHM'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('AZ') THEN 'Air New Zealand'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('AP') THEN 'Australia Post'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('HH') THEN 'HIF'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('MB') THEN 'Medibank'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('NI') THEN 'NRMA'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('SE') THEN 'SGIC'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('SO') THEN 'SGIO'
	WHEN po.CountryKey = 'AU' AND po.GroupCode IN ('AA', 'AE', 'AR', 'AV', 'CG', 'CM', 'CM', 'CR', 'CT', 'FL', 'HA', 'HF', 'HI', 'HL', 'HP', 'HW', 'IU', 'JT', 'PO', 'ST', 'TI', 'TT', 'TW', 'XA', 'YG', 'ZA') THEN 'CoverMore'
	WHEN po.CountryKey = 'NZ' AND po.GroupCode IN ('AZ') THEN 'Air New Zealand'
	WHEN po.CountryKey = 'NZ' AND po.GroupCode IN ('AM') THEN 'AMI'
	WHEN po.CountryKey = 'NZ' AND po.GroupCode IN ('SA') THEN 'State'
	WHEN po.CountryKey = 'NZ' AND po.GroupCode IN ('WP') THEN 'Westpac'
	WHEN po.CountryKey = 'NZ' AND po.GroupCode IN ('AA', 'AR', 'AT', 'BK', 'CB', 'CR', 'FA', 'FL', 'FM', 'GH', 'GO', 'HS', 'HW', 'PO', 'ST', 'TM', 'TS','UT', 'VL', 'WA', 'WT') THEN 'CoverMore'
	ELSE 'DoNotSend' END AS Brand

FROM dbo.penPolicy pp
INNER JOIN dbo.penPolicyTraveller ptv ON ptv.PolicyKey = pp.PolicyKey
INNER JOIN dbo.penOutlet po ON po.OutletAlphaKey = pp.OutletAlphaKey AND po.OutletStatus = 'Current'
OUTER APPLY (
	SELECT top 1 pe.EMCRef, ea.CreateDateOnly
	FROM dbo.penPolicyTransSummary pt
	INNER JOIN dbo.penPolicyTravellerTransaction ptvt ON ptvt.PolicyTransactionKey = pt.PolicyTransactionKey
	INNER JOIN dbo.penPolicyEMC pe ON pe.PolicyTravellerTransactionKey = ptvt.PolicyTravellerTransactionKey
	INNER JOIN dbo.emcApplications ea ON ea.ApplicationKey = pe.EMCApplicationKey
	WHERE ptvt.PolicyTravellerKey = ptv.PolicyTravellerKey AND pt.PolicyKey = pp.PolicyKey
	ORDER BY ea.ApplicationID desc
	) emc
OUTER APPLY (
	SELECT TOP 1 pu.FirstName, pu.LastName, pu.Email
	FROM dbo.penPolicyTransSummary ppts
	inner join dbo.penUser pu on pu.UserKey = ppts.UserKey and pu.UserStatus = 'Current'
	WHERE ppts.PolicyKey = pp.PolicyKey
	ORDER BY ppts.PolicyTransactionID
	) csr
OUTER APPLY (
	SELECT TOP 1 ppt.Title, ppt.FirstName, ppt.LastName, ppt.DisplayName
	, ppt.EmailAddress
	, ppt.AddressLine1, ppt.AddressLine2, ppt.Suburb, ppt.State, ppt.Country, ppt.PostCode
	, ppt.HomePhone, ppt.WorkPhone, ppt.MobilePhone
	, ppt.OptFurtherContact, ppt.MarketingConsent
	FROM dbo.penPolicyTraveller ppt
	WHERE ppt.PolicyKey = pp.PolicyKey
	AND ppt.isPrimary = 1
	) pc
OUTER APPLY (
	SELECT count(1) AS TravellerCount 
	FROM dbo.penPolicyTraveller ppt WHERE ppt.PolicyKey = pp.PolicyKey
	) ptvct
OUTER APPLY (
	SELECT sum(ppts.GrossPremium) AS SellPrice, sum(ppts.Commission) AS AgentRevenue, sum(ppts.AdjustedNet) AS NetPayable
	FROM dbo.penPolicyTransSummary ppts
	WHERE ppts.PolicyKey = pp.PolicyKey
	) prem
LEFT JOIN #temp_cte_RL cte ON cte.Email = pc.EmailAddress AND pc.EmailAddress <> ''
WHERE emc.EMCRef IS NULL
AND DATEDIFF(yy, ptv.DOB, pp.IssueDate) >= 75
AND pp.TripStart >= DATEADD(dd, 7, pp.IssueDate)	-- departure date is at least 7 days away from the issue date
AND pp.TripStart >= DATEADD(dd, 7, GETDATE())		-- departure date is at least 7 days away from the report run date (As per required, this may result in some data is filtered out by the report if the report is not run on daily basis)
AND pp.ProductCode <> 'CMB'							-- exclude business policies
AND pp.GroupName IS NULL							-- exclude group policies
AND pp.StatusCode = 1								-- exclude cancelled policies
AND po.Channel <> 'Integrated'						-- exclude integrated channel
AND pp.TripType = 'Single Trip'
AND ptv.isAdult = 1
AND DATEADD(dd, DATEDIFF(dd, 0, pp.IssueDate), 0) >= @rptStartDate				-- parameter start date
AND DATEADD(dd, DATEDIFF(dd, 0, pp.IssueDate), 0) < dateadd(day,1,@rptEndDate)	-- parameter end date
AND pp.CountryKey = @Country													-- parameter domain

END
GO
