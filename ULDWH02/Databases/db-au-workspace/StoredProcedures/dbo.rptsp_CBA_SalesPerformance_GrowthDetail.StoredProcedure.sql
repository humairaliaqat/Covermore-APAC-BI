USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_CBA_SalesPerformance_GrowthDetail]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[rptsp_CBA_SalesPerformance_GrowthDetail]		
											
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           CBA_SalesPerformance
--  Author:         ME
--  Date Created:   20180827
--  Description:    Return Sales data for certain period  
--
--  Parameters:     NA
--   
--  Change History: 20180827 - ME - Created 
--                  
/****************************************************************************************************/

--uncomment to debug

	DECLARE @Country NVARCHAR(10) = 'AU'
	DECLARE @SuperGroup NVARCHAR(MAX) = 'Medibank'

	DECLARE @StartDate DATE = (SELECT CAST(DATEADD(MM,-6,GETDATE()) AS DATE))
	DECLARE @EndDate DATE = (SELECT CAST(GETDATE() AS DATE))


	SELECT CAST([Date] AS DATE) AS [Date],		  		   
		   isWeekDay,
		   isHoliday,
		   isWeekEnd,
		   CAST(EOMONTH([Date]) AS DATE) AS [MonthEnd]
	INTO #Calendar
	FROM [db-au-cba].dbo.Calendar
	WHERE [Date] BETWEEN @StartDate AND @EndDate

	CREATE CLUSTERED INDEX [IX_Date] ON #Calendar
	(
		[Date] ASC
	)

	SELECT	o.SuperGroupName	as [Super Group],
			o.GroupName	as [Group],
			o.SubGroupName	as [Sub Group],
			o.BDMName       AS BDM,
			o.AlphaCode     AS [Alpha Code],
			o.OutletName    AS [Outlet Name],	
			o.Channel,	
			o.OutletAlphaKey,
			o.OutletKey
    INTO #Outlets
	FROM   [db-au-cba].dbo.penOutlet o	
	WHERE  o.CountryKey = @Country			
	   AND o.OutletStatus = 'Current'			
   	   AND o.SuperGroupName = @SuperGroup

	CREATE CLUSTERED INDEX [IX_OutletKey] ON #Outlets
	(
		[OutletKey] ASC	
	)
	CREATE NONCLUSTERED INDEX [IX_OutletAlphaKey] ON #Outlets
	(
		[OutletAlphaKey] ASC

	)
	INCLUDE ( 	[OutletKey],	
				[Alpha Code]
	) 

	SELECT   po.OutletKey
			,c.Date
			,po.[Outlet Name]
			,po.[Alpha Code]			
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday
			,CASE 
				WHEN po.Channel = 'Website White-Label' THEN 'White Label'
				ELSE 'Activated'
			 END	AS [Type]
			,p.ProductDisplayName
			,SUM(pts.NewPolicyCount)	AS PolicyCount	
			,SUM(pts.GrossPremium)	AS SellPrice	
			,SUM(pts.Commission)	AS Commission
			,SUM(pts.BasePremium)	AS BasePremimum
	INTO #CY
	FROM  #Outlets po
	INNER JOIN [db-au-cba].dbo.penPolicy p						
		ON p.OutletAlphaKey = po.OutletAlphaKey
	INNER JOIN [db-au-cba].dbo.penPolicyTransSummary pts
		ON pts.PolicyKey = p.PolicyKey	
	INNER JOIN #Calendar c		
		ON CAST(pts.PostingDate AS DATE) = c.Date	
	GROUP BY po.[Outlet Name]
			,po.[Alpha Code]
			,po.OutletKey
			,c.Date
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday
			,CASE 
				WHEN po.Channel = 'Website White-Label' THEN 'White Label'
				ELSE 'Activated'
			 END
			,p.ProductDisplayName
	
	CREATE CLUSTERED INDEX [IX_Date] ON #CY
	(
		[Date] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_OutletKey] ON #CY
	(
		[OutletKey] ASC

	)
	INCLUDE ( 		
				[Alpha Code]				
	) 


	SELECT   po.OutletKey
			,c.Date
			,po.[Outlet Name]
			,po.[Alpha Code]			
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday
			,CASE 
				WHEN po.Channel = 'Website White-Label' THEN 'White Label'
				ELSE 'Activated'
			 END	AS [Type]
			,p.ProductDisplayName
			,SUM(pts.NewPolicyCount)	AS PolicyCount	
			,SUM(pts.GrossPremium)	AS SellPrice	
			,SUM(pts.Commission)	AS Commission
			,SUM(pts.BasePremium)	AS BasePremimum
	INTO #PY
	FROM  #Outlets po
	INNER JOIN [db-au-cba].dbo.penPolicy p						
		ON p.OutletAlphaKey = po.OutletAlphaKey
	INNER JOIN [db-au-cba].dbo.penPolicyTransSummary pts
		ON pts.PolicyKey = p.PolicyKey	
	INNER JOIN #Calendar c		
		ON CAST(pts.YAGOPostingDate AS DATE) = c.Date	
	GROUP BY po.[Outlet Name]
			,po.[Alpha Code]
			,po.OutletKey
			,c.Date
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday
			,CASE 
				WHEN po.Channel = 'Website White-Label' THEN 'White Label'
				ELSE 'Activated'
			 END
			,p.ProductDisplayName
	
	CREATE CLUSTERED INDEX [IX_Date] ON #PY
	(
		[Date] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_OutletKey] ON #PY
	(
		[OutletKey] ASC

	)
	INCLUDE ( 		
				[Alpha Code]				
	) 

	SELECT   po.OutletKey
			,c.Date
			,po.[Outlet Name]
			,po.[Alpha Code]			
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday
			,'White Label'	AS [Type]
			,q.ProductDisplayName
			,COUNT(q.QuoteID)	as QuoteCount
	INTO #CYQ
	FROM  #Outlets po
	INNER JOIN [db-au-cba].dbo.penQuote q						
		ON q.OutletAlphaKey = po.OutletAlphaKey
	INNER JOIN #Calendar c		
		ON CAST(q.CreateDate AS DATE) = c.Date	
	WHERE po.Channel = 'Website White-Label'
	GROUP BY po.OutletKey
			,c.Date
			,po.[Outlet Name]
			,po.[Alpha Code]			
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday			
			,q.ProductDisplayName
	
	CREATE CLUSTERED INDEX [IX_Date] ON #CYQ
	(
		[Date] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_OutletKey] ON #CYQ
	(
		[OutletKey] ASC

	)
	INCLUDE ( 		
				[Alpha Code]				
	) 

	SELECT   po.OutletKey
			,c.Date
			,po.[Outlet Name]
			,po.[Alpha Code]			
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday
			,'White Label'	AS [Type]
			,q.ProductDisplayName
			,COUNT(q.QuoteID)	as QuoteCount
	INTO #PYQ
	FROM  #Outlets po
	INNER JOIN [db-au-cba].dbo.penQuote q						
		ON q.OutletAlphaKey = po.OutletAlphaKey
	INNER JOIN #Calendar c		
		ON CAST(q.YAGOCreateDate AS DATE) = c.Date	
	WHERE po.Channel = 'Website White-Label'
	GROUP BY po.OutletKey
			,c.Date
			,po.[Outlet Name]
			,po.[Alpha Code]			
			,c.isWeekDay
			,c.isWeekEnd
			,c.isHoliday			
			,q.ProductDisplayName
	
	CREATE CLUSTERED INDEX [IX_Date] ON #PYQ
	(
		[Date] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_OutletKey] ON #PYQ
	(
		[OutletKey] ASC

	)
	INCLUDE ( 		
				[Alpha Code]				
	) 

	SELECT	 OutletKey
			,Date
			,[Outlet Name]
			,[Alpha Code]			
			,isWeekDay
			,isWeekEnd
			,isHoliday	
			,[Type]
			,ProductDisplayName
	INTO #Base
	FROM #CY
	UNION
	SELECT	 OutletKey
			,Date
			,[Outlet Name]
			,[Alpha Code]			
			,isWeekDay
			,isWeekEnd
			,isHoliday	
			,[Type]
			,ProductDisplayName
	FROM #PY
	UNION
	SELECT	 OutletKey
			,Date
			,[Outlet Name]
			,[Alpha Code]			
			,isWeekDay
			,isWeekEnd
			,isHoliday	
			,[Type]
			,ProductDisplayName
	FROM #CYQ
		UNION
	SELECT	 OutletKey
			,Date
			,[Outlet Name]
			,[Alpha Code]			
			,isWeekDay
			,isWeekEnd
			,isHoliday	
			,[Type]
			,ProductDisplayName
	FROM #PYQ

	CREATE CLUSTERED INDEX [IX_Date] ON #Base
	(
		[Date] ASC
	)
	CREATE NONCLUSTERED INDEX [IX_OutletKey] ON #Base
	(
		[OutletKey] ASC

	)
	INCLUDE ( 		
				[Alpha Code]				
	) 

	SELECT   b.OutletKey
			,b.Date
			,b.[Outlet Name]
			,b.[Alpha Code]			
			,b.isWeekDay
			,b.isWeekEnd
			,b.isHoliday	
			,b.[Type]
			,b.ProductDisplayName	AS [Product]
			,cyp.PolicyCount AS [Policy Count]
			,cyp.SellPrice AS [Sell Price]
			,cyp.Commission	AS [Commission]
			,cyp.BasePremimum	AS [Base Premium]
			,cyq.QuoteCount	AS [Quote Count]
			,'Current'	AS Label
	FROM #Base b
	LEFT JOIN #CY cyp
		ON	b.OutletKey = cyp.OutletKey
		AND b.Date = cyp.Date
		AND b.Type = cyp.Type
		AND b.ProductDisplayName = cyp.ProductDisplayName
	LEFT JOIN #CYQ cyq
		ON	b.OutletKey = cyq.OutletKey
		AND b.Date = cyq.Date
		AND b.Type = cyq.Type
		AND b.ProductDisplayName = cyq.ProductDisplayName
	UNION 
	SELECT   b.OutletKey
			,b.Date
			,b.[Outlet Name]
			,b.[Alpha Code]			
			,b.isWeekDay
			,b.isWeekEnd
			,b.isHoliday	
			,b.[Type]
			,b.ProductDisplayName	AS [Product]
			,pyp.PolicyCount AS [Policy Count]
			,pyp.SellPrice AS [Sell Price]
			,pyp.Commission	AS [Commission]
			,pyp.BasePremimum	AS [Base Premium]
			,pyq.QuoteCount	AS [Quote Count]
			,'YAGO'	AS Label
	FROM #Base b
	LEFT JOIN #PY pyp
		ON	b.OutletKey = pyp.OutletKey
		AND b.Date = pyp.Date
		AND b.Type = pyp.Type
		AND b.ProductDisplayName = pyp.ProductDisplayName
	LEFT JOIN #PYQ pyq
		ON	b.OutletKey = pyq.OutletKey
		AND b.Date = pyq.Date
		AND b.Type = pyq.Type
		AND b.ProductDisplayName = pyq.ProductDisplayName

GO
