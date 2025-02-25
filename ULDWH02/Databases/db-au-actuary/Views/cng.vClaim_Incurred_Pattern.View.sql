USE [db-au-actuary]
GO
/****** Object:  View [cng].[vClaim_Incurred_Pattern]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vClaim_Incurred_Pattern] AS 
/****************************************************************************************************/
--  Name:           vClaim_Incurred_Pattern
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  2024-08-13 Dom MED claims to MIS for AU only         
/****************************************************************************************************/

WITH 
Claim_Header AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Claim_Header]
),

Policy_Header AS (
    SELECT 
         *
        ,[Lead Time]*1.00/([Lead Time]+[Trip Duration]) AS [LeadTime%]
    FROM [db-au-actuary].[cng].[Policy_Header]
),

Claim_Header_01 AS (
    SELECT 
         a.[DomainCountry]
        ,IIF(CAST(b.[Return Date] AS date)<'2023-09-30','Pre','Post') AS [Period]
        ,CASE WHEN b.[Trip Type] IN ('AMT','Cancellation','Single Trip') 
              THEN b.[Trip Type]     
              ELSE 'Single Trip'
         END AS [TripType]
        ,CASE WHEN b.[Plan Type] IN ('Domestic') 
              THEN 'Domestic'
              ELSE 'International'
         END AS [PlanType]
        ,CASE WHEN b.[LeadTime%] < 1.0 AND b.[Trip Type] NOT IN ('AMT','Cancellation')
              THEN CEILING([LeadTime%]*10) 
              ELSE 10
         END AS [LeadTimeGroup]
        ,CASE 
            WHEN CAST(a.[LossDate] AS date) < CAST(b.[Issue Date]     AS date) THEN 0
            WHEN CAST(a.[LossDate] AS date) < CAST(b.[Departure Date] AS date) THEN ROUND(CAST(DATEDIFF(DAY,b.[Issue Date]    ,a.[LossDate]) AS float)/NULLIF(CAST(DATEDIFF(DAY,b.[Issue Date], b.[Departure Date]) AS float),0) * 0.5      ,2)
            WHEN CAST(a.[LossDate] AS date) < CAST(b.[Return Date]    AS date) THEN ROUND(CAST(DATEDIFF(DAY,b.[Departure Date],a.[LossDate]) AS float)/NULLIF(CAST(DATEDIFF(DAY,b.[Departure Date],b.[Return Date]) AS float),0) * 0.5 + 0.5,2)
                                                                               ELSE 1
         END AS [DaysToLoss%Rescale]
        ,CASE
            WHEN b.[Trip Type]             = 'Cancellation'        THEN 'CAN'
          --WHEN b.[Plan Type]             = 'Domestic'
          -- AND a.[ActuarialBenefitGroup] = 'Medical'             THEN 'MIS'
            WHEN a.[DomainCountry]         = 'AU'
             AND b.[Plan Type]             = 'Domestic'
             AND a.[ActuarialBenefitGroup] = 'Medical'             THEN 'MIS'
            WHEN a.[ActuarialBenefitGroup] = 'Additional Expenses' THEN 'ADD'
            WHEN a.[ActuarialBenefitGroup] = 'Cancellation' 
             AND CAST(a.[LossDate] as date)
               > CAST(b.[Departure Date] as date)                  THEN 'ADD'
            WHEN a.[ActuarialBenefitGroup] = 'Cancellation'        THEN 'CAN'
            WHEN a.[ActuarialBenefitGroup] = 'Luggage'             THEN 'LUG'
            WHEN a.[ActuarialBenefitGroup] = 'Medical'             THEN 'MED'
            WHEN a.[ActuarialBenefitGroup] = 'Other'               THEN 'MIS'
                                                                   ELSE 'MIS'
         END AS [Section]
        ,a.[SectionCount]
        ,a.[NetIncurredMovementIncRecoveries]
    FROM      Claim_Header  a
    LEFT JOIN Policy_Header b ON a.[PolicyKey] = b.[PolicyKey] AND a.[ProductCode] = b.[Product Code]

    WHERE CAST(b.[Issue Date]  AS date) >= '2017-06-01'
      AND CAST(b.[Return Date] AS date) >= '2017-06-01' 
      AND CAST(b.[Return Date] AS date) <= '2024-09-30' 
    --AND YEAR(b.[Return Date]) NOT IN ('2020','2021','2022') 
      AND [JV] NOT IN ('BW NAC','CBA NAC') 
      AND [CATCode] NOT IN ('COR')
    --AND [Size50k] = 'Underlying'
),

