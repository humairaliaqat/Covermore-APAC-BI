USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0993]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rptsp_rpt0993]		
											@Country NVARCHAR(10)--,
											--@SuperGroup NVARCHAR(MAX)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           RPT0993 - BDM Claim Dashboard
--  Author:         ME
--  Date Created:   20180523
--  Description:    Return Policy and Claim data for certain period  
--
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20180523 - ME - Created 
--					20180717 - ME - Replaced IssueDate with PostingDate, added SellPrice in
--					20180726 - ME - Changed the claculation of policy count and sell price to use penpolicytranssummary only and match the cube
--					20180727 - ME - Took StartDate and EndDate parameter out and assigned them the default values of last 24 months in the SP
--					20180815 - ME - Replaced the clmClaimSummary table in the final select statement with a subquery to calculate the correct claim value
--                  20181210 - DM - Adjusted to be able to run for all Super Groups
/****************************************************************************************************/

--uncomment to debug

	--DECLARE @Country NVARCHAR(10) = 'AU'
	--DECLARE @SuperGroup NVARCHAR(MAX) = 'Flight Centre'

	DECLARE @StartDate DATE = (SELECT CAST(DATEADD(MM,-24,GETDATE()) AS DATE))
	DECLARE @EndDate DATE = (SELECT CAST(GETDATE() AS DATE))

	--20181210 Added Super Group as option
	SELECT	lo.EGMNation     AS Brand,
			lo.FCNation      AS Nation,
			lo.FCArea        AS Area,
			lo.BDMName       AS BDM,
			lo.AlphaCode     AS [Alpha Code],
			lo.OutletName    AS [Outlet Name],	
			lo.SuperGroupName AS [Super Group],	
			o.OutletAlphaKey,
			o.OutletKey
    INTO #Outlets
	FROM   penOutlet o
	INNER JOIN penOutlet lo
		ON o.LatestOutletKey = lo.OutletKey
	WHERE  o.CountryKey = @Country
			AND lo.CountryKey = @Country
			AND o.OutletStatus = 'Current'
			AND lo.OutletStatus = 'Current'
			--AND lo.SuperGroupName = @SuperGroup

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

	SELECT UPPER(dest.Destination) AS Destination,
		   coun.ISO2Code
	INTO #Country
	FROM
		( SELECT Destination,
			     Max(LoadID) AS LoadID
		  FROM   [db-au-star].[dbo].[dimDestination]
		  GROUP  BY Destination) dest
	OUTER APPLY ( SELECT TOP 1 ISO2Code
				  FROM [db-au-star].[dbo].[dimDestination]
				  WHERE LoadID = dest.LoadID
					 AND Destination = dest.Destination) Coun

	SELECT CAST([Date] AS DATE) AS [Date],
		   CAST(EOMONTH([Date]) AS DATE) AS [MonthEnd]
	INTO #Calendar
	FROM Calendar
	WHERE [Date] BETWEEN @StartDate AND @EndDate

	CREATE CLUSTERED INDEX [IX_Date] ON #Calendar
	(
		[Date] ASC
	)

	SELECT   o.[Alpha Code]	
			,dest.Destination	AS Country
			,cal.[Date]		
			,COUNT(*)	AS ClaimCount	
	INTO #Claims				
	FROM #Outlets o
	INNER JOIN (
				select cl.OutletKey
					  ,cl.ReceivedDate
					  ,ce.EventCountryName
				from [db-au-cmdwh].dbo.clmClaim cl  
				inner join [db-au-cmdwh].dbo.clmSection cs on
					cs.ClaimKey = cl.ClaimKey
				left join [db-au-cmdwh].dbo.clmEvent ce on
					ce.EventKey = cs.EventKey
				left join [db-au-cmdwh]..vclmBenefitCategory cbb on
					cbb.BenefitSectionKey = cs.BenefitSectionKey
			   ) clm
		ON clm.OutletKey = o.OutletKey
	INNER JOIN #Calendar cal
		ON CAST(clm.ReceivedDate AS DATE) = cal.[Date]			
	INNER JOIN #Country dest
		ON clm.EventCountryName = dest.Destination	

	GROUP BY o.[Alpha Code]
			,dest.Destination	
			,cal.[Date]
	
	CREATE CLUSTERED INDEX [IX_Date] ON #Claims
	(
		[Date] ASC
	)


	SELECT   o.[Alpha Code]	
			,dest.Destination	AS Country
			,cal.[Date]		
			,SUM(pts.NewPolicyCount)	AS PolicyCount	
			,SUM(pts.GrossPremium)	AS SellPrice

	INTO #Policies				
	FROM #Outlets o
	INNER JOIN penPolicy p
		ON p.OutletAlphaKey = o.OutletAlphaKey
	INNER JOIN penPolicyTransSummary pts
		ON pts.PolicyKey = p.PolicyKey			
	INNER JOIN #Calendar cal
		ON CAST(pts.PostingDate AS DATE) = cal.[Date]	
	OUTER APPLY ( SELECT c.Item AS Country 
					FROM fn_DelimitedSplit8K(p.MultiDestination,';') c
				) d			
	OUTER APPLY ( SELECT *
				  FROM #Country dest
				  WHERE CASE 
							WHEN ISNULL(d.Country,'')='' THEN 'UNKNOWN'	
							ELSE d.Country
							END = dest.Destination
				) dest	
		
	GROUP BY o.[Alpha Code]
			,dest.Destination	
			,cal.[Date]

	CREATE CLUSTERED INDEX [IX_Date] ON #Policies
	(
		[Date] ASC
	)


	SELECT [Alpha Code],
		   Country,
		   [Date]
	INTO #Base
	FROM #Claims
	UNION 
	SELECT [Alpha Code],
		   Country,
		   [Date]
	FROM #Policies

	CREATE CLUSTERED INDEX [IX_Date] ON #Base
	(
		[Date] ASC
	)

	CREATE NONCLUSTERED INDEX [IX_AlphaCode] ON #Base
	(
		[Alpha Code] ASC

	)
	INCLUDE ( 	[Date],	
				[Country]
	) 

	SELECT outlet.*,
		   iso.ISO2Code,
		   b.Country,
		   P.PolicyCount AS [Original Policy Count],
		   clm.ClaimKey,
		   clm.[Claim No],
		   clm.BenefitCategory    AS [Benefit Category],
		   clm.ClaimValue AS [Claim Value],
		   clm.EventDate	AS [Event Date],
		   ISNULL(p.PolicyCount, 0) / (1.0*ISNULL(c.ClaimCount, 1)) AS [Policy Count],
		   ISNULL(p.SellPrice, 0) / (1.0*ISNULL(c.ClaimCount, 1)) AS [Sell Price],
		   b.[Date]
	FROM #Base b
	OUTER APPLY ( SELECT TOP 1  Brand,
					 			Nation,
								Area,
								BDM,
								[Alpha Code],
								[Outlet Name],
								[Super Group]
				  FROM #Outlets
				  WHERE [Alpha Code] = b.[Alpha Code]
				 ) outlet
	OUTER APPLY ( SELECT TOP 1 ISO2Code
				  FROM #Country
				  WHERE Destination = b.Country
				) iso
	OUTER APPLY ( SELECT c.ClaimKey
					,c.ClaimNo		AS [Claim No]
					,c.BenefitCategory
					,c.ClaimValue
					,c.EventCountryName
					,c.EventDate
				FROM (  select        
							cl.ClaimKey, 
							cl.ClaimNo,  
							cl.OutletKey,
							cl.ReceivedDate,
							case
								when cl.FinalisedDate is null then 0
								else 1
							end IsFinalised,
							convert(date, ce.EventDate) EventDate,
							ce.EventCountryName,
							cbb.BenefitCategory,
							(isnull(cp.PaidPayment, 0) + isnull(cp.RecoveredPayment, 0)) * (1 - cs.isDeleted) PaidRecoveredPayment,
							(isnull(cp.PaidPayment, 0) + isnull(cp.RecoveredPayment, 0) + isnull(cs.EstimateValue, 0)) * (1 - cs.isDeleted) ClaimValue						

						from
							[db-au-cmdwh].dbo.clmClaim cl  
							inner join [db-au-cmdwh].dbo.clmSection cs on
								cs.ClaimKey = cl.ClaimKey
							left join [db-au-cmdwh].dbo.clmEvent ce on
								ce.EventKey = cs.EventKey
							left join [db-au-cmdwh]..vclmBenefitCategory cbb on
								cbb.BenefitSectionKey = cs.BenefitSectionKey
							outer apply
							(
								select  
									sum(
										case
											when cp.PaymentStatus = 'PAID' then cp.PaymentAmount
											else 0
										end
									) PaidPayment,
									sum(
										case
											when cp.PaymentStatus = 'RECY' then cp.PaymentAmount
											else 0
										end
									) RecoveredPayment
								from
									[db-au-cmdwh].dbo.clmPayment cp
								where
									cp.SectionKey = cs.SectionKey and
									cp.isDeleted = 0
							) cp	
					 ) c
				INNER JOIN #Outlets o
					ON c.OutletKey = o.OutletKey
				WHERE o.[Alpha Code] = b.[Alpha Code]
				AND CAST(c.ReceivedDate AS DATE) = b.[Date]				
				AND c.EventCountryName =b.Country
			) clm
	OUTER APPLY ( SELECT p.PolicyCount
						,p.SellPrice
				  FROM #Policies p
				  WHERE p.Date = b.Date
					AND p.[Alpha Code] = b.[Alpha Code]
					AND p.Country = b.Country) p
	OUTER APPLY ( SELECT c.ClaimCount
				  FROM #Claims c
				  WHERE c.Date = b.Date
					AND c.[Alpha Code] = b.[Alpha Code]
					AND c.Country = b.Country) c
GO
