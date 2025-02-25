USE [db-au-actuary]
GO
/****** Object:  View [cng].[vPolicy_Month_Exposure]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vPolicy_Month_Exposure] AS 

/****************************************************************************************************/
--  Name:           vPolicy_Month_Exposure
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  
/****************************************************************************************************/

WITH 
Months AS (
    SELECT DATEADD(month,number,'2017-06-01') AS [Month]
    FROM [master].[dbo].[spt_values]
    WHERE type = 'p' AND number <= 120
),

Policy_Header AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Policy_Header]
    --WHERE [PolicyKey] = 'AU-CM7-19226071'
),

Claim_Header AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Claim_Header]
),

Claim_Incurred_Pattern AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[vClaim_Incurred_Pattern]
),

Policy_Header_01 AS (
    SELECT 
         [PolicyKey]
        ,[Domain Country]
        ,[Policy Status]
        ,[Policy Status Detailed]
        ,[JV Code]
        ,[JV Description]
        ,[Outlet Channel]
        ,[Product Code]
        ,[Plan Code]
        ,[Product Plan]
        ,[Product Group]
        ,[Policy Type]
        ,[Trip Type]
        ,CASE WHEN [Trip Type] IN ('AMT','Cancellation','Single Trip') 
              THEN [Trip Type]
              ELSE 'Single Trip'
         END AS [Trip Type Earning]
        ,CASE WHEN [Domain Country] = 'AU' AND [Plan Type] = 'International' AND [Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
              WHEN [Domain Country] = 'NZ' AND [Plan Type] = 'International' AND [Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
              ELSE [Plan Type]
         END AS [Plan Type]
        ,CASE WHEN [Plan Type] IN ('Domestic') 
              THEN 'Domestic'
              ELSE 'International'
         END AS [Plan Type Earning]
        ,CASE WHEN ([Addon Count Cancel For Any Reason] > 0 OR [Gross Premium Cancel For Any Reason] > 0)
              THEN 'Yes'
              ELSE 'No'
         END AS [CFAR Flag]

        ,[Issue Date]
        ,[Departure Date]
        ,[Return Date]
        ,IIF(CAST([Return Date] AS date)<'2022-01-01','Pre','Post') AS [Period]
        ,[Lead Time]
        ,[Trip Duration]
        ,[Lead Time]*1.00/([Lead Time]+[Trip Duration]) AS [Lead Time %]

        ,[Policy Count]
        ,COALESCE([Sell Price - Active]   ,[Sell Price]) AS [Sell Price - Active]
        ,COALESCE([Sell Price - Cancelled],0           ) AS [Sell Price - Cancelled]
        ,COALESCE([Sell Price - Total]    ,[Sell Price]) AS [Sell Price]
        ,COALESCE([Premium - Active]      ,[Premium]   ) AS [Premium - Active]
        ,COALESCE([Premium - Cancelled]   ,0           ) AS [Premium - Cancelled]
        ,COALESCE([Premium - Total]       ,[Premium]   ) AS [Premium]
        ,[Agency Commission]
        ,[NAP]
        ,[GST on Sell Price]
        ,[Stamp Duty on Sell Price]
        ,[GST on Agency Commission]
        ,[Stamp Duty on Agency Commission]

        ,[UW Rating Group]
        ,[UW JV Description Orig]
        ,COALESCE([UW Policy Status],'Not in UW Returns') AS [UW Policy Status]

        ,IIF([JV Description] IN ('CBA NAC','BW NAC'),0,[UW Premium]        ) AS [UW Premium]
        ,IIF([JV Description] IN ('CBA NAC','BW NAC'),0,[UW Premium COVID19]) AS [UW Premium COVID19]
        ,CASE WHEN CAST([Issue Date] AS date) >= '2021-01-01'
              THEN IIF([JV Description] IN ('CBA NAC','BW NAC'),0,[UW Premium]) * 0.8800
              ELSE IIF([JV Description] IN ('CBA NAC','BW NAC'),0,[UW Premium]) * 0.9275
         END AS [Target Cost]
        ,CASE WHEN CAST([Issue Date] AS date) >= '2021-01-01'
              THEN IIF([JV Description] IN ('CBA NAC','BW NAC'),0,[UW Premium COVID19]) * 0.8800
              ELSE IIF([JV Description] IN ('CBA NAC','BW NAC'),0,[UW Premium COVID19]) * 0.9275
         END AS [Target Cost COVID19]

        ,[GLM Freq ADD]
        ,[GLM Freq CAN]
        ,[GLM Freq LUG]
        ,[GLM Freq MED]
        ,[GLM Freq MIS]
        ,[GLM Freq UDL]
        ,[GLM Size ADD]
        ,[GLM Size CAN]
        ,[GLM Size LUG]
        ,[GLM Size MED]
        ,[GLM Size LGE]
        ,[GLM Size MIS]
        ,[GLM Size ULD]
        ,[GLM CPP ADD]
        ,[GLM CPP CAN]
        ,[GLM CPP LUG]
        ,[GLM CPP MED]
        ,[GLM CPP LGE]
        ,[GLM CPP MIS]
        ,[GLM CPP UDL]
        ,[GLM CPP CAT]
        ,[GLM CPP]
        ,[GLM UWP ADD]
        ,[GLM UWP CAN]
        ,[GLM UWP LUG]
        ,[GLM UWP MED]
        ,[GLM UWP LGE]
        ,[GLM UWP MIS]
        ,[GLM UWP UDL]
        ,[GLM UWP CAT]
        ,[GLM UWP]
    FROM Policy_Header
),

pmth_01 AS (
    SELECT 
         b.*
        ,CASE WHEN b.[Lead Time %] < 1.0 AND b.[Trip Type] NOT IN ('AMT','Cancellation')
              THEN CEILING(b.[Lead Time %]*10) 
              ELSE 10
         END AS [Lead Time Group]
        ,a.[Month] AS [Exposure Month]
        ,CASE WHEN b.[Issue Date] <= b.[Departure Date] 
              THEN DATEDIFF(month,b.[Issue Date]    ,a.[Month])
              ELSE DATEDIFF(month,b.[Departure Date],a.[Month])
         END AS [Issue Development Month]
        ,CASE WHEN b.[Issue Date]              > b.[Departure Date]         THEN 0
              WHEN EOMONTH(b.[Issue Date])     = EOMONTH(a.[Month])
               AND EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Issue Date],b.[Departure Date])
              WHEN EOMONTH(b.[Issue Date])     = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Issue Date],EOMONTH(a.[Month]))+1
              WHEN EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])         THEN DATEDIFF(day,a.[Month]     ,b.[Departure Date])
              WHEN a.[Month] BETWEEN b.[Issue Date] AND b.[Departure Date]  THEN DATEDIFF(day,a.[Month]     ,EOMONTH(a.[Month]))+1
                                                                            ELSE 0
         END AS [Lead Days]
        ,CASE WHEN EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])
               AND EOMONTH(b.[Return Date])    = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Departure Date],b.[Return Date]   )+1
              WHEN EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Departure Date],EOMONTH(a.[Month]))+1
              WHEN EOMONTH(b.[Return Date]   ) = EOMONTH(a.[Month])         THEN DATEDIFF(day,a.[Month]         ,b.[Return Date]   )+1
              WHEN a.[Month] BETWEEN b.[Departure Date] AND b.[Return Date] THEN DATEDIFF(day,a.[Month]         ,EOMONTH(a.[Month]))+1
                                                                            ELSE 0
         END AS [Trip Days]
    FROM months           a
    JOIN Policy_Header_01 b ON (CAST(b.[Issue Date]     AS date) <= EOMONTH(a.[Month])  OR 
                                CAST(b.[Departure Date] AS date) <= EOMONTH(a.[Month])) AND 
                                CAST(b.[Return Date]    AS date) >= a.[Month]

),

