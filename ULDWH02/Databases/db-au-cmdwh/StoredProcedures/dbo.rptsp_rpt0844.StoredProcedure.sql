USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0844]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[rptsp_rpt0844]	@DateRange varchar(30) = 'Month-To-Date'
AS



/****************************************************************************************************/
--  Name			:	rptsp_rpt0844
--  Description		:	for RPT0844 - Flight Centre Kicker Earned
--  Author			:	Ryan Lee
--  Date Created	:	20170130
--  Description		:	This view captures flight centre policy and quote sales and apply kicker incentives
--						as defined by kicker definitions
--  Parameters		:	@DateRange: Month-To-Date, Last Month, or Last 2 Months
--  Change History	:	20170322 - RL - update calculations
--                      20170320 - RL - adding more niche brands with additional calculations/tabs
--	                    20170208 - RL - new report was created based on the RPT0596
--                      20170705 - LL - why limit the date options?
--						20170816 - SD - Added 'SA' and 'WANT' into nations filter
--						20170818 - SD - Added SellPriceLY120, also corrected of LY to be LY Same reporting period details and calculations
--						20170829 - SD - Changed Kicker calculations as requested by SImon McNally, INC0042906
--						20170830 - SD - Added Head Office nation stores as Flight Centre stores, requested by Simon McNally
--						20170906 - SD - Changed Kicker calculations for <12 months stores, also added LY End of month calculations
--						20170907 - SD - Changed Kicker earned to be based on Total Sales (PY i.e. LYEOM Sell price
--						20171120 - SD - Included products FYE and FYP into Flight Centre
--						20180405 - SD - Incorporated Latest outlet lineage
/****************************************************************************************************/



SET NOCOUNT ON

-- uncomments to debug
-- DECLARE @DateRange varchar(30)
-- SELECT @DateRange = 'Month-To-Date'
-- uncomments to debug


DECLARE @rptStartDate datetime
DECLARE @rptEndDate datetime
DECLARE @rptStartDateLY datetime
DECLARE @rptEndDateLY datetime
DECLARE @rptStartDateLYEOM datetime
DECLARE @rptEndDateLYEOM datetime


	SELECT @rptStartDate = StartDate, @rptEndDate = EndDate
	FROM dbo.vDateRange
	WHERE DateRange = @DateRange

	SELECT @rptStartDateLY = DATEADD(year,-1,@rptStartDate)
	, @rptEndDateLY = DATEADD(year,-1,@rptEndDate)

	SELECT @rptStartDateLYEOM = DATEADD(year,-1,@rptStartDate)
	, @rptEndDateLYEOM = EOMONTH(DATEADD(year,-1,CONVERT(datetime,CONVERT(varchar(8),@rptStartDate,120)+'01')))


-- All current AU FL AphaCodes, and their previous alphas
IF OBJECT_ID('tempdb..#AlphaCode') IS NOT NULL DROP TABLE #AlphaCode
SELECT distinct
	o.OutletAlphaKey
	, o.LatestOutletKey
	, lo.TradingStatus
	, lo.FCNation
	, lo.BDMName
	, lo.AlphaCode
	, lo.OutletName
	, lo.CountryKey
	, lo.FCArea
	, lo.FCAreaCode
	, lo.CommencementDate
	, lo.CloseDate
	, lo.PreviousAlpha
	, lo.OutletType
	, lo.GroupCode
	, lo.TradingAge
	, lo.OutletKey
	, lo.OutletStatus
INTO 
	#AlphaCode
FROM 
	dbo.penOutlet o
	outer apply
	(
		Select
			Top 1
			TradingStatus
			, FCNation
			, BDMName
			, AlphaCode
			, OutletName
			, CountryKey
			, FCArea
			, FCAreaCode
			, CommencementDate
			, CloseDate
			, PreviousAlpha
			, OutletType
			, GroupCode
			, OutletAlphaKey
			, CASE 
				WHEN DATEDIFF(month, o.CommencementDate,@rptEndDate) <= 6 THEN '1-6months'
				WHEN DATEDIFF(month, o.CommencementDate,@rptEndDate) BETWEEN 7 AND 12 THEN '7-12mths'
				ELSE '>12mths'
			  END AS TradingAge
			, OutletKey
			, lo.OutletStatus
		From
			penOutlet lo
		Where
			lo.outletKey = o.LatestOutletKey
			AND lo.OutletStatus = 'Current'
			AND lo.CountryKey = 'AU'
			AND lo.CompanyKey = 'CM'
			AND lo.GroupCode = 'FL'
	) lo
WHERE 
	o.OutletStatus = 'Current'
	AND o.LatestOutletKey IN (
								SELECT 
									po.LatestOutletKey
								FROM 
									dbo.penOutlet po
								WHERE 
									po.OutletStatus = 'Current'
									AND po.CountryKey = 'AU'
									AND po.CompanyKey = 'CM'
									AND po.GroupCode = 'FL'
									AND po.OutletKey = po.LatestOutletKey)


-- ConsultantCount of latest outlet
IF OBJECT_ID('tempdb..#Consultant') IS NOT NULL DROP TABLE #Consultant
SELECT 
	o.OutletAlphaKey
	, o.LatestOutletKey
	, o.TradingStatus
	, COUNT(DISTINCT CASE WHEN pts.TransactionType = 'Base' AND pts.TransactionStatus = 'Active' AND u.ConsultantType = 'External' THEN pts.UserKey ELSE NULL END) AS ConsultantCount
INTO 
	#Consultant
FROM 
	dbo.penPolicyTransSummary pts
	INNER JOIN dbo.penPolicy p ON p.PolicyKey = pts.PolicyKey
	INNER JOIN #AlphaCode o ON o.OutletAlphaKey = p.OutletAlphaKey
	INNER JOIN dbo.penUser u ON u.UserKey = pts.UserKey AND u.UserStatus = 'Current'
WHERE 
	o.LatestOutletKey in (select LatestOutletKey from #AlphaCode)
	AND pts.PostingDate BETWEEN @rptStartDate AND @rptEndDate
GROUP BY 
	o.OutletAlphaKey
	, o.LatestOutletKey
	, o.TradingStatus


-- Base table on product code level, inlcude both Current and LY reporting period, and all brands
-- For data validation, to be compared with policy cube
IF OBJECT_ID('tempdb..#BaseTable') IS NOT NULL DROP TABLE #BaseTable
SELECT 
	o.LatestOutletKey
	, o.FCNation
	, p.ProductCode
	, CASE WHEN pts.PostingDate >= @rptStartDate THEN 'Current'	ELSE 'LY' END AS SalesPeriod
	, CASE WHEN o.FCNation = 'Head Office' or (o.FCNation IN ('NSW/ACT','7th Wonder','Heartland','SANT','VIC Mania','WA', 'SA', 'WANT') AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FYE', 'FYP')) THEN 'Flight Centre'
		WHEN o.FCNation = 'IntrepidMAS' or (o.FCNation = 'Student Flights' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'STY')) THEN 'Student Flights'
		WHEN o.FCNation = 'Escape Travel' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FPG', 'FPP') THEN 'Escape Travel'
		WHEN o.FCNation = 'Cruiseabout' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FCC') THEN 'Cruiseabout'
		WHEN o.FCNation = 'Travel Associates' AND p.ProductCode IN ('CMB', 'FPG', 'FPP') THEN 'Travel Associates'
		ELSE 'Other'
		END AS ReportingGroup
	, SUM(pts.NewPolicyCount) AS PolicyCount
	, SUM(pts.GrossPremium) AS SellPrice
INTO 
	#BaseTable
FROM 
	dbo.penPolicy p
	INNER JOIN #AlphaCode o ON o.OutletAlphaKey = p.OutletAlphaKey
	INNER JOIN dbo.penPolicyTransSummary pts ON pts.PolicyKey = p.PolicyKey
WHERE
	o.LatestOutletKey in (select LatestOutletKey from #AlphaCode)
	AND
	(pts.PostingDate BETWEEN @rptStartDate AND @rptEndDate 
	OR pts.PostingDate BETWEEN @rptStartDateLY AND @rptEndDateLY)
GROUP BY 
	o.LatestOutletKey
	, o.FCNation
	, p.ProductCode
	, CASE WHEN pts.PostingDate >= @rptStartDate THEN 'Current' ELSE 'LY' END
	, CASE WHEN o.FCNation = 'Head Office' or (o.FCNation IN ('NSW/ACT','7th Wonder','Heartland','SANT','VIC Mania','WA', 'SA', 'WANT') AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FYE', 'FYP')) THEN 'Flight Centre'
		WHEN o.FCNation = 'IntrepidMAS' or (o.FCNation = 'Student Flights' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'STY')) THEN 'Student Flights'
		WHEN o.FCNation = 'Escape Travel' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FPG', 'FPP') THEN 'Escape Travel'
		WHEN o.FCNation = 'Cruiseabout' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FCC') THEN 'Cruiseabout'
		WHEN o.FCNation = 'Travel Associates' AND p.ProductCode IN ('CMB', 'FPG', 'FPP') THEN 'Travel Associates'
		ELSE 'Other'
		END




-- Base table on product code level, inlcude LY End of Month reporting period, and all brands
-- For data validation, to be compared with policy cube
IF OBJECT_ID('tempdb..#BaseTableEOM') IS NOT NULL DROP TABLE #BaseTableEOM
SELECT 
	o.LatestOutletKey
	, o.FCNation
	, p.ProductCode
	, 'LYEOM' AS SalesPeriod
	, CASE WHEN o.FCNation = 'Head Office' or (o.FCNation IN ('NSW/ACT','7th Wonder','Heartland','SANT','VIC Mania','WA', 'SA', 'WANT') AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FYE', 'FYP')) THEN 'Flight Centre'
		WHEN o.FCNation = 'IntrepidMAS' or (o.FCNation = 'Student Flights' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'STY')) THEN 'Student Flights'
		WHEN o.FCNation = 'Escape Travel' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FPG', 'FPP') THEN 'Escape Travel'
		WHEN o.FCNation = 'Cruiseabout' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FCC') THEN 'Cruiseabout'
		WHEN o.FCNation = 'Travel Associates' AND p.ProductCode IN ('CMB', 'FPG', 'FPP') THEN 'Travel Associates'
		ELSE 'Other'
		END AS ReportingGroup
	, SUM(pts.NewPolicyCount) AS PolicyCount
	, SUM(pts.GrossPremium) AS SellPrice
INTO 
	#BaseTableEOM
FROM 
	dbo.penPolicy p
	INNER JOIN #AlphaCode o ON o.OutletAlphaKey = p.OutletAlphaKey
	INNER JOIN dbo.penPolicyTransSummary pts ON pts.PolicyKey = p.PolicyKey
WHERE 
	o.LatestOutletKey in (Select LatestOutletKey from #AlphaCode)
	AND
	pts.PostingDate BETWEEN @rptStartDateLYEOM AND @rptEndDateLYEOM
GROUP BY 
	o.LatestOutletKey
	, o.FCNation
	, p.ProductCode
	, CASE WHEN o.FCNation = 'Head Office' or (o.FCNation IN ('NSW/ACT','7th Wonder','Heartland','SANT','VIC Mania','WA', 'SA', 'WANT') AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FYE', 'FYP')) THEN 'Flight Centre'
		WHEN o.FCNation = 'IntrepidMAS' or (o.FCNation = 'Student Flights' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'STY')) THEN 'Student Flights'
		WHEN o.FCNation = 'Escape Travel' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FPG', 'FPP') THEN 'Escape Travel'
		WHEN o.FCNation = 'Cruiseabout' AND p.ProductCode IN ('FCO', 'FCT', 'CMB', 'FCC') THEN 'Cruiseabout'
		WHEN o.FCNation = 'Travel Associates' AND p.ProductCode IN ('CMB', 'FPG', 'FPP') THEN 'Travel Associates'
		ELSE 'Other'
		END



-- Calculate policycount and sell price for both current and LY sales period
IF OBJECT_ID('tempdb..#BaseTable2') IS NOT NULL DROP TABLE #BaseTable2
SELECT 
	bt.LatestOutletKey
	, bt.FCNation
	, bt.SalesPeriod
	, bt.ReportingGroup
	, SUM(bt.PolicyCount) AS PolicyCount
	, SUM(bt.SellPrice) AS SellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FCO' THEN bt.PolicyCount ELSE 0 END) AS FCOCount
	, SUM(CASE WHEN bt.ProductCode = 'FCT' THEN bt.PolicyCount ELSE 0 END) AS FCTCount
	, SUM(CASE WHEN bt.ProductCode = 'CMB' THEN bt.PolicyCount ELSE 0 END) AS CMBCount
	, SUM(CASE WHEN bt.ProductCode = 'STY' THEN bt.PolicyCount ELSE 0 END) AS STYCount
	, SUM(CASE WHEN bt.ProductCode = 'FPG' THEN bt.PolicyCount ELSE 0 END) AS FPGCount
	, SUM(CASE WHEN bt.ProductCode = 'FPP' THEN bt.PolicyCount ELSE 0 END) AS FPPCount
	, SUM(CASE WHEN bt.ProductCode = 'FCC' THEN bt.PolicyCount ELSE 0 END) AS FCCCount
	, SUM(CASE WHEN bt.ProductCode = 'FYE' THEN bt.PolicyCount ELSE 0 END) AS FYECount
	, SUM(CASE WHEN bt.ProductCode = 'FYP' THEN bt.PolicyCount ELSE 0 END) AS FYPCount
	, SUM(CASE WHEN bt.ProductCode NOT IN ('FCO', 'FCT', 'CMB', 'STY', 'FPG', 'FPP', 'FCC','FYE','FYP') THEN bt.PolicyCount ELSE 0 END) AS RestCount
	, SUM(CASE WHEN bt.ProductCode = 'FCO' THEN bt.SellPrice ELSE 0 END) AS FCOSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FCT' THEN bt.SellPrice ELSE 0 END) AS FCTSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'CMB' THEN bt.SellPrice ELSE 0 END) AS CMBSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'STY' THEN bt.SellPrice ELSE 0 END) AS STYSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FPG' THEN bt.SellPrice ELSE 0 END) AS FPGSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FPP' THEN bt.SellPrice ELSE 0 END) AS FPPSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FCC' THEN bt.SellPrice ELSE 0 END) AS FCCSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FYE' THEN bt.SellPrice ELSE 0 END) AS FYESellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FYP' THEN bt.SellPrice ELSE 0 END) AS FYPSellPrice
	, SUM(CASE WHEN bt.ProductCode NOT IN ('FCO', 'FCT', 'CMB', 'STY', 'FPG', 'FPP', 'FCC','FYE','FYP') THEN bt.SellPrice ELSE 0 END) AS RestSellPrice
INTO 
	#BaseTable2
FROM 
	#BaseTable bt
GROUP BY 
	bt.LatestOutletKey
	, bt.FCNation
	, bt.SalesPeriod
	, bt.ReportingGroup




-- Calculate policycount and sell price for LY End of Month sales period
IF OBJECT_ID('tempdb..#BaseTableEOM2') IS NOT NULL DROP TABLE #BaseTableEOM2
SELECT 
	bt.LatestOutletKey
	, bt.FCNation
	, bt.SalesPeriod
	, bt.ReportingGroup
	, SUM(bt.PolicyCount) AS PolicyCount
	, SUM(bt.SellPrice) AS SellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FCO' THEN bt.PolicyCount ELSE 0 END) AS FCOCount
	, SUM(CASE WHEN bt.ProductCode = 'FCT' THEN bt.PolicyCount ELSE 0 END) AS FCTCount
	, SUM(CASE WHEN bt.ProductCode = 'CMB' THEN bt.PolicyCount ELSE 0 END) AS CMBCount
	, SUM(CASE WHEN bt.ProductCode = 'STY' THEN bt.PolicyCount ELSE 0 END) AS STYCount
	, SUM(CASE WHEN bt.ProductCode = 'FPG' THEN bt.PolicyCount ELSE 0 END) AS FPGCount
	, SUM(CASE WHEN bt.ProductCode = 'FPP' THEN bt.PolicyCount ELSE 0 END) AS FPPCount
	, SUM(CASE WHEN bt.ProductCode = 'FCC' THEN bt.PolicyCount ELSE 0 END) AS FCCCount
	, SUM(CASE WHEN bt.ProductCode = 'FYE' THEN bt.PolicyCount ELSE 0 END) AS FYECount
	, SUM(CASE WHEN bt.ProductCode = 'FYP' THEN bt.PolicyCount ELSE 0 END) AS FYPCount
	, SUM(CASE WHEN bt.ProductCode NOT IN ('FCO', 'FCT', 'CMB', 'STY', 'FPG', 'FPP', 'FCC','FYE','FYP') THEN bt.PolicyCount ELSE 0 END) AS RestCount
	, SUM(CASE WHEN bt.ProductCode = 'FCO' THEN bt.SellPrice ELSE 0 END) AS FCOSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FCT' THEN bt.SellPrice ELSE 0 END) AS FCTSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'CMB' THEN bt.SellPrice ELSE 0 END) AS CMBSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'STY' THEN bt.SellPrice ELSE 0 END) AS STYSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FPG' THEN bt.SellPrice ELSE 0 END) AS FPGSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FPP' THEN bt.SellPrice ELSE 0 END) AS FPPSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FCC' THEN bt.SellPrice ELSE 0 END) AS FCCSellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FYE' THEN bt.SellPrice ELSE 0 END) AS FYESellPrice
	, SUM(CASE WHEN bt.ProductCode = 'FYP' THEN bt.SellPrice ELSE 0 END) AS FYPSellPrice
	, SUM(CASE WHEN bt.ProductCode NOT IN ('FCO', 'FCT', 'CMB', 'STY', 'FPG', 'FPP', 'FCC','FYE','FYP') THEN bt.SellPrice ELSE 0 END) AS RestSellPrice
