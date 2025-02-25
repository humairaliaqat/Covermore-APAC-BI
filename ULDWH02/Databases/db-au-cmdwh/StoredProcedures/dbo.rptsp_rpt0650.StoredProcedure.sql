USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0650]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0650]	@DateRange varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10),
										@RepMonth int = 14
as

SET NOCOUNT ON
									
/****************************************************************************************************/
--  Name:           etlsp_RPT0650
--  Author:         Shweta Jain
--  Date Created:   20150824
--  Description:    This stored procedure returns outlet and consultant statistics for helloworld group
--					
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@RepMonth: the number of months to report on
--   
--	Change History:
--			20150903 - SJ - TFS 16828 - Created
--			20150907 - LT - added Group State and excluded TRIPS consultants
--			
/****************************************************************************************************/

--uncomment to debug
/*
DECLARE @DateRange varchar(30),
		@StartDate varchar(10),
		@EndDate varchar(10),
		@RepMonth int
SELECT @DateRange = 'Month-To-Date', @StartDate = null, @EndDate = null, @RepMonth = 14
*/


DECLARE @rptStartDate DATE
DECLARE @rptEndDate DATE

SET @RepMonth = @RepMonth - 1

--Get reporting dates
IF @DateRange = '_User Defined'
	SELECT @rptStartDate = DATEADD(MM, -@RepMonth, @StartDate),
		   @rptEndDate = @EndDate
ELSE
	SELECT @rptStartDate = DATEADD(MM, -@RepMonth, StartDate), 
		   @rptEndDate = EndDate
	FROM dbo.vDateRange
	WHERE DateRange = @DateRange



--Get stores for the selected peroid
IF object_id('tempdb..#Outlet') IS NOT NULL DROP TABLE #Outlet
SELECT distinct 
		OutletAlphaKey,
		LatestOutletKey,
		lo.GroupName,
		lo.SubGroupName,
		lo.CommencementDate OutletStartDate,
		lo.TradingStatus,
		lo.CloseDate OutletCloseDate,
		lo.[State],
		u.ConsultantKey,
		u.UserStartDate,
		u.UserStatus,
		u.UserEndDate,
		u.ConsultantType   
INTO #Outlet
FROM 
	penOutlet o
	outer apply 
	(
		select top 1 SuperGroupName,
				GroupName,
				SubGroupName,
				CommencementDate,
				TradingStatus,
				CloseDate,
				StateSalesArea as [State]
		from
			penOutlet
		where
			OutletStatus = 'Current' and
			OutletKey = o.LatestOutletKey
	) lo
	OUTER APPLY
	(
		SELECT DISTINCT 
			UserKey as ConsultantKey, 
			ConsultantType, 
			CreateDateTime UserStartDate,
			[Status] UserStatus,
			InactiveDate UserEndDate
		FROM penUser
		WHERE 
			OutletKey = o.LatestOutletKey AND 
			UserStatus = 'Current' and
			ConsultantType = 'External' AND 
			ISNUMERIC(REPLACE(UserKey, 'AU-CM7-', '')) <> 0		--exclude TRIPS-migrated consultants

	) u
WHERE 
	o.CountryKey = 'AU' and
	o.OutletType = 'B2B' and
	(
		lo.SuperGroupname = 'Stella' or 
		lo.GroupName = 'Traveller''s Choice'
	) and
    o.OutletStatus = 'Current' and
	(	
		lo.TradingStatus IN ('Stocked','Prospect') OR 
		(lo.TradingStatus = 'Closed' AND lo.CloseDate BETWEEN @rptStartDate AND @rptEndDate)
	) and
    o.OutletAlphaKey not in (select OutletAlphaKey							--exclude TRIPS migrated outlets
							 from penOutlet
							 where
								CountryKey = 'AU' and
								(
									SuperGroupname = 'Stella' or 
									GroupName = 'Traveller''s Choice'
								) and
								OutletStatus = 'Current' and
								ISNUMERIC(REPLACE(LatestOutletKey, 'AU-CM7-', '')) = 0
							)



--Get policies for the  selected peroid
IF object_id('tempdb..#Policy') IS NOT NULL DROP TABLE #Policy
SELECT DISTINCT
	PolicyKey,
	TransactionStatus,
	IssueDate, --CONVERT(VARCHAR(10), FORMAT(IssueDate, 'YYYY-MM-DD')) IssueMonth,
	p.OutletAlphaKey,
	LatestOutletKey,
	p.UserKey ConsultantKey
INTO #Policy
FROM penPolicyTransSummary p
	INNER JOIN penOutlet o 
		ON p.OutletAlphaKey = o.OutletAlphaKey 
		AND o.OutletStatus = 'Current'