pmth_02 AS (
    SELECT
         *
        ,CASE 
            WHEN [Lead Time] > 0                THEN CAST([Lead Days] AS float)/[Lead Time]
            WHEN [Issue Development Month] = 0  THEN 1
                                                ELSE 0
         END AS [Lead Days %]
        ,CASE
            WHEN [Trip Duration] > 0            THEN CAST([Trip Days] AS float)/[Trip Duration]
            WHEN [Issue Development Month] = 0  THEN 1
                                                ELSE 0
         END AS [Trip Days %]
    FROM pmth_01
),

pmth_03 AS (
    SELECT
         *
        ,[Lead Days %] * 0.5 + [Trip Days %] * 0.5                                                                                        AS [Policy Time %]
        ,SUM([Lead Days %])                             OVER (PARTITION BY [PolicyKey],[Product Code] ORDER BY [Issue Development Month]) AS [Lead Days % Total]
        ,SUM([Trip Days %])                             OVER (PARTITION BY [PolicyKey],[Product Code] ORDER BY [Issue Development Month]) AS [Trip Days % Total]
        ,SUM([Lead Days %] * 0.5 + [Trip Days %] * 0.5) OVER (PARTITION BY [PolicyKey],[Product Code] ORDER BY [Issue Development Month]) AS [Policy Time % Total]
    FROM pmth_02
),