INTO 
	#BaseTableEOM2
FROM 
	#BaseTableEOM bt
GROUP BY 
	bt.LatestOutletKey
	, bt.FCNation
	, bt.SalesPeriod
	, bt.ReportingGroup



-- Current sales period
-- apply OptionMixPolicy, OptionMixSales, LY Sales Target, Outlet information
-- total last year sell and policy count are smaller than policy cube, as some of the outlets were closed
IF OBJECT_ID('tempdb..#Detail') IS NOT NULL DROP TABLE #Detail
SELECT 
	bt.LatestOutletKey
	, bt.FCNation
	, bt.SalesPeriod
	, bt.ReportingGroup
	, bt.PolicyCount
	, bt.SellPrice
	, bt.FCOCount
	, bt.FCTCount
	, bt.CMBCount
	, bt.STYCount
	, bt.FPGCount
	, bt.FPPCount
	, bt.FCCCount
	, bt.FYECount
	, bt.FYPCount
	, bt.RestCount
	, bt.FCOSellPrice
	, bt.FCTSellPrice
	, bt.CMBSellPrice
	, bt.STYSellPrice
	, bt.FPGSellPrice
	, bt.FPPSellPrice
	, bt.FCCSellPrice
	, bt.FYESellPrice
	, bt.FYPSellPrice
	, bt.RestSellPrice
	, CASE WHEN bt.ReportingGroup = 'Flight Centre' AND bt.FCOCount + bt.FCTCount + bt.CMBCount + bt.FYECount + bt.FYPCount <> 0 THEN CONVERT(float, bt.FCOCount) / (bt.FCOCount + bt.FCTCount + bt.CMBCount + bt.FYECount + bt.FYPCount)
		WHEN bt.ReportingGroup = 'Cruiseabout' AND bt.FCOCount + bt.FCTCount + bt.CMBCount + bt.FCCCount <> 0 THEN CONVERT(float, bt.FCOCount + bt.FCCCount) / (bt.FCOCount + bt.FCTCount + bt.CMBCount + bt.FCCCount)
		ELSE NULL END AS OptionsMixPolicy
	, CASE WHEN bt.ReportingGroup = 'Flight Centre' AND bt.FCOSellPrice + bt.FCTSellPrice + bt.CMBSellPrice + bt.FYESellPrice + bt.FYPSellPrice <> 0 THEN CONVERT(float, bt.FCOSellPrice) / (bt.FCOSellPrice + bt.FCTSellPrice + bt.CMBSellPrice + bt.FYESellPrice + bt.FYPSellPrice)
		ELSE NULL END AS OptionsMixSales
	, cs1.ConsultantCount
	, CASE WHEN cs1.ConsultantCount > 0 THEN bt.SellPrice / cs1.ConsultantCount 
		ELSE NULL END AS SellPricePerConsultant
	, ly1.PolicyCount AS PolicyCountLY
	, ly1.SellPrice AS SellPriceLY
	, lyEOM1.PolicyCount AS PolicyCountLYEOM
	, lyEOM1.SellPrice AS SellPriceLYEOM
	, ly1.SellPrice * 1.05 AS SellPriceLY105
	, ly1.SellPrice * 1.10 AS SellPriceLY110
	, ly1.SellPrice * 1.15 AS SellPriceLY115
	, ly1.SellPrice * 1.20 AS SellPriceLY120
	, lyEOM1.SellPrice * 1.05 AS SellPriceLYEOM105
	, lyEOM1.SellPrice * 1.10 AS SellPriceLYEOM110
	, lyEOM1.SellPrice * 1.15 AS SellPriceLYEOM115
	, lyEOM1.SellPrice * 1.20 AS SellPriceLYEOM120
	, o1.BDMName
	, o1.AlphaCode
	, o1.OutletName
	, o1.CountryKey
	, o1.FCArea
	, o1.FCAreaCode
	, o1.CommencementDate
	, o1.CloseDate
	, o1.PreviousAlpha
	, o1.OutletType
	, o1.GroupCode
	, o1.TradingStatus
	, o1.OutletAlphaKey
	, o1.TradingAge
