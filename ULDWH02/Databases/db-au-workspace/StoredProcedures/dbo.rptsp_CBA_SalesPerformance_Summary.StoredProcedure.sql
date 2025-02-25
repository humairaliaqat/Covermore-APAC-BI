USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_CBA_SalesPerformance_Summary]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[rptsp_CBA_SalesPerformance_Summary]		
											
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

	SELECT CAST(d.Date AS DATE) as [Date],		
		   o.OutletAlphaKey,	
		   o.AlphaCode,
		   o.OutletName,	   
		   SUM(t.BudgetAmount) AS BudgetAmount

	INTO #Target
	FROM [db-au-cba].[dbo].[factPolicyTarget] t
		INNER JOIN [db-au-cba].[dbo].dimOutlet o
			ON t.OutletSK = o.OutletSK	
		INNER JOIN [db-au-cba].[dbo].Dim_Date d
			ON t.DateSK = d.[Date_SK]
	WHERE o.SuperGroupName = @SuperGroup
		AND o.Country = @Country
		AND CAST(d.Date AS DATE) BETWEEN @StartDate AND @EndDate
	
	GROUP BY CAST(d.Date AS DATE),		
			   o.OutletAlphaKey,	
			   o.AlphaCode,
			   o.OutletName

	CREATE CLUSTERED INDEX [IX_Date] ON #Target
	(
		[Date] ASC
	)
		
	SELECT   c.MonthEnd	
			,c.Date
			,c.isWeekDay
			,c.isHoliday
			,c.isWeekEnd
			,t.AlphaCode	AS [Alpha Code]				
			,t.OutletName	AS [Outlet Name]
			,t.BudgetAmount	AS [Target]
			,cy.PolicyCount AS [Policy Count]
			,cy.SellPrice	AS [Sell Price]
			,py.PolicyCount	AS [YAGO Policy Count]
			,py.SellPrice	AS [YAGO Sell Price]
				
	FROM  #Target t
	INNER JOIN #Calendar c
		ON t.Date = c.Date
	OUTER APPLY (	SELECT   SUM(pts.NewPolicyCount)	AS PolicyCount	
							,SUM(pts.GrossPremium)	AS SellPrice
					FROM  [db-au-cba].dbo.penPolicy p						
					INNER JOIN [db-au-cba].dbo.penPolicyTransSummary pts
						ON pts.PolicyKey = p.PolicyKey		
					WHERE CAST(pts.PostingDate AS DATE) = t.Date	
						AND p.OutletAlphaKey = t.OutletAlphaKey ) cy

	OUTER APPLY (	SELECT   SUM(pts.NewPolicyCount)	AS PolicyCount	
							,SUM(pts.GrossPremium)	AS SellPrice
					FROM  [db-au-cba].dbo.penPolicy p						
					INNER JOIN [db-au-cba].dbo.penPolicyTransSummary pts
						ON pts.PolicyKey = p.PolicyKey		
					WHERE CAST(pts.PostingDate AS DATE) = DATEADD(YEAR,-1,t.Date)	
						AND p.OutletAlphaKey = t.OutletAlphaKey ) py
								
			

GO
