USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_RPT1041_Test_INC0319227]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[rptsp_RPT1041_Test_INC0319227]   
	@DateRange varchar(30),
	@StartDate varchar(10),
	@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           RPT1041 - Zurich Report for ICNZ
--  Author:         Mercede Edrisi
--  Date Created:   20190116
--  Description:    This stored procedure returns sales and claims data for reporting to ICNZ
--  Parameters:     @DateRange: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2018-07-01
--					@EndDate  : if_User Defined. Format: YYYY-MM-DD eg. 2018-07-01
--   
--  Change History: 20190116 - ME - Created
--
   
/****************************************************************************************************/

--DECLARE
--	@DateRange varchar(30),
--	@StartDate varchar(10),
--	@EndDate varchar(10)
--	SET @DateRange = 'Month-To-Date'

declare @rptStartDate date
declare @rptEndDate date


--get reporting dates
if @DateRange = '_User Defined'
	select 
		@rptStartDate = @StartDate,
		@rptEndDate = @EndDate
else
	select 
		@rptStartDate = StartDate, 
		@rptEndDate = EndDate
	from 
		vDateRange
	where 
		DateRange = @DateRange

DECLARE @rptDayAfterEndDate DATE = (SELECT DATEADD(DAY, 1, @rptEndDate))

-- Report on Gross Written Premimum
IF OBJECT_ID('tempdb..#Premium') IS NOT NULL
  DROP TABLE #Premium

SELECT *
INTO   #Premium
FROM   (SELECT CASE 					
					WHEN AreaType = 'International'	THEN 'Outbound Leisure'
					WHEN AreaType = 'Domestic (Inbound)'	THEN 'Incoming Travelers'
					WHEN AreaType = 'Domestic'	THEN 'Other'
			   END AS [Group],
               Sum(pt.Premium) AS Premium,
			   SUM(pt.SellPrice) AS SellPrice
        FROM   [db-au-star].[dbo].[factPolicyTransaction] pt
               INNER JOIN [db-au-star].[dbo].dimDomain d
                       ON d.DomainSK = pt.DomainSK
               INNER JOIN [db-au-star].[dbo].dimArea a
                       ON pt.AreaSK = a.AreaSK
        WHERE  d.CountryCode = 'NZ'
               AND pt.PostingDate >= @rptStartDate
               AND pt.PostingDate < @rptDayAfterEndDate
               AND pt.UnderwriterCode = 'ZURICH'
        GROUP  BY CASE 					
					WHEN AreaType = 'International'	THEN 'Outbound Leisure'
					WHEN AreaType = 'Domestic (Inbound)'	THEN 'Incoming Travelers'
					WHEN AreaType = 'Domestic'	THEN 'Other'
				  END
        UNION ALL
        SELECT 'Corporate',
               Sum(c.Premium),
			   SUM(c.SellPrice)
        FROM   [db-au-star].[dbo].[factCorporate] c
               INNER JOIN [db-au-star].[dbo].dimDomain d
                       ON d.DomainSK = c.DomainSK
        WHERE  d.CountryCode = 'NZ'
               AND c.IssueDate >= @rptStartDate
               AND c.IssueDate < @rptDayAfterEndDate
               AND c.UnderwriterCode = 'ZURICH') res

-- Report on Claims Incurred
IF Object_id('tempdb..#incurred') IS NOT NULL
  DROP TABLE #incurred

SELECT cim.EstimateMovement,
       cim.PaymentMovement,
       cim.RecoveryMovement,
       cim.EstimateMovement + cim.PaymentMovement
       + cim.RecoveryMovement    IncurredMovement,
       cim.NetPaymentMovement,
       cim.NetRecoveryMovement,
       cim.NetPaymentMovement
       + cim.NetRecoveryMovement NetPaymentMovementIncRecoveries,
       cim.NetPaymentMovement
       + cim.NetRecoveryMovement
       + cim.EstimateMovement    NetIncurredMovement,
       cim.NetRealRecoveryMovement,
       cim.NetApprovedPaymentMovement,
       cim.OutletKey,
       cim.IssueDate,
       cim.ClaimProduct,
       cim.ReceiptDate,
       cim.PolicyKey
INTO   #incurred
FROM   [db-au-actuary].ws.ClaimIncurredMovement cim WITH(nolock)
WHERE  cim.[Domain Country] = 'NZ'
       AND cim.IncurredTime >= @rptStartDate
       AND cim.IncurredTime < @rptDayAfterEndDate 

IF Object_id('tempdb..#IncurredRes') IS NOT NULL
  DROP TABLE #IncurredRes
SELECT CASE 
			WHEN ClaimProduct = 'CMC'	THEN 'Corporate'
			WHEN AreaType = 'International'	THEN 'Outbound Leisure'
			WHEN AreaType = 'Domestic (Inbound)'	THEN 'Incoming Travelers'
			WHEN AreaType = 'Domestic'	THEN 'Other'
	   END AS [Group],
	   SUM(IncurredMovement) AS [Incurred],
	   SUM(NetIncurredMovement) AS [Net Incurred]