INTO 
	#Detail
FROM 
	#BaseTable2 bt
	-- apply Last Year Sell, [ReportingGroup = Other] has to be taken out, as it causes duplicates when joining on alphacode, as same alphacode may ends up in 2 reporting groups
	OUTER APPLY (SELECT 
					sum(ly.SellPrice) SellPrice
					, sum(ly.PolicyCount) PolicyCount
				FROM 
					#BaseTable2 ly 
				WHERE 
					ly.LatestOutletKey = bt.LatestOutletKey 
					AND ly.SalesPeriod = 'LY'
					AND bt.SalesPeriod = 'LY' 
					AND ly.ReportingGroup <> 'Other' 
					AND bt.ReportingGroup <> 'Other'
				) ly1
	-- apply Last Year End of Month Sell, [ReportingGroup = Other] has to be taken out, as it causes duplicates when joining on alphacode, as same alphacode may ends up in 2 reporting groups
	OUTER APPLY (SELECT 
					sum(lyEOM.SellPrice) SellPrice
					, Sum(lyEOM.PolicyCount) PolicyCount
				FROM 
					#BaseTableEOM2 lyEOM 
				WHERE 
					lyEOM.LatestOutletKey = bt.LatestOutletKey 
					AND lyEOM.SalesPeriod = 'LYEOM' 
					AND bt.SalesPeriod = 'LYEOM'
					AND lyEOM.ReportingGroup <> 'Other' 
					AND bt.ReportingGroup <> 'Other') lyEOM1
	OUTER APPLY (SELECT 
					sum(cs.ConsultantCount) ConsultantCount
				FROM 
					#Consultant cs 
				WHERE 
					cs.LatestOutletKey = bt.LatestOutletKey) cs1
	OUTER APPLY (SELECT 
					Top 1
					o.BDMName
					, o.AlphaCode
					, o.OutletName
					, o.CountryKey
					, o.FCArea
					, o.FCAreaCode
					, o.CommencementDate
					, o.CloseDate
					, o.PreviousAlpha
					, o.OutletType
					, o.GroupCode
					, o.TradingStatus
					, o.OutletAlphaKey
					, o.TradingAge
				FROM 
					#AlphaCode o 
				WHERE 
					o.LatestOutletKey = bt.LatestOutletKey 
					and o.OutletKey = bt.LatestOutletKey
				) o1
