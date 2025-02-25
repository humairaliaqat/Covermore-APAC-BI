USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_CBA_SalesPerformance_addons]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[rptsp_CBA_SalesPerformance_addons]		
											
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
--  Change History: 20180829 - ME - Created 
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
				
	SELECT   c.MonthEnd	
			,c.Date
			,AddOnGroup	as [Add-On Group]
			,sum(AddonPolicyCount+BasePolicyCount)	as [Add-on Count]
				
	FROM  #Calendar c   
    inner join [db-au-cba].dbo.penPolicyTransSummary pt on
		c.Date = cast(pt.PostingDate as date)
	inner join [db-au-cba].dbo.penOutlet po on
		pt.OutletAlphaKey = po.OutletAlphaKey
    inner join [db-au-cba].dbo.penPolicyTransAddOn pta on
        pta.PolicyTransactionKey = pt.PolicyTransactionKey	
		
	where po.CountryKey = @Country and
		  po. SuperGroupName = @SuperGroup
	group by c.MonthEnd
			,c.Date
			,AddOnGroup

GO