pmth_04 AS (
    SELECT 
         a.*
        ,b.[Sections ADD %]
        ,b.[Sections CAN %]
        ,b.[Sections LUG %]
        ,b.[Sections MED %]
        ,b.[Sections MIS %]
        ,b.[Sections %]
        ,b.[Incurred ADD %]
        ,b.[Incurred CAN %]
        ,b.[Incurred LUG %]
        ,b.[Incurred MED %]
        ,b.[Incurred MIS %]
        ,b.[Incurred ADD % Total]
        ,b.[Incurred CAN % Total]
        ,b.[Incurred LUG % Total]
        ,b.[Incurred MED % Total]
        ,b.[Incurred MIS % Total]
        ,b.[Incurred %]
        ,b.[Sections ADD %]       - COALESCE(LAG(b.[Sections ADD %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Policy ADD %]
        ,b.[Sections CAN %]       - COALESCE(LAG(b.[Sections CAN %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Policy CAN %]
        ,b.[Sections LUG %]       - COALESCE(LAG(b.[Sections LUG %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Policy LUG %]
        ,b.[Sections MED %]       - COALESCE(LAG(b.[Sections MED %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Policy MED %]
        ,b.[Sections MIS %]       - COALESCE(LAG(b.[Sections MIS %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Policy MIS %]
        ,b.[Sections %]           - COALESCE(LAG(b.[Sections %])           OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Policy %]
        ,b.[Incurred ADD %]       - COALESCE(LAG(b.[Incurred ADD %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium ADD %]
        ,b.[Incurred CAN %]       - COALESCE(LAG(b.[Incurred CAN %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium CAN %]
        ,b.[Incurred LUG %]       - COALESCE(LAG(b.[Incurred LUG %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium LUG %]
        ,b.[Incurred MED %]       - COALESCE(LAG(b.[Incurred MED %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium MED %]
        ,b.[Incurred MIS %]       - COALESCE(LAG(b.[Incurred MIS %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium MIS %]
        ,b.[Incurred ADD % Total] - COALESCE(LAG(b.[Incurred ADD % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium ADD % Total]
        ,b.[Incurred CAN % Total] - COALESCE(LAG(b.[Incurred CAN % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium CAN % Total]
        ,b.[Incurred LUG % Total] - COALESCE(LAG(b.[Incurred LUG % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium LUG % Total]
        ,b.[Incurred MED % Total] - COALESCE(LAG(b.[Incurred MED % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium MED % Total]
        ,b.[Incurred MIS % Total] - COALESCE(LAG(b.[Incurred MIS % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium MIS % Total]
        ,b.[Incurred %]           - COALESCE(LAG(b.[Incurred %])           OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0) AS [Earned Premium %]

    FROM      pmth_03 a
    LEFT JOIN Claim_Incurred_Pattern b 
        ON  a.[Domain Country]                  = b.[DomainCountry]
        AND a.[Period]                          = b.[Period]
        AND a.[Trip Type Earning]               = b.[TripType]
        AND a.[Plan Type Earning]               = b.[PlanType]
        AND a.[Lead Time Group]                 = b.[LeadTimeGroup]
        AND ROUND(a.[Policy Time % Total],2)    = b.[DaysToLoss%Rescale]

),

pmth_05 AS (
    SELECT
         [PolicyKey]
        ,[Domain Country]
        ,[Policy Status]
        ,[Policy Status Detailed]
        ,[JV Code]
        ,[JV Description]
        ,[Outlet Channel]
        ,[Product Code]
        ,[Plan Code]
        ,[Product Plan]
        ,[Product Group]
        ,[Policy Type]
        ,[Trip Type]
        ,[Trip Type Earning]
        ,[Plan Type]
        ,[Plan Type Earning]
        ,[CFAR Flag]

        ,[Issue Date]
        ,[Departure Date]
        ,[Return Date]
        ,[Period]
        ,[Lead Time]
        ,[Trip Duration]
        ,[Lead Time %]
        ,[Lead Time Group]

        ,[Policy Count]
        ,[Sell Price - Active]
        ,[Sell Price - Cancelled]
        ,[Sell Price]
        ,[Premium - Active]
        ,[Premium - Cancelled]
        ,[Premium]
        ,[Agency Commission]
        ,[NAP]
        ,[GST on Sell Price]
        ,[Stamp Duty on Sell Price]
        ,[GST on Agency Commission]
        ,[Stamp Duty on Agency Commission]

        ,[UW Rating Group]
        ,[UW JV Description Orig]
        ,[UW Policy Status]

        ,[UW Premium]
        ,[UW Premium COVID19]
        ,[Target Cost]
        ,[Target Cost COVID19]

        ,[GLM Freq ADD]
        ,[GLM Freq CAN]
        ,[GLM Freq LUG]
        ,[GLM Freq MED]
        ,[GLM Freq MIS]
        ,[GLM Freq UDL]
        ,[GLM Size ADD]
        ,[GLM Size CAN]
        ,[GLM Size LUG]
        ,[GLM Size MED]
        ,[GLM Size LGE]
        ,[GLM Size MIS]
        ,[GLM Size ULD]
        ,[GLM CPP ADD]
        ,[GLM CPP CAN]
        ,[GLM CPP LUG]
        ,[GLM CPP MED]
        ,[GLM CPP LGE]
        ,[GLM CPP MIS]
        ,[GLM CPP UDL]
        ,[GLM CPP CAT]
        ,[GLM CPP]
        ,[GLM UWP ADD]
        ,[GLM UWP CAN]
        ,[GLM UWP LUG]
        ,[GLM UWP MED]
        ,[GLM UWP LGE]
        ,[GLM UWP MIS]
        ,[GLM UWP UDL]
        ,[GLM UWP CAT]
        ,[GLM UWP]

        ,[Exposure Month]
        ,[Issue Development Month]
        ,[Lead Days]
        ,[Trip Days]
        ,[Lead Days %]
        ,[Trip Days %]
        ,[Policy Time %]
        ,[Lead Days % Total]
        ,[Trip Days % Total]
        ,[Policy Time % Total]

        ,[Sections ADD %]
        ,[Sections CAN %]
        ,[Sections LUG %]
        ,[Sections MED %]
        ,[Sections MIS %]
        ,[Sections %]
        ,[Incurred ADD %]
        ,[Incurred CAN %]
        ,[Incurred LUG %]
        ,[Incurred MED %]
        ,[Incurred MIS %]
        ,[Incurred ADD % Total]
        ,[Incurred CAN % Total]
        ,[Incurred LUG % Total]
        ,[Incurred MED % Total]
        ,[Incurred MIS % Total]
        ,[Incurred %]

        ,[Earned Policy ADD %]
        ,[Earned Policy CAN %]
        ,[Earned Policy LUG %]
        ,[Earned Policy MED %]
        ,[Earned Policy MIS %]
        ,[Earned Policy %]
        ,[Earned Premium ADD %]
        ,[Earned Premium CAN %]
        ,[Earned Premium LUG %]
        ,[Earned Premium MED %]
        ,[Earned Premium MIS %]
        ,[Earned Premium ADD % Total]
        ,[Earned Premium CAN % Total]
        ,[Earned Premium LUG % Total]
        ,[Earned Premium MED % Total]
        ,[Earned Premium MIS % Total]
        ,[Earned Premium %]
        ,CASE WHEN [Trip Type]   IN ('Cancellation')                                                 THEN ([Lead Days] * 1.00 + [Trip Days] * 0.01)/([Lead Time] * 1.00 + [Trip Duration] * 0.01)
              WHEN [Policy Type] IN ('Car Hire','Corporate')                                         THEN ([Lead Days] * 0.01 + [Trip Days] * 1.00)/([Lead Time] * 0.01 + [Trip Duration] * 1.00)
              WHEN [Trip Type]     IN ('AMT') AND [Plan Type]     IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 3.00 + [Trip Days] * 1.00)/([Lead Time] * 3.00 + [Trip Duration] * 1.00)
              WHEN [Trip Type]     IN ('AMT') AND [Plan Type] NOT IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 1.00 + [Trip Days] * 1.00)/([Lead Time] * 1.00 + [Trip Duration] * 1.00)
              WHEN [Trip Type] NOT IN ('AMT') AND [Plan Type]     IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 1.00 + [Trip Days] * 4.00)/([Lead Time] * 1.00 + [Trip Duration] * 4.00)
              WHEN [Trip Type] NOT IN ('AMT') AND [Plan Type] NOT IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 1.00 + [Trip Days] * 10.0)/([Lead Time] * 1.00 + [Trip Duration] * 10.0)
                                                                                                     ELSE ([Lead Days] * 1.00 + [Trip Days] * 1.00)/([Lead Time] * 1.00 + [Trip Duration] * 1.00)
         END AS [Refund Premium %]

        ,NULL AS [ClaimKey]
        ,NULL AS [SectionID]
        ,NULL AS [ActuarialBenefitGroup]
        ,NULL AS [Section]
        ,NULL AS [ClaimCount]
        ,NULL AS [SectionCount]
        ,NULL AS [SectionCountNonNil]
        ,NULL AS [NetPaymentMovementIncRecoveries]
        ,NULL AS [NetIncurredMovementIncRecoveries]
    FROM pmth_04
),

chdr_01 AS (
    SELECT
         a.[PolicyKey]
        ,a.[DomainCountry] AS [Domain Country]
        ,b.[Policy Status]
        ,b.[Policy Status Detailed]
        ,b.[JV Code]
        ,b.[JV Description]
        ,b.[Outlet Channel]
        ,b.[Product Code]
        ,b.[Plan Code]
        ,b.[Product Plan]
        ,b.[Product Group]
        ,b.[Policy Type]
        ,b.[Trip Type]
        ,b.[Trip Type Earning]
        ,b.[Plan Type]
        ,b.[Plan Type Earning]
        ,b.[CFAR Flag]

        ,b.[Issue Date]
        ,b.[Departure Date]
        ,b.[Return Date]
        ,b.[Period]
        ,b.[Lead Time]
        ,b.[Trip Duration]
        ,b.[Lead Time %]
        ,CASE WHEN b.[Lead Time %] < 1.0 AND b.[Trip Type] NOT IN ('AMT','Cancellation')
              THEN CEILING(b.[Lead Time %]*10) 
              ELSE 10
         END AS [Lead Time Group]

        ,b.[Policy Count]
        ,b.[Sell Price - Active]
        ,b.[Sell Price - Cancelled]
        ,b.[Sell Price]
        ,b.[Premium - Active]
        ,b.[Premium - Cancelled]
        ,b.[Premium]
        ,b.[Agency Commission]
        ,b.[NAP]
        ,b.[GST on Sell Price]
        ,b.[Stamp Duty on Sell Price]
        ,b.[GST on Agency Commission]
        ,b.[Stamp Duty on Agency Commission]

        ,b.[UW Rating Group]
        ,b.[UW JV Description Orig]
        ,b.[UW Policy Status]

        ,b.[UW Premium]
        ,b.[UW Premium COVID19]
        ,b.[Target Cost]
        ,b.[Target Cost COVID19]

        ,b.[GLM Freq ADD]
        ,b.[GLM Freq CAN]
        ,b.[GLM Freq LUG]
        ,b.[GLM Freq MED]
        ,b.[GLM Freq MIS]
        ,b.[GLM Freq UDL]
        ,b.[GLM Size ADD]
        ,b.[GLM Size CAN]
        ,b.[GLM Size LUG]
        ,b.[GLM Size MED]
        ,b.[GLM Size LGE]
        ,b.[GLM Size MIS]
        ,b.[GLM Size ULD]
        ,b.[GLM CPP ADD]
        ,b.[GLM CPP CAN]
        ,b.[GLM CPP LUG]
        ,b.[GLM CPP MED]
        ,b.[GLM CPP LGE]
        ,b.[GLM CPP MIS]
        ,b.[GLM CPP UDL]
        ,b.[GLM CPP CAT]
        ,b.[GLM CPP]
        ,b.[GLM UWP ADD]
        ,b.[GLM UWP CAN]
        ,b.[GLM UWP LUG]
        ,b.[GLM UWP MED]
        ,b.[GLM UWP LGE]
        ,b.[GLM UWP MIS]
        ,b.[GLM UWP UDL]
        ,b.[GLM UWP CAT]
        ,b.[GLM UWP]

        ,a.[LossMonth] AS [Exposure Month]
        ,CASE WHEN b.[Issue Date] <= b.[Departure Date] 
              THEN DATEDIFF(month,b.[Issue Date]    ,a.[LossDate])
              ELSE DATEDIFF(month,b.[Departure Date],a.[LossDate])
         END AS [Issue Development Month]
        ,NULL AS [Lead Days]
        ,NULL AS [Trip Days]
        ,NULL AS [Lead Days %]
        ,NULL AS [Trip Days %]
        ,NULL AS [Policy Time %]
        ,NULL AS [Lead Days % Total]
        ,NULL AS [Trip Days % Total]
        ,NULL AS [Policy Time % Total]

        ,NULL AS [Sections ADD %]
        ,NULL AS [Sections CAN %]
        ,NULL AS [Sections LUG %]
        ,NULL AS [Sections MED %]
        ,NULL AS [Sections MIS %]
        ,NULL AS [Sections %]
        ,NULL AS [Incurred ADD %]
        ,NULL AS [Incurred CAN %]
        ,NULL AS [Incurred LUG %]
        ,NULL AS [Incurred MED %]
        ,NULL AS [Incurred MIS %]
        ,NULL AS [Incurred ADD % Total]
        ,NULL AS [Incurred CAN % Total]
        ,NULL AS [Incurred LUG % Total]
        ,NULL AS [Incurred MED % Total]
        ,NULL AS [Incurred MIS % Total]
        ,NULL AS [Incurred %]

        ,NULL AS [Earned Policy ADD %]
        ,NULL AS [Earned Policy CAN %]
        ,NULL AS [Earned Policy LUG %]
        ,NULL AS [Earned Policy MED %]
        ,NULL AS [Earned Policy MIS %]
        ,NULL AS [Earned Policy %]
        ,NULL AS [Earned Premium ADD %]
        ,NULL AS [Earned Premium CAN %]
        ,NULL AS [Earned Premium LUG %]
        ,NULL AS [Earned Premium MED %]
        ,NULL AS [Earned Premium MIS %]
        ,NULL AS [Earned Premium ADD % Total]
        ,NULL AS [Earned Premium CAN % Total]
        ,NULL AS [Earned Premium LUG % Total]
        ,NULL AS [Earned Premium MED % Total]
        ,NULL AS [Earned Premium MIS % Total]
        ,NULL AS [Earned Premium %]
        ,NULL AS [Refund Premium %]

        ,a.[ClaimKey]
        ,a.[SectionID]
        ,a.[ActuarialBenefitGroup]
        ,a.[Section3] AS [Section]
        ,a.[ClaimCount]
        ,a.[SectionCount]
        ,a.[SectionCountNonNil]
        ,a.[NetPaymentMovementIncRecoveries]
        ,a.[NetIncurredMovementIncRecoveries]
    FROM       Claim_Header     a
    INNER JOIN Policy_Header_01 b ON a.[PolicyKey] = b.[PolicyKey] AND a.[ProductCode] = b.[Product Code]
)

SELECT * FROM pmth_05
UNION ALL
SELECT * FROM chdr_01
;
GO