WHERE 
	bt.SalesPeriod = 'Current'


-- Apply kicker percentage
IF OBJECT_ID('tempdb..#Detail2') IS NOT NULL DROP TABLE #Detail2
SELECT 
	dtl.LatestOutletKey
	, dtl.FCNation
	, dtl.SalesPeriod
	, dtl.ReportingGroup
	, dtl.PolicyCount
	, dtl.SellPrice
	, dtl.FCOCount
	, dtl.FCTCount
	, dtl.CMBCount
	, dtl.STYCount
	, dtl.FPGCount
	, dtl.FPPCount
	, dtl.FCCCount
	, dtl.FYECount
	, dtl.FYPCount
	, dtl.RestCount
	, dtl.FCOSellPrice
	, dtl.FCTSellPrice
	, dtl.CMBSellPrice
	, dtl.STYSellPrice
	, dtl.FPGSellPrice
	, dtl.FPPSellPrice
	, dtl.FCCSellPrice
	, dtl.FYESellPrice
	, dtl.FYPSellPrice
	, dtl.RestSellPrice
	, dtl.OptionsMixPolicy
	, dtl.OptionsMixSales
	, dtl.ConsultantCount
	, dtl.SellPricePerConsultant
	, dtl.PolicyCountLY
	, dtl.SellPriceLY
	, dtl.PolicyCountLYEOM
	, dtl.SellPriceLYEOM
	, dtl.SellPriceLY105
	, dtl.SellPriceLY110
	, dtl.SellPriceLY115
	, dtl.SellPriceLY120
	, dtl.SellPriceLYEOM105
	, dtl.SellPriceLYEOM110
	, dtl.SellPriceLYEOM115
	, dtl.SellPriceLYEOM120
	, dtl.BDMName
	, dtl.AlphaCode
	, dtl.OutletName
	, dtl.CountryKey
	, dtl.FCArea
	, dtl.FCAreaCode
	, dtl.CommencementDate
	, dtl.CloseDate
	, dtl.PreviousAlpha
	, dtl.OutletType
	, dtl.GroupCode
	, dtl.TradingStatus
	, dtl.OutletAlphaKey
	, dtl.TradingAge
	, CASE WHEN dtl.ReportingGroup = 'Flight Centre' AND dtl.SellPrice > 0 AND dtl.TradingStatus = 'Stocked' AND dtl.SellPricePerConsultant >= 4000 THEN 0.03
	WHEN dtl.ReportingGroup = 'Student Flights' AND dtl.SellPrice > 0 AND dtl.TradingStatus = 'Stocked' AND dtl.SellPricePerConsultant >= 3500 THEN 0.03 
	WHEN dtl.ReportingGroup = 'Escape Travel' AND dtl.SellPrice > 0 AND dtl.TradingStatus = 'Stocked' AND dtl.SellPricePerConsultant >= 4000 THEN 0.03 
	WHEN dtl.ReportingGroup = 'Cruiseabout' AND dtl.SellPrice > 0 AND dtl.TradingStatus = 'Stocked' AND dtl.SellPricePerConsultant >= 4000 THEN 0.03 
	WHEN dtl.ReportingGroup = 'Travel Associates' AND dtl.TradingAge = '>12mths' AND dtl.PolicyCount >= 25 AND ((dtl.PolicyCount - dtl.PolicyCountLY) / dtl.PolicyCountLY) >= 0.20 AND dtl.TradingStatus = 'Stocked' THEN 0.10
	WHEN dtl.ReportingGroup = 'Travel Associates' AND dtl.TradingAge = '>12mths' AND dtl.PolicyCount >= 25 AND (((dtl.PolicyCount - dtl.PolicyCountLY) / dtl.PolicyCountLY) >= 0.10 and ((dtl.PolicyCount - dtl.PolicyCountLY) / dtl.PolicyCountLY) < 0.20) AND dtl.TradingStatus = 'Stocked' THEN 0.05
	WHEN dtl.ReportingGroup = 'Travel Associates' AND dtl.TradingAge <> '>12mths' AND dtl.PolicyCount >= 25 AND dtl.TradingStatus = 'Stocked' THEN 0.10
	WHEN dtl.TradingAge = '>12mths' AND dtl.TradingStatus = 'Stocked' AND dtl.SellPrice >= dtl.SellPriceLYEOM AND dtl.SellPrice < dtl.SellPriceLYEOM110 THEN 0.01
	WHEN dtl.TradingAge = '>12mths' AND dtl.TradingStatus = 'Stocked' AND dtl.SellPrice >= dtl.SellPriceLYEOM110 AND dtl.SellPrice < dtl.SellPriceLYEOM115 THEN 0.02
	WHEN dtl.TradingAge = '>12mths' AND dtl.TradingStatus = 'Stocked' AND dtl.SellPrice >= dtl.SellPriceLYEOM115 THEN 0.03
	WHEN dtl.TradingAge <> '>12mths' AND dtl.TradingStatus = 'Stocked' THEN 0.02
	ELSE 0 END AS KickerEarnedPercent 