Summary_01 AS (
    SELECT 
         [DomainCountry]
        ,[Period]
        ,[TripType]
        ,[PlanType]
        ,[LeadTimeGroup]
        ,[DaysToLoss%Rescale]
        ,SUM(CASE WHEN [Section] IN ('ADD') THEN [SectionCount] ELSE 0 END) AS [Sections ADD]
        ,SUM(CASE WHEN [Section] IN ('CAN') THEN [SectionCount] ELSE 0 END) AS [Sections CAN]
        ,SUM(CASE WHEN [Section] IN ('LUG') THEN [SectionCount] ELSE 0 END) AS [Sections LUG]
        ,SUM(CASE WHEN [Section] IN ('MED') THEN [SectionCount] ELSE 0 END) AS [Sections MED]
        ,SUM(CASE WHEN [Section] IN ('MIS') THEN [SectionCount] ELSE 0 END) AS [Sections MIS]
        ,SUM([SectionCount])                                                AS [Sections]
        ,SUM(CASE WHEN [Section] IN ('ADD') THEN [NetIncurredMovementIncRecoveries] ELSE 0 END) AS [Incurred ADD]
        ,SUM(CASE WHEN [Section] IN ('CAN') THEN [NetIncurredMovementIncRecoveries] ELSE 0 END) AS [Incurred CAN]
        ,SUM(CASE WHEN [Section] IN ('LUG') THEN [NetIncurredMovementIncRecoveries] ELSE 0 END) AS [Incurred LUG]
        ,SUM(CASE WHEN [Section] IN ('MED') THEN [NetIncurredMovementIncRecoveries] ELSE 0 END) AS [Incurred MED]
        ,SUM(CASE WHEN [Section] IN ('MIS') THEN [NetIncurredMovementIncRecoveries] ELSE 0 END) AS [Incurred MIS]
        ,SUM([NetIncurredMovementIncRecoveries])                                                AS [Incurred]
    FROM Claim_Header_01
    GROUP BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup],[DaysToLoss%Rescale]
),

Padding AS (
    SELECT [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup],[DaysToLoss%Rescale]
    FROM       (SELECT DISTINCT [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] FROM Claim_Header_01) a
    CROSS JOIN (SELECT (number*1.00)/100 AS [DaysToLoss%Rescale] FROM [master].[dbo].[spt_values] WHERE type = 'p' AND number < 101) b
),

Summary_02 AS (
    SELECT 
         a.[DomainCountry]
        ,a.[Period]
        ,a.[TripType]
        ,a.[PlanType]
        ,a.[LeadTimeGroup]
        ,a.[DaysToLoss%Rescale]
        ,COALESCE(b.[Sections ADD],0) AS [Sections ADD]
        ,COALESCE(b.[Sections CAN],0) AS [Sections CAN]
        ,COALESCE(b.[Sections LUG],0) AS [Sections LUG]
        ,COALESCE(b.[Sections MED],0) AS [Sections MED]
        ,COALESCE(b.[Sections MIS],0) AS [Sections MIS]
        ,COALESCE(b.[Sections]    ,0) AS [Sections]
        ,COALESCE(b.[Incurred ADD],0) AS [Incurred ADD]
        ,COALESCE(b.[Incurred CAN],0) AS [Incurred CAN]
        ,COALESCE(b.[Incurred LUG],0) AS [Incurred LUG]
        ,COALESCE(b.[Incurred MED],0) AS [Incurred MED]
        ,COALESCE(b.[Incurred MIS],0) AS [Incurred MIS]
        ,COALESCE(b.[Incurred]    ,0) AS [Incurred]
    FROM      Padding    a 
    LEFT JOIN Summary_01 b ON a.[DomainCountry] = b.[DomainCountry] AND a.[Period] = b.[Period] AND a.[TripType] = b.[TripType] AND a.[PlanType] = b.[PlanType] AND a.[LeadTimeGroup] = b.[LeadTimeGroup] AND a.[DaysToLoss%Rescale] = b.[DaysToLoss%Rescale]
),

Summary_03 AS (
    SELECT 
         [DomainCountry]
        ,[Period]
        ,[TripType]
        ,[PlanType]
        ,[LeadTimeGroup]
        ,[DaysToLoss%Rescale]

        ,[Sections ADD]
        ,[Sections CAN]
        ,[Sections LUG]
        ,[Sections MED]
        ,[Sections MIS]
        ,[Sections]

        ,[Incurred ADD]
        ,[Incurred CAN]
        ,[Incurred LUG]
        ,[Incurred MED]
        ,[Incurred MIS]
        ,[Incurred]
    FROM Summary_02
)

SELECT TOP 100000
     [DomainCountry]
    ,[Period]
    ,[TripType]
    ,[PlanType]
    ,[LeadTimeGroup]
    ,[DaysToLoss%Rescale]
    ,SUM([Sections ADD]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Sections ADD]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Sections ADD %]
    ,SUM([Sections CAN]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Sections CAN]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Sections CAN %]
    ,SUM([Sections LUG]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Sections LUG]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Sections LUG %]
    ,SUM([Sections MED]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Sections MED]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Sections MED %]
    ,SUM([Sections MIS]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Sections MIS]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Sections MIS %]
    ,SUM([Sections])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Sections])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Sections %]
    ,SUM([Incurred ADD]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred ADD]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred ADD %]
    ,SUM([Incurred CAN]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred CAN]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred CAN %]
    ,SUM([Incurred LUG]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred LUG]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred LUG %]
    ,SUM([Incurred MED]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred MED]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred MED %]
    ,SUM([Incurred MIS]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred MIS]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred MIS %]
    ,SUM([Incurred ADD]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred ADD % Total]
    ,SUM([Incurred CAN]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred CAN % Total]
    ,SUM([Incurred LUG]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred LUG % Total]
    ,SUM([Incurred MED]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred MED % Total]
    ,SUM([Incurred MIS]) OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred MIS % Total]
    ,SUM([Incurred])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup] ORDER BY [DaysToLoss%Rescale])*1.00 / NULLIF(SUM([Incurred])     OVER (PARTITION BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup]),0) AS [Incurred %]
FROM Summary_03
ORDER BY [DomainCountry],[Period],[TripType],[PlanType],[LeadTimeGroup],[DaysToLoss%Rescale]
;
GO