WHERE p.CountryKey = 'AU' 
	AND p.PostingDate BETWEEN @rptStartDate AND @rptEndDate 
	AND p.TransactionStatus = 'Active'
	AND o.OutletAlphaKey IN (SELECT DISTINCT OutletAlphaKey FROM #Outlet)



--Populate monthly table with stores and consultants
IF object_id('tempdb..#OutletMonthly') IS NOT NULL DROP TABLE #OutletMonthly
CREATE TABLE #OutletMonthly
(
	GroupName VARCHAR(50),
	[State] varchar(50),
	ReportDate DATE,
	OutletCount INT,
	OutletSellCount INT,
	OutletNotSellCount INT,
	ConsultantCount INT,
	ConsultantSellCount INT,
	ConsultantNotSellCount INT
)	


DECLARE @ReportDate DATE
DECLARE @CurMonStartDate DATE
DECLARE @CurMonEndDate DATE


SELECT @ReportDate = CurMonthStart
FROM [dbo].[Calendar]
WHERE [DATE] = @rptStartDate


--Loop through the each month between start date and end date
WHILE @ReportDate < @rptEndDate
BEGIN


	SELECT @CurMonStartDate = CurMonthStart, @CurMonEndDate = CurMonthEnd
	FROM [dbo].[Calendar]
	WHERE [DATE] = @ReportDate


	INSERT INTO #OutletMonthly
	SELECT 
		m.GroupName, 
		m.[State],
		@ReportDate, 
		SUM(TotalStores), 
		SUM(TotalSellingStores), 
		SUM(TotalStores) - SUM(TotalSellingStores), 
		SUM(TotalConsultants), 
		SUM(TotalSellingConsultants), 
		SUM(TotalConsultants) - SUM(TotalSellingConsultants)
	FROM
	(
		SELECT 
			CASE WHEN SubGroupName = 'helloworld for business' THEN SubGroupName ELSE GroupName END GroupName,
			[State],
			COUNT(DISTINCT CASE 
								WHEN TradingStatus IN ('Stocked','Prospect') AND OutletStartDate <= @ReportDate THEN LatestOutletKey
								WHEN TradingStatus IN ('Stocked','Prospect') AND MONTH(OutletStartDate) = MONTH(@ReportDate) AND YEAR(OutletStartDate) = YEAR(@ReportDate) THEN LatestOutletKey
								WHEN TradingStatus = 'Closed' AND OutletCloseDate IS NOT NULL AND OutletCloseDate > @ReportDate THEN LatestOutletKey
								WHEN TradingStatus = 'Closed' AND OutletCloseDate IS NOT NULL AND MONTH(OutletCloseDate) =  MONTH(@ReportDate) AND YEAR(OutletCloseDate) = YEAR(@ReportDate) THEN NULL
								WHEN TradingStatus = 'Closed' AND OutletCloseDate IS NOT NULL AND OutletCloseDate < @ReportDate THEN NULL
								WHEN TradingStatus = 'Closed' THEN NULL
			END) as TotalStores,
			COUNT(DISTINCT CASE 
								WHEN UserStatus = 'Active' AND UserStartDate < @ReportDate THEN ConsultantKey
								WHEN UserStatus = 'Active' AND Month(UserStartDate) = MONTH(@ReportDate) AND YEAR(UserStartDate) = YEAR(@ReportDate) THEN ConsultantKey
								WHEN UserStatus = 'Inactive' AND UserEndDate IS NOT NULL AND UserEndDate > @ReportDate THEN ConsultantKey
								WHEN UserStatus = 'Inactive' AND UserEndDate IS NOT NULL AND MONTH(UserEndDate) =  MONTH(@ReportDate) AND YEAR(UserEndDate) = YEAR(@ReportDate) THEN NULL
								WHEN UserStatus = 'Inactive' AND UserEndDate IS NOT NULL AND UserEndDate < @ReportDate THEN NULL
								WHEN UserStatus = 'Inactive' THEN NULL
			END) as TotalConsultants
		FROM #Outlet
		GROUP BY CASE WHEN SubGroupName = 'helloworld for business' THEN SubGroupName ELSE GroupName END, [State]
	) m
	LEFT JOIN		
	(
		SELECT 
			CASE WHEN SubGroupName = 'helloworld for business' THEN SubGroupName ELSE GroupName END GroupName,
			[State],
			COUNT(DISTINCT p.LatestOutletKey) as TotalSellingStores,
			COUNT(DISTINCT p.ConsultantKey) as TotalSellingConsultants
		FROM 
			#Policy p
			INNER JOIN #Outlet o ON  
				p.OutletAlphaKey = o.OutletAlphaKey AND 
				p.LatestOutletKey = o.LatestOutletKey
		WHERE 
			IssueDate BETWEEN @CurMonStartDate AND @CurMonEndDate
		GROUP BY 
			CASE WHEN SubGroupName = 'helloworld for business' THEN SubGroupName ELSE GroupName END, [State]
	)  p
	ON 
		m.GroupName = p.GroupName and	
		m.[State] = p.[State]
	GROUP BY 
		m.GroupName, m.[State]
		

	SELECT @ReportDate = NextMonthStart
	FROM [dbo].[Calendar]
	WHERE [DATE] = @ReportDate


END


--return output
SELECT
	GroupName,
	[State],
	ReportDate,
	isnull(OutletCount,0) as OutletCount,
	isnull(OutletSellCount,0) as OutletSellCount,
	isnull(OutletNotSellCount,0) as OutletNotSellCount,
	isnull(ConsultantCount,0) as ConsultantCount,
	isnull(ConsultantSellCount,0) as ConsultantSellCount,
	isnull(ConsultantNotSellCount,0) as ConsultantNotSellCount,
	@rptStartDate rptStartDate,
	@rptEndDate rptEndDate
FROM 
	#OutletMonthly 
ORDER BY 
	GroupName, ReportDate


--drop temp tables
DROP TABLE #Outlet
DROP TABLE #Policy
DROP TABLE #OutletMonthly
GO