INTO 
	#Detail2
FROM 
	#Detail dtl



IF OBJECT_ID('tempdb..#out') IS NOT NULL DROP TABLE #out
-- Apply kicker
SELECT 
	dtl.LatestOutletKey
	, dtl.FCNation
	, dtl.SalesPeriod
	, dtl.ReportingGroup
	, dtl.PolicyCount
	, dtl.SellPrice
	, dtl.FCOCount
	, dtl.FCTCount
	, dtl.CMBCount
	, dtl.STYCount
	, dtl.FPGCount
	, dtl.FPPCount
	, dtl.FCCCount
	, dtl.RestCount
	, dtl.FCOSellPrice
	, dtl.FCTSellPrice
	, dtl.CMBSellPrice
	, dtl.STYSellPrice
	, dtl.FPGSellPrice
	, dtl.FPPSellPrice
	, dtl.FCCSellPrice
	, dtl.RestSellPrice
	, dtl.OptionsMixPolicy
	, dtl.OptionsMixSales
	, dtl.ConsultantCount
	, dtl.SellPricePerConsultant
	, dtl.PolicyCountLY
	, dtl.SellPriceLY
	, dtl.PolicyCountLYEOM
	, dtl.SellPriceLYEOM
	, dtl.SellPriceLY105
	, dtl.SellPriceLY110
	, dtl.SellPriceLY115
	, dtl.SellPriceLY120
	, dtl.SellPriceLYEOM105
	, dtl.SellPriceLYEOM110
	, dtl.SellPriceLYEOM115
	, dtl.SellPriceLYEOM120
	, dtl.BDMName
	, dtl.AlphaCode
	, dtl.OutletName
	, dtl.CountryKey
	, dtl.FCArea
	, dtl.FCAreaCode
	, dtl.CommencementDate
	, dtl.CloseDate
	, dtl.PreviousAlpha
	, dtl.OutletType
	, dtl.GroupCode
	, dtl.TradingStatus
	, dtl.OutletAlphaKey
	, dtl.TradingAge
	, dtl.KickerEarnedPercent
	, (dtl.SellPrice * dtl.KickerEarnedPercent) AS KickerEarned
	, @rptStartDate as StartDate
	, @rptEndDate as EndDate
	, @rptStartDateLY as StartDateLY
	, @rptEndDateLY as EndDateLY
	, @rptStartDateLYEOM as StartDateLYEOM
	, @rptEndDateLYEOM as EndDateLYEOM