INTO #IncurredRes
FROM
	(
		SELECT t.*,
			   [db-au-cmdwh].dbo.Fn_getunderwritercode('CM', 'NZ', o.AlphaCode, IssueDate) Underwriter,
			   p.*
		FROM   #incurred t
			   OUTER apply(SELECT TOP 1 o.AlphaCode
						   FROM   [db-au-cmdwh]..penOutlet o WITH(nolock)
						   WHERE  o.OutletKey = t.OutletKey
								  AND o.OutletStatus = 'Current') o
			   OUTER apply(SELECT TOP 1 p.AreaType
						   FROM   [db-au-cmdwh]..penPolicy p WITH(nolock)
						   WHERE  p.PolicyKey = t.PolicyKey) p 
	) r
WHERE r.Underwriter = 'ZURICH'
GROUP BY CASE 
			WHEN ClaimProduct = 'CMC'	THEN 'Corporate'
			WHEN AreaType = 'International'	THEN 'Outbound Leisure'
			WHEN AreaType = 'Domestic (Inbound)'	THEN 'Incoming Travelers'
			WHEN AreaType = 'Domestic'	THEN 'Other'
		 END


-- Claim Numbers
IF Object_id('tempdb..#Received') IS NOT NULL
  DROP TABLE #Received

SELECT cim.EstimateMovement,
       cim.PaymentMovement,
       cim.RecoveryMovement,
       cim.EstimateMovement + cim.PaymentMovement
       + cim.RecoveryMovement    IncurredMovement,
       cim.NetPaymentMovement,
       cim.NetRecoveryMovement,
       cim.NetPaymentMovement
       + cim.NetRecoveryMovement NetPaymentMovementIncRecoveries,
       cim.NetPaymentMovement
       + cim.NetRecoveryMovement
       + cim.EstimateMovement    NetIncurredMovement,
       cim.NetRealRecoveryMovement,
       cim.NetApprovedPaymentMovement,
       cim.OutletKey,
       cim.IssueDate,
       cim.ClaimProduct,
       cim.ReceiptDate,
       cim.PolicyKey,
	   cim.ClaimKey,
	   cim.ClaimNo
INTO   #Received
FROM   [db-au-actuary].ws.ClaimIncurredMovement cim WITH(nolock)
WHERE  cim.[Domain Country] = 'NZ'
       AND cim.ReceiptDate >= @rptStartDate
       AND cim.ReceiptDate < @rptDayAfterEndDate 

IF Object_id('tempdb..#ClaimsReceived') IS NOT NULL
  DROP TABLE #ClaimsReceived
SELECT CASE 
			WHEN ClaimProduct = 'CMC'	THEN 'Corporate'
			WHEN AreaType = 'International'	THEN 'Outbound Leisure'
			WHEN AreaType = 'Domestic (Inbound)'	THEN 'Incoming Travelers'
			WHEN AreaType = 'Domestic'	THEN 'Other'
	   END AS [Group],
	   COUNT(DISTINCT ClaimKey)	AS [Claim Count]
INTO #ClaimsReceived
FROM
	(
		SELECT t.*,
			   [db-au-cmdwh].dbo.Fn_getunderwritercode('CM', 'NZ', o.AlphaCode, IssueDate) Underwriter,
			   p.*
		FROM   #Received t
			   OUTER apply(SELECT TOP 1 o.AlphaCode
						   FROM   [db-au-cmdwh]..penOutlet o WITH(nolock)
						   WHERE  o.OutletKey = t.OutletKey
								  AND o.OutletStatus = 'Current') o
			   OUTER apply(SELECT TOP 1 p.AreaType
						   FROM   [db-au-cmdwh]..penPolicy p WITH(nolock)
						   WHERE  p.PolicyKey = t.PolicyKey) p 
	) r
WHERE r.Underwriter = 'ZURICH'
GROUP BY CASE 
			WHEN ClaimProduct = 'CMC'	THEN 'Corporate'
			WHEN AreaType = 'International'	THEN 'Outbound Leisure'
			WHEN AreaType = 'Domestic (Inbound)'	THEN 'Incoming Travelers'
			WHEN AreaType = 'Domestic'	THEN 'Other'
		 END


SELECT base.[Group],
       p.Premium,
	   p.SellPrice AS [Sell Price],
       c.[Claim Count],
       i.Incurred,
	   i.[Net Incurred],
	   @rptStartDate AS [Start Date],
	   @rptEndDate AS [End Date]
FROM   (SELECT item AS [Group]
        FROM   [db-au-cmdwh].dbo.Fn_delimitedsplit8k('Outbound Leisure,Incoming travelers,Corporate,Other', ',')) base
       LEFT JOIN #Premium p
              ON p.[Group] = base.[Group]
       LEFT JOIN #ClaimsReceived c
              ON c.[Group] = base.[Group]
       LEFT JOIN #IncurredRes i
              ON i.[Group] = base.[Group]

GO