Into
	#out
FROM 
	#Detail2 dtl


-- The rest of LY sell which can't be attached to the current alpha
UNION

SELECT 
	o.LatestOutletKey
	, o.FCNation
	, ly.SalesPeriod
	, ly.ReportingGroup
	, NULL AS PolicyCount
	, NULL AS SellPrice
	, NULL AS FCOCount, NULL AS FCTCount, NULL AS CMBCount, NULL AS STYCount, NULL AS FPGCount, NULL AS FPPCount, NULL AS FCCCount
	,NULL AS RestCount
	, NULL AS FCOSellPrice, NULL AS FCTSellPrice, NULL AS CMBSellPrice, NULL AS STYSellPrice, NULL AS FPGSellPrice, NULL AS FPPSellPrice, NULL AS FCCSellPrice 
	,NULL AS RestSellPrice
	, NULL AS OptionsMixPolicy, NULL AS OptionsMixSales, NULL AS ConsultantCount, NULL AS SellPricePerConsultant
	, ly.PolicyCount AS PolicyCountLY
	, ly.SellPrice AS SellPriceLY
	, NULL AS PolicyCountLYEOM
	, NULL AS SellPriceLYEOM
	, ly.SellPrice * 1.05 AS SellPriceLY105
	, ly.SellPrice * 1.10 AS SellPriceLY110
	, ly.SellPrice * 1.15 AS SellPriceLY115
	, ly.SellPrice * 1.20 AS SellPriceLY120
	, NULL AS SellPriceLYEOM105
	, NULL AS SellPriceLYEOM110
	, NULL AS SellPriceLYEOM115
	, NULL AS SellPriceLYEOM120
	, o.BDMName
	, o.AlphaCode
	, o.OutletName
	, o.CountryKey
	, o.FCArea
	, o.FCAreaCode
	, o.CommencementDate
	, o.CloseDate
	, o.PreviousAlpha
	, o.OutletType
	, o.GroupCode
	, o.TradingStatus
	, o.OutletAlphaKey
	, o.TradingAge
	, NULL AS KickerEarnedPercent
	, NULL AS KickerEarned
	, @rptStartDate as StartDate
	, @rptEndDate as EndDate
	, @rptStartDateLY as StartDateLY
	, @rptEndDateLY as EndDateLY
	, @rptStartDateLYEOM as StartDateLYEOM
	, @rptEndDateLYEOM as EndDateLYEOM
FROM 
	#BaseTable2 ly
	outer apply
	(
		select 
			top 1
			*
		From
			#AlphaCode o 
		where
			o.latestOutletKey = ly.LatestOutletKey
			AND o.OutletKey = ly.LatestOutletKey 
			AND o.OutletStatus = 'Current'
	) o
WHERE 
	o.LatestOutletKey in (Select LatestOutletKey from #AlphaCode)
	AND
	ly.SalesPeriod = 'LY'
	--AND 
	--	(
	--		ly.ReportingGroup = 'Other'
	--		OR 
	--		(
	--		ly.ReportingGroup <> 'Other' 
	--		AND ly.LatestOutletKey NOT IN (SELECT 
	--											LatestOutletKey 
	--										FROM 
	--											#BaseTable2 cr 
	--										WHERE 
	--											cr.SalesPeriod = 'Current' 
	--											AND cr.ReportingGroup <> 'Other'
	--										)
	--		)
	--	)



-- The rest of LY End of Month sell which can't be attached to the current alpha
UNION

SELECT 
	o.LatestOutletKey
	, o.FCNation
	, lyEOM.SalesPeriod
	, lyEOM.ReportingGroup
	, NULL AS PolicyCount
	, NULL AS SellPrice
	, NULL AS FCOCount
	, NULL AS FCTCount
	, NULL AS CMBCount
	, NULL AS STYCount
	, NULL AS FPGCount
	, NULL AS FPPCount
	, NULL AS FCCCount
	, NULL AS RestCount
	, NULL AS FCOSellPrice
	, NULL AS FCTSellPrice
	, NULL AS CMBSellPrice
	, NULL AS STYSellPrice
	, NULL AS FPGSellPrice
	, NULL AS FPPSellPrice
	, NULL AS FCCSellPrice
	, NULL AS RestSellPrice
	, NULL AS OptionsMixPolicy
	, NULL AS OptionsMixSales
	, NULL AS ConsultantCount
	, NULL AS SellPricePerConsultant
	, NULL AS PolicyCountLY
	, NULL AS SellPriceLY
	, lyEOM.PolicyCount AS PolicyCountLYEOM
	, lyEOM.SellPrice AS SellPriceLYEOM
	, NULL AS SellPriceLY105
	, NULL AS SellPriceLY110
	, NULL AS SellPriceLY115
	, NULL AS SellPriceLY120
	, lyEOM.SellPrice * 1.05 AS SellPriceLYEOM105
	, lyEOM.SellPrice * 1.10 AS SellPriceLYEOM110
	, lyEOM.SellPrice * 1.15 AS SellPriceLYEOM115
	, lyEOM.SellPrice * 1.20 AS SellPriceLYEOM120
	, o.BDMName
	, o.AlphaCode
	, o.OutletName
	, o.CountryKey
	, o.FCArea
	, o.FCAreaCode
	, o.CommencementDate
	, o.CloseDate
	, o.PreviousAlpha
	, o.OutletType
	, o.GroupCode
	, o.TradingStatus
	, o.OutletAlphaKey
	, o.TradingAge
	, NULL AS KickerEarnedPercent
	, NULL AS KickerEarned
	, @rptStartDate as StartDate
	, @rptEndDate as EndDate
	, @rptStartDateLY as StartDateLY
	, @rptEndDateLY as EndDateLY
	, @rptStartDateLYEOM as StartDateLYEOM
	, @rptEndDateLYEOM as EndDateLYEOM
FROM 
	#BaseTableEOM2 lyEOM
	Outer apply
	(
		select
			top 1
			*
		From
			#AlphaCode o 
		Where
			o.LatestOutletKey = lyEOM.LatestOutletKey
			AND o.OutletKey = lyEOM.LatestOutletKey
			AND o.OutletStatus = 'Current' 
	) o
WHERE
	o.LatestOutletKey in (Select LatestOutletKey from #AlphaCode)
	and
	lyEOM.SalesPeriod = 'LYEOM'
	AND 
		(
			lyEOM.ReportingGroup = 'Other'
			OR 
			(
			 lyEOM.ReportingGroup <> 'Other' 
			 AND 
			 lyEOM.LatestOutletKey NOT IN (SELECT 
													LatestOutletKey 
												  FROM 
													#BaseTableEOM2 cr 
												  WHERE 
													cr.SalesPeriod = 'Current' 
													AND cr.ReportingGroup <> 'Other'
												  )
			)
		)


select 
	distinct
	*
from
    #out
where
	isnull(PolicyCount, 0) <> 0 or
	isnull(SellPrice, 0) <> 0 or
	isnull(PolicyCountLY, 0) <> 0 or
	isnull(SellPriceLY, 0) <> 0 or
	isnull(PolicyCountLYEOM, 0) <> 0 or
	isnull(SellPriceLYEOM, 0) <> 0

--drop temp tables
IF OBJECT_ID('tempdb..#AlphaCode') IS NOT NULL DROP TABLE #AlphaCode
IF OBJECT_ID('tempdb..#Consultant') IS NOT NULL DROP TABLE #Consultant
IF OBJECT_ID('tempdb..#BaseTable') IS NOT NULL DROP TABLE #BaseTable
IF OBJECT_ID('tempdb..#BaseTable2') IS NOT NULL DROP TABLE #BaseTable2
IF OBJECT_ID('tempdb..#BaseTable') IS NOT NULL DROP TABLE #BaseTableEOM
IF OBJECT_ID('tempdb..#BaseTable2') IS NOT NULL DROP TABLE #BaseTableEOM2
IF OBJECT_ID('tempdb..#Detail') IS NOT NULL DROP TABLE #Detail
IF OBJECT_ID('tempdb..#Detail2') IS NOT NULL DROP TABLE #Detail2
GO
