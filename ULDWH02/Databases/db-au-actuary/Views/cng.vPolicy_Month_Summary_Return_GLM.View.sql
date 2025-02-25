USE [db-au-actuary]
GO
/****** Object:  View [cng].[vPolicy_Month_Summary_Return_GLM]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vPolicy_Month_Summary_Return_GLM] AS
WITH 
Policy_Header AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Policy_Header] WITH(NOLOCK)
    --WHERE [PolicyKey] = 'AU-TIP7-3093567'
    WHERE CAST([Return Date] as date) >= '2023-10-01' AND [UW Rating Group] = 'GLM' AND [Product Code] <> 'CMC' AND [JV Description] NOT IN ('CBA NAC','BW NAC')
),

Claim_Header AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Claim_Header] WITH(NOLOCK)
),

Claim_Incurred_Pattern AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[vClaim_Incurred_Pattern] WITH(NOLOCK)
),

GLM_Score AS (
    SELECT
         REPLACE([PolicyKey],'CB-','AU-')   AS [PolicyKey]
        ,[Domain_Country]                   AS [Domain Country]
        ,CAST([issue_year_month] as date)   AS [Issue Month]
        ,[Policy_Status]                    AS [Policy Status]
        ,[UW_rating_group]                  AS [UW Rating Group]
        ,[JV_Description]                   AS [JV Description]
        ,[JV_Group]                         AS [JV Group]
        ,[Product_Code]                     AS [Product Code]
        ,[Product_Name]                     AS [Product Name]
        ,[Segment]                          AS [GLM Segment]
        ,[Segment2]                         AS [GLM Segment2]

        ,IIF([Policy_Status]='Cancelled',0,[med_freq_u]                 ) AS [GLM Freq MED]
        ,IIF([Policy_Status]='Cancelled',0,[can_freq_u]                 ) AS [GLM Freq CAN]
        ,IIF([Policy_Status]='Cancelled',0,[add_and_on_trip_can_freq_u] ) AS [GLM Freq ADD]
        ,IIF([Policy_Status]='Cancelled',0,[lug_freq_u]                 ) AS [GLM Freq LUG]
        ,IIF([Policy_Status]='Cancelled',0,[oth_freq_u]                 ) AS [GLM Freq MIS]
        ,IIF([Policy_Status]='Cancelled',0,[med_freq_u]+[can_freq_u]+[add_and_on_trip_can_freq_u]+[lug_freq_u]+[oth_freq_u]) AS [GLM Freq UDL]

        ,IIF([Policy_Status]='Cancelled',0,[med_sev_u]                  ) AS [GLM Size MED]
        ,IIF([Policy_Status]='Cancelled',0,[can_sev_u]                  ) AS [GLM Size CAN]
        ,IIF([Policy_Status]='Cancelled',0,[add_and_on_trip_can_sev_u]  ) AS [GLM Size ADD]
        ,IIF([Policy_Status]='Cancelled',0,[lug_sev_u]                  ) AS [GLM Size LUG]
        ,IIF([Policy_Status]='Cancelled',0,[oth_sev_u]                  ) AS [GLM Size MIS]
        ,IIF([Policy_Status]='Cancelled',0,[Pred_l]/[med_freq_u]        ) AS [GLM Size LGE]
        ,IIF([Policy_Status]='Cancelled',0,([med_pred_u]+[can_pred_u]+[add_and_on_trip_can_pred_u]+[lug_pred_u]+[oth_pred_u]+[Pred_l])/([med_freq_u]+[can_freq_u]+[add_and_on_trip_can_freq_u]+[lug_freq_u]+[oth_freq_u])) AS [GLM Size ULD]

        ,IIF([Policy_Status]='Cancelled',0,[med_pred_u]                 ) AS [GLM CPP MED]
        ,IIF([Policy_Status]='Cancelled',0,[can_pred_u]                 ) AS [GLM CPP CAN]
        ,IIF([Policy_Status]='Cancelled',0,[add_and_on_trip_can_pred_u] ) AS [GLM CPP ADD]
        ,IIF([Policy_Status]='Cancelled',0,[lug_pred_u]                 ) AS [GLM CPP LUG]
        ,IIF([Policy_Status]='Cancelled',0,[oth_pred_u]                 ) AS [GLM CPP MIS]
        ,IIF([Policy_Status]='Cancelled',0,[Pred_l]                     ) AS [GLM CPP LGE]
        ,IIF([Policy_Status]='Cancelled',0,([med_pred_u]+[can_pred_u]+[add_and_on_trip_can_pred_u]+[lug_pred_u]+[oth_pred_u]+[Pred_l]) * 1.00) AS [GLM CPP UDL]
        ,IIF([Policy_Status]='Cancelled',0,([med_pred_u]+[can_pred_u]+[add_and_on_trip_can_pred_u]+[lug_pred_u]+[oth_pred_u]+[Pred_l]) * 0.04) AS [GLM CPP CAT]
        ,IIF([Policy_Status]='Cancelled',0,([med_pred_u]+[can_pred_u]+[add_and_on_trip_can_pred_u]+[lug_pred_u]+[oth_pred_u]+[Pred_l]) * 1.04) AS [GLM CPP]

        ,IIF([Policy_Status]='Cancelled',0,[med_pred_u]                 * 1.00/0.88) AS [GLM UWP MED]
        ,IIF([Policy_Status]='Cancelled',0,[can_pred_u]                 * 1.00/0.88) AS [GLM UWP CAN]
        ,IIF([Policy_Status]='Cancelled',0,[add_and_on_trip_can_pred_u] * 1.00/0.88) AS [GLM UWP ADD]
        ,IIF([Policy_Status]='Cancelled',0,[lug_pred_u]                 * 1.00/0.88) AS [GLM UWP LUG]
        ,IIF([Policy_Status]='Cancelled',0,[oth_pred_u]                 * 1.00/0.88) AS [GLM UWP MIS]
        ,IIF([Policy_Status]='Cancelled',0,[Pred_l]                     * 1.00/0.88) AS [GLM UWP LGE]
        ,IIF([Policy_Status]='Cancelled',0,([med_pred_u]+[can_pred_u]+[add_and_on_trip_can_pred_u]+[lug_pred_u]+[oth_pred_u]+[Pred_l]) * 1.00 * 1.00/0.88) AS [GLM UWP UDL]
        ,IIF([Policy_Status]='Cancelled',0,([med_pred_u]+[can_pred_u]+[add_and_on_trip_can_pred_u]+[lug_pred_u]+[oth_pred_u]+[Pred_l]) * 0.04 * 1.00/0.88) AS [GLM UWP CAT]
        ,IIF([Policy_Status]='Cancelled',0,([med_pred_u]+[can_pred_u]+[add_and_on_trip_can_pred_u]+[lug_pred_u]+[oth_pred_u]+[Pred_l]) * 1.04 * 1.00/0.88) AS [GLM UWP]

        ,[UW_Premium]

    FROM [bhdwh02].[db-au-actuary].[cz].[BookingEstimate20230101_20240831actualUWP] WITH(NOLOCK)
),

Policy_Header_01 AS (
    SELECT 
         a.[PolicyKey]
        ,a.[Domain Country]
        ,a.[Policy Status]
        ,a.[Policy Status Detailed]
        ,a.[JV Code]
        ,a.[JV Description]
        ,a.[Outlet Channel]
        ,a.[Product Code]
        ,a.[Product Name]
        ,a.[Plan Code]
        ,a.[Product Plan]
        ,a.[Product Group]
        ,a.[Policy Type]
        ,a.[Trip Type]
        ,CASE WHEN a.[Trip Type] IN ('AMT','Cancellation','Single Trip') 
              THEN a.[Trip Type]
              ELSE 'Single Trip'
         END AS [Trip Type Earning]
        ,CASE WHEN a.[Domain Country] = 'AU' AND a.[Plan Type] = 'International' AND a.[Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
              WHEN a.[Domain Country] = 'NZ' AND a.[Plan Type] = 'International' AND a.[Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
              ELSE a.[Plan Type]
         END AS [Plan Type]
        ,CASE WHEN a.[Plan Type] IN ('Domestic') 
              THEN 'Domestic'
              ELSE 'International'
         END AS [Plan Type Earning]
        ,CASE WHEN (a.[Addon Count Cancel For Any Reason] > 0 OR a.[Gross Premium Cancel For Any Reason] > 0)
              THEN 'Yes'
              ELSE 'No'
         END AS [CFAR Flag]

        ,CASE WHEN a.[Traveller Count]=1 THEN '1' 
              WHEN a.[Traveller Count]=2 THEN '2' 
                                         ELSE '3+'
         END AS [Traveller Count]
        ,CASE WHEN a.[Max EMC Score] = 0   THEN 'No EMC'
              WHEN a.[Max EMC Score] < 1.4 THEN '<1.4'
                                           ELSE '1.4+'
         END as [Max EMC Score]
        ,CASE WHEN c.Age BETWEEN  0 AND 16 THEN ' 0 - 16'
              WHEN c.Age BETWEEN 17 AND 24 THEN '17 - 24'
              WHEN c.Age BETWEEN 25 AND 34 THEN '25 - 34'
              WHEN c.Age BETWEEN 35 AND 49 THEN '35 - 49'
              WHEN c.Age BETWEEN 50 AND 59 THEN '50 - 59'
              WHEN c.Age BETWEEN 60 AND 64 THEN '60 - 64'
              WHEN c.Age BETWEEN 65 AND 69 THEN '65 - 69'
              WHEN c.Age BETWEEN 70 AND 74 THEN '70 - 74'
              WHEN c.Age >= 75             THEN '75+'
         END [Age Group]
        ,d.[GLM_Region_20242_Banded]
		,CASE WHEN a.[Trip Duration] > 0 AND a.[Trip Duration] <=  14 THEN '<2 Weeks'
              WHEN a.[Trip Duration] >  14                            THEN '>2 Weeks'
                                                                      ELSE NULL
		 END AS [Trip Duration Group]

        ,a.[Issue Date]
        ,a.[Departure Date]
        ,a.[Return Date]
        ,IIF(CAST(a.[Return Date] AS date)<'2022-01-01','Pre','Post') AS [Period]
        ,a.[Lead Time]
        ,a.[Trip Duration]
        ,a.[Lead Time]*1.00/(a.[Lead Time]+a.[Trip Duration]) AS [Lead Time %]

        ,a.[Policy Count]
        ,COALESCE(a.[Sell Price - Active]   ,a.[Sell Price]) AS [Sell Price - Active]
        ,COALESCE(a.[Sell Price - Cancelled],0             ) AS [Sell Price - Cancelled]
        ,COALESCE(a.[Sell Price - Total]    ,a.[Sell Price]) AS [Sell Price]
        ,COALESCE(a.[Premium - Active]      ,a.[Premium]   ) AS [Premium - Active]
        ,COALESCE(a.[Premium - Cancelled]   ,0             ) AS [Premium - Cancelled]
        ,COALESCE(a.[Premium - Total]       ,a.[Premium]   ) AS [Premium]
        ,a.[Agency Commission]
        ,a.[NAP]
        ,a.[GST on Sell Price]
        ,a.[Stamp Duty on Sell Price]
        ,a.[GST on Agency Commission]
        ,a.[Stamp Duty on Agency Commission]

        ,a.[UW Rating Group]
        ,a.[UW JV Description Orig]
        ,COALESCE(a.[UW Policy Status],'Not in UW Returns') AS [UW Policy Status]

        ,IIF(a.[JV Description] IN ('CBA NAC','BW NAC'),0,a.[UW Premium]        ) AS [UW Premium]
        ,IIF(a.[JV Description] IN ('CBA NAC','BW NAC'),0,a.[UW Premium COVID19]) AS [UW Premium COVID19]
        ,CASE WHEN CAST(a.[Issue Date] AS date) >= '2021-01-01'
              THEN IIF(a.[JV Description] IN ('CBA NAC','BW NAC'),0,a.[UW Premium]) * 0.8800
              ELSE IIF(a.[JV Description] IN ('CBA NAC','BW NAC'),0,a.[UW Premium]) * 0.9275
         END AS [Target Cost]
        ,CASE WHEN CAST(a.[Issue Date] AS date) >= '2021-01-01'
              THEN IIF(a.[JV Description] IN ('CBA NAC','BW NAC'),0,a.[UW Premium COVID19]) * 0.8800
              ELSE IIF(a.[JV Description] IN ('CBA NAC','BW NAC'),0,a.[UW Premium COVID19]) * 0.9275
         END AS [Target Cost COVID19]

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

    FROM      Policy_Header a
    LEFT JOIN GLM_Score     b ON a.[PolicyKey] = b.[PolicyKey] AND a.[Product Code] = b.[Product Code]
    OUTER APPLY (    
        SELECT TOP 1 c.[Age]
        FROM [db-au-actuary].[cng].[Tmp_penPolicyTraveller] c WITH(NOLOCK)
        WHERE a.[PolicyKey] = c.[PolicyKey] AND c.[IsPrimary] = 1) c
    LEFT JOIN [bhdwh02].[db-au-actuary].[cng].[UW_Destinations] d WITH(NOLOCK) ON a.[Destination] = d.[Destination] 
),

pmth_01 AS (
    SELECT 
         b.*
        ,CASE WHEN b.[Lead Time %] < 1.0 AND b.[Trip Type] NOT IN ('AMT','Cancellation')
              THEN CEILING(b.[Lead Time %]*10) 
              ELSE 10
         END AS [Lead Time Group]
        --,a.[Month] AS [Exposure Month]
        --,CASE WHEN b.[Issue Date] <= b.[Departure Date] 
        --      THEN DATEDIFF(month,b.[Issue Date]    ,a.[Month])
        --      ELSE DATEDIFF(month,b.[Departure Date],a.[Month])
        -- END AS [Issue Development Month]
        --,CASE WHEN b.[Issue Date]              > b.[Departure Date]         THEN 0
        --      WHEN EOMONTH(b.[Issue Date])     = EOMONTH(a.[Month])
        --       AND EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Issue Date],b.[Departure Date])
        --      WHEN EOMONTH(b.[Issue Date])     = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Issue Date],EOMONTH(a.[Month]))+1
        --      WHEN EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])         THEN DATEDIFF(day,a.[Month]     ,b.[Departure Date])
        --      WHEN a.[Month] BETWEEN b.[Issue Date] AND b.[Departure Date]  THEN DATEDIFF(day,a.[Month]     ,EOMONTH(a.[Month]))+1
        --                                                                    ELSE 0
        -- END AS [Lead Days]
        --,CASE WHEN EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])
        --       AND EOMONTH(b.[Return Date])    = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Departure Date],b.[Return Date]   )+1
        --      WHEN EOMONTH(b.[Departure Date]) = EOMONTH(a.[Month])         THEN DATEDIFF(day,b.[Departure Date],EOMONTH(a.[Month]))+1
        --      WHEN EOMONTH(b.[Return Date]   ) = EOMONTH(a.[Month])         THEN DATEDIFF(day,a.[Month]         ,b.[Return Date]   )+1
        --      WHEN a.[Month] BETWEEN b.[Departure Date] AND b.[Return Date] THEN DATEDIFF(day,a.[Month]         ,EOMONTH(a.[Month]))+1
        --                                                                    ELSE 0
        -- END AS [Trip Days]
    --FROM months           a
    --JOIN Policy_Header_01 b ON (CAST(b.[Issue Date]     AS date) <= EOMONTH(a.[Month])  OR 
    --                            CAST(b.[Departure Date] AS date) <= EOMONTH(a.[Month])) AND 
    --                            CAST(b.[Return Date]    AS date) >= a.[Month]
    FROM Policy_Header_01 b
),

--pmth_02 AS (
--    SELECT
--         *
--        ,CASE 
--            WHEN [Lead Time] > 0                THEN CAST([Lead Days] AS float)/[Lead Time]
--            WHEN [Issue Development Month] = 0  THEN 1
--                                                ELSE 0
--         END AS [Lead Days %]
--        ,CASE
--            WHEN [Trip Duration] > 0            THEN CAST([Trip Days] AS float)/[Trip Duration]
--            WHEN [Issue Development Month] = 0  THEN 1
--                                                ELSE 0
--         END AS [Trip Days %]
--    FROM pmth_01
--),

--pmth_03 AS (
--    SELECT
--         *
--        ,[Lead Days %] * 0.5 + [Trip Days %] * 0.5                                                                                        AS [Policy Time %]
--        ,SUM([Lead Days %])                             OVER (PARTITION BY [PolicyKey],[Product Code] ORDER BY [Issue Development Month]) AS [Lead Days % Total]
--        ,SUM([Trip Days %])                             OVER (PARTITION BY [PolicyKey],[Product Code] ORDER BY [Issue Development Month]) AS [Trip Days % Total]
--        ,SUM([Lead Days %] * 0.5 + [Trip Days %] * 0.5) OVER (PARTITION BY [PolicyKey],[Product Code] ORDER BY [Issue Development Month]) AS [Policy Time % Total]
--    FROM pmth_02
--),

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
        ,b.[Sections ADD %]       /*- COALESCE(LAG(b.[Sections ADD %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Policy ADD %]
        ,b.[Sections CAN %]       /*- COALESCE(LAG(b.[Sections CAN %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Policy CAN %]
        ,b.[Sections LUG %]       /*- COALESCE(LAG(b.[Sections LUG %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Policy LUG %]
        ,b.[Sections MED %]       /*- COALESCE(LAG(b.[Sections MED %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Policy MED %]
        ,b.[Sections MIS %]       /*- COALESCE(LAG(b.[Sections MIS %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Policy MIS %]
        ,b.[Sections %]           /*- COALESCE(LAG(b.[Sections %])           OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Policy %]
        ,b.[Incurred ADD %]       /*- COALESCE(LAG(b.[Incurred ADD %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium ADD %]
        ,b.[Incurred CAN %]       /*- COALESCE(LAG(b.[Incurred CAN %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium CAN %]
        ,b.[Incurred LUG %]       /*- COALESCE(LAG(b.[Incurred LUG %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium LUG %]
        ,b.[Incurred MED %]       /*- COALESCE(LAG(b.[Incurred MED %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium MED %]
        ,b.[Incurred MIS %]       /*- COALESCE(LAG(b.[Incurred MIS %])       OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium MIS %]
        ,b.[Incurred ADD % Total] /*- COALESCE(LAG(b.[Incurred ADD % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium ADD % Total]
        ,b.[Incurred CAN % Total] /*- COALESCE(LAG(b.[Incurred CAN % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium CAN % Total]
        ,b.[Incurred LUG % Total] /*- COALESCE(LAG(b.[Incurred LUG % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium LUG % Total]
        ,b.[Incurred MED % Total] /*- COALESCE(LAG(b.[Incurred MED % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium MED % Total]
        ,b.[Incurred MIS % Total] /*- COALESCE(LAG(b.[Incurred MIS % Total]) OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium MIS % Total]
        ,b.[Incurred %]           /*- COALESCE(LAG(b.[Incurred %])           OVER (PARTITION BY a.[PolicyKey],a.[Product Code] ORDER BY a.[Issue Development Month]),0)*/ AS [Earned Premium %]

    FROM      pmth_01 a
    LEFT JOIN Claim_Incurred_Pattern b 
        ON  a.[Domain Country]                  = b.[DomainCountry]
        AND a.[Period]                          = b.[Period]
        AND a.[Trip Type Earning]               = b.[TripType]
        AND a.[Plan Type Earning]               = b.[PlanType]
        AND a.[Lead Time Group]                 = b.[LeadTimeGroup]
      --AND ROUND(a.[Policy Time % Total],2)    = b.[DaysToLoss%Rescale]
        AND 1                                   = b.[DaysToLoss%Rescale]
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
        ,[Product Name]
        ,[Plan Code]
        ,[Product Plan]
        ,[Product Group]
        ,[Policy Type]
        ,[Trip Type]
        ,[Trip Type Earning]
        ,[Plan Type]
        ,[Plan Type Earning]
        ,[CFAR Flag]

        ,[Traveller Count]
        ,[Max EMC Score]
        ,[Age Group]
        ,[GLM_Region_20242_Banded]
        ,[Trip Duration Group]

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

        ,NULL AS [Exposure Month]
        ,NULL AS [Issue Development Month]
        ,NULL AS [Lead Days]
        ,NULL AS [Trip Days]
        ,NULL AS [Lead Days %]
        ,NULL AS [Trip Days %]
        ,NULL AS [Policy Time %]
        ,NULL AS [Lead Days % Total]
        ,NULL AS [Trip Days % Total]
        ,NULL AS [Policy Time % Total]

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
        --,CASE WHEN [Trip Type]   IN ('Cancellation')                                                 THEN ([Lead Days] * 1.00 + [Trip Days] * 0.01)/([Lead Time] * 1.00 + [Trip Duration] * 0.01)
        --      WHEN [Policy Type] IN ('Car Hire','Corporate')                                         THEN ([Lead Days] * 0.01 + [Trip Days] * 1.00)/([Lead Time] * 0.01 + [Trip Duration] * 1.00)
        --      WHEN [Trip Type]     IN ('AMT') AND [Plan Type]     IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 3.00 + [Trip Days] * 1.00)/([Lead Time] * 3.00 + [Trip Duration] * 1.00)
        --      WHEN [Trip Type]     IN ('AMT') AND [Plan Type] NOT IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 1.00 + [Trip Days] * 1.00)/([Lead Time] * 1.00 + [Trip Duration] * 1.00)
        --      WHEN [Trip Type] NOT IN ('AMT') AND [Plan Type]     IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 1.00 + [Trip Days] * 4.00)/([Lead Time] * 1.00 + [Trip Duration] * 4.00)
        --      WHEN [Trip Type] NOT IN ('AMT') AND [Plan Type] NOT IN ('Domestic','Domestic Inbound') THEN ([Lead Days] * 1.00 + [Trip Days] * 10.0)/([Lead Time] * 1.00 + [Trip Duration] * 10.0)
        --                                                                                             ELSE ([Lead Days] * 1.00 + [Trip Days] * 1.00)/([Lead Time] * 1.00 + [Trip Duration] * 1.00)
        -- END AS [Refund Premium %]
        ,1.00 AS [Refund Premium %]
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
        ,b.[Product Name]
        ,b.[Plan Code]
        ,b.[Product Plan]
        ,b.[Product Group]
        ,b.[Policy Type]
        ,b.[Trip Type]
        ,b.[Trip Type Earning]
        ,b.[Plan Type]
        ,b.[Plan Type Earning]
        ,b.[CFAR Flag]

        ,b.[Traveller Count]
        ,b.[Max EMC Score]
        ,b.[Age Group]
        ,b.[GLM_Region_20242_Banded]
        ,b.[Trip Duration Group]

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
),

Policy_Month_Return AS (
    SELECT * FROM pmth_05
    UNION ALL
    SELECT * FROM chdr_01
)

SELECT 
     'Return' AS [Date Type]
    ,[Domain Country]
    ,[Policy Status]
    ,[Policy Status Detailed]
    ,[UW Policy Status]
    ,[UW Rating Group]
    ,[JV Description]
    ,[Outlet Channel]
    ,[Product Code]
    ,[Product Name]
    ,[Plan Code]
    ,[Product Plan]
    ,[Product Group]
    ,[Policy Type]
    ,[Plan Type]
    ,[Trip Type]
    ,[CFAR Flag]

    ,[Traveller Count]
    ,[Max EMC Score]
    ,[Age Group]
    ,[GLM_Region_20242_Banded]
    ,[Trip Duration Group]

    ,CAST(EOMONTH([Return Date]) as datetime)    AS [Return Month]
    ,YEAR([Return Date])                         AS [Return Year]

    ,SUM([Earned Policy MED %]) AS [Policy MED]
    ,SUM([Earned Policy CAN %]) AS [Policy CAN]
    ,SUM([Earned Policy ADD %]) AS [Policy ADD]
    ,SUM([Earned Policy LUG %]) AS [Policy LUG]
    ,SUM([Earned Policy MIS %]) AS [Policy MIS]
    ,SUM([Earned Policy %])     AS [Policy]

    ,SUM(IIF([Policy Status]='Active'   ,[Earned Policy MED %],0)) AS [Policy MED - Active]
    ,SUM(IIF([Policy Status]='Active'   ,[Earned Policy CAN %],0)) AS [Policy CAN - Active]
    ,SUM(IIF([Policy Status]='Active'   ,[Earned Policy ADD %],0)) AS [Policy ADD - Active]
    ,SUM(IIF([Policy Status]='Active'   ,[Earned Policy LUG %],0)) AS [Policy LUG - Active]
    ,SUM(IIF([Policy Status]='Active'   ,[Earned Policy MIS %],0)) AS [Policy MIS - Active]
    ,SUM(IIF([Policy Status]='Active'   ,[Earned Policy %]    ,0)) AS [Policy - Active]

    ,SUM(IIF([Policy Status]='Cancelled',[Earned Policy MED %],0)) AS [Policy MED - Cancelled]
    ,SUM(IIF([Policy Status]='Cancelled',[Earned Policy CAN %],0)) AS [Policy CAN - Cancelled]
    ,SUM(IIF([Policy Status]='Cancelled',[Earned Policy ADD %],0)) AS [Policy ADD - Cancelled]
    ,SUM(IIF([Policy Status]='Cancelled',[Earned Policy LUG %],0)) AS [Policy LUG - Cancelled]
    ,SUM(IIF([Policy Status]='Cancelled',[Earned Policy MIS %],0)) AS [Policy MIS - Cancelled]
    ,SUM(IIF([Policy Status]='Cancelled',[Earned Policy %]    ,0)) AS [Policy - Cancelled]

    ,SUM([Sell Price - Active]              * [Refund Premium %]) AS [Sell Price - Refund]
    ,SUM([Sell Price - Active]              * [Earned Premium %]) AS [Sell Price - Active]
    ,SUM([Sell Price - Cancelled]           * [Earned Premium %]) AS [Sell Price - Cancelled]
    ,SUM([Sell Price]                       * [Earned Premium %]) AS [Sell Price]
    ,SUM([Premium - Active]                 * [Earned Premium %]) AS [Premium - Active]
    ,SUM([Premium - Cancelled]              * [Earned Premium %]) AS [Premium - Cancelled]
    ,SUM([Premium]                          * [Earned Premium %]) AS [Premium]
    ,SUM([Agency Commission]                * [Earned Premium %]) AS [Commission]
    ,SUM([NAP]                              * [Earned Premium %]) AS [NAP]
    ,SUM([GST on Sell Price]                * [Earned Premium %]) AS [GST on Sell Price]
    ,SUM([GST on Agency Commission]         * [Earned Premium %]) AS [GST on Agency Commission]
    ,SUM([Stamp Duty on Sell Price]         * [Earned Premium %]) AS [Stamp Duty on Sell Price]
    ,SUM([Stamp Duty on Agency Commission]  * [Earned Premium %]) AS [Stamp Duty on Agency Commission]

    --,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium MED % Total])                              AS [UW Premium MED]
    --,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',2,1)) AS [UW Premium CAN]
    --,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium ADD % Total])                              AS [UW Premium ADD]
    --,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium LUG % Total])                              AS [UW Premium LUG]
    --,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium MIS % Total])                              AS [UW Premium MIS]
    --,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium %]) +
    -- SUM([UW Premium]           * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [UW Premium UDL]
    --,SUM([UW Premium]           * 0.04/1.04 * [Earned Premium %]) +
    -- SUM([UW Premium]           * 0.04/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [UW Premium CAT]
    --,SUM([UW Premium COVID19]   * 1.00      * [Earned Premium %])                                        AS [UW Premium COV]
    ,SUM([UW Premium]           * 1.00      * [Earned Premium %]) + 
     SUM([UW Premium COVID19]   * 1.00      * [Earned Premium %]) + 
     SUM([UW Premium]           * 1.00      * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [UW Premium]

    --,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium MED % Total])                              AS [Target Cost MED]
    --,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',2,1)) AS [Target Cost CAN]
    --,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium ADD % Total])                              AS [Target Cost ADD]
    --,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium LUG % Total])                              AS [Target Cost LUG]
    --,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium MIS % Total])                              AS [Target Cost MIS]
    --,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium %]) + 
    -- SUM([Target Cost]          * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [Target Cost UDL]
    --,SUM([Target Cost]          * 0.04/1.04 * [Earned Premium %]) +
    -- SUM([Target Cost]          * 0.04/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [Target Cost CAT]
    --,SUM([Target Cost COVID19]  * 1.00      * [Earned Premium %])                                        AS [Target Cost COV]
    ,SUM([Target Cost]          * 1.00      * [Earned Premium %]) + 
     SUM([Target Cost COVID19]  * 1.00      * [Earned Premium %]) + 
     SUM([Target Cost]          * 1.00      * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [Target Cost]

    ,COALESCE(SUM([GLM Freq MED] * [Earned Policy MED %]),0)    AS [GLM Freq MED]
    ,COALESCE(SUM([GLM Freq CAN] * [Earned Policy CAN %]),0)    AS [GLM Freq CAN]
    ,COALESCE(SUM([GLM Freq ADD] * [Earned Policy ADD %]),0)    AS [GLM Freq ADD]
    ,COALESCE(SUM([GLM Freq LUG] * [Earned Policy LUG %]),0)    AS [GLM Freq LUG]
    ,COALESCE(SUM([GLM Freq MIS] * [Earned Policy MIS %]),0)    AS [GLM Freq MIS]
    ,COALESCE(SUM([GLM Freq MED] * [Earned Policy MED %]),0) + 
     COALESCE(SUM([GLM Freq CAN] * [Earned Policy CAN %]),0) + 
     COALESCE(SUM([GLM Freq ADD] * [Earned Policy ADD %]),0) + 
     COALESCE(SUM([GLM Freq LUG] * [Earned Policy LUG %]),0) + 
     COALESCE(SUM([GLM Freq MIS] * [Earned Policy MIS %]),0)    AS [GLM Freq UDL]
    ,COALESCE(SUM([GLM Freq UDL] * [Earned Policy %])    ,0)    AS [GLM Freq]

    ,COALESCE(SUM([GLM CPP MED] * [Earned Premium MED %]),0)    AS [GLM CPP MED]
    ,COALESCE(SUM([GLM CPP LGE] * [Earned Premium MED %]),0)    AS [GLM CPP LGE]
    ,COALESCE(SUM([GLM CPP MED] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM CPP LGE] * [Earned Premium MED %]),0)    AS [GLM CPP MED+LGE]
    ,COALESCE(SUM([GLM CPP CAN] * [Earned Premium CAN %]),0)    AS [GLM CPP CAN]
    ,COALESCE(SUM([GLM CPP ADD] * [Earned Premium ADD %]),0)    AS [GLM CPP ADD]
    ,COALESCE(SUM([GLM CPP LUG] * [Earned Premium LUG %]),0)    AS [GLM CPP LUG]
    ,COALESCE(SUM([GLM CPP MIS] * [Earned Premium MIS %]),0)    AS [GLM CPP MIS]
    ,COALESCE(SUM([GLM CPP MED] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM CPP LGE] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM CPP CAN] * [Earned Premium CAN %]),0) + 
     COALESCE(SUM([GLM CPP ADD] * [Earned Premium ADD %]),0) + 
     COALESCE(SUM([GLM CPP LUG] * [Earned Premium LUG %]),0) + 
     COALESCE(SUM([GLM CPP MIS] * [Earned Premium MIS %]),0)    AS [GLM CPP UDL]
    ,COALESCE(SUM([GLM CPP CAT] * [Earned Premium %])    ,0)    AS [GLM CPP CAT]
    ,COALESCE(SUM([GLM CPP MED] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM CPP LGE] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM CPP CAN] * [Earned Premium CAN %]),0) + 
     COALESCE(SUM([GLM CPP ADD] * [Earned Premium ADD %]),0) + 
     COALESCE(SUM([GLM CPP LUG] * [Earned Premium LUG %]),0) + 
     COALESCE(SUM([GLM CPP MIS] * [Earned Premium MIS %]),0)+
     COALESCE(SUM([GLM CPP CAT] * [Earned Premium %])    ,0)    AS [GLM CPP]

    ,COALESCE(SUM([GLM UWP MED] * [Earned Premium MED %]),0)    AS [GLM UWP MED]
    ,COALESCE(SUM([GLM UWP LGE] * [Earned Premium MED %]),0)    AS [GLM UWP LGE]
    ,COALESCE(SUM([GLM UWP MED] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM UWP LGE] * [Earned Premium MED %]),0)    AS [GLM UWP MED+LGE]
    ,COALESCE(SUM([GLM UWP CAN] * [Earned Premium CAN %]),0)    AS [GLM UWP CAN]
    ,COALESCE(SUM([GLM UWP ADD] * [Earned Premium ADD %]),0)    AS [GLM UWP ADD]
    ,COALESCE(SUM([GLM UWP LUG] * [Earned Premium LUG %]),0)    AS [GLM UWP LUG]
    ,COALESCE(SUM([GLM UWP MIS] * [Earned Premium MIS %]),0)    AS [GLM UWP MIS]
    ,COALESCE(SUM([GLM UWP MED] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM UWP LGE] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM UWP CAN] * [Earned Premium CAN %]),0) + 
     COALESCE(SUM([GLM UWP ADD] * [Earned Premium ADD %]),0) + 
     COALESCE(SUM([GLM UWP LUG] * [Earned Premium LUG %]),0) + 
     COALESCE(SUM([GLM UWP MIS] * [Earned Premium MIS %]),0)    AS [GLM UWP UDL]
    ,COALESCE(SUM([GLM UWP CAT] * [Earned Premium %])    ,0)    AS [GLM UWP CAT]
    ,COALESCE(SUM([GLM UWP MED] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM UWP LGE] * [Earned Premium MED %]),0) + 
     COALESCE(SUM([GLM UWP CAN] * [Earned Premium CAN %]),0) + 
     COALESCE(SUM([GLM UWP ADD] * [Earned Premium ADD %]),0) + 
     COALESCE(SUM([GLM UWP LUG] * [Earned Premium LUG %]),0) + 
     COALESCE(SUM([GLM UWP MIS] * [Earned Premium MIS %]),0) +
     COALESCE(SUM([GLM UWP CAT] * [Earned Premium %])    ,0)    AS [GLM UWP]

    ,SUM([ClaimCount]) AS [Claims]

    ,SUM(IIF([Section] = 'MED'        ,[SectionCount],0))   AS [Sections MED]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[SectionCount],0))   AS [Sections MED_LGE]
    ,SUM(IIF([Section] = 'PRE_CAN'    ,[SectionCount],0))   AS [Sections CAN]
    ,SUM(IIF([Section] = 'PRE_CAN_LGE',[SectionCount],0))   AS [Sections CAN_LGE]
    ,SUM(IIF([Section] = 'ADD'        ,[SectionCount],0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[SectionCount],0))   AS [Sections ADD]
    ,SUM(IIF([Section] = 'ADD_LGE'    ,[SectionCount],0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[SectionCount],0))   AS [Sections ADD_LGE]
    ,SUM(IIF([Section] = 'LUG'        ,[SectionCount],0))   AS [Sections LUG]
    ,SUM(IIF([Section] = 'LUG_LGE'    ,[SectionCount],0))   AS [Sections LUG_LGE]
    ,SUM(IIF([Section] = 'MIS'        ,[SectionCount],0))   AS [Sections MIS]
    ,SUM(IIF([Section] = 'MIS_LGE'    ,[SectionCount],0))   AS [Sections MIS_LGE]
    ,SUM(IIF([Section] = 'MED'        ,[SectionCount],0)) +
     SUM(IIF([Section] = 'PRE_CAN'    ,[SectionCount],0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[SectionCount],0)) +
     SUM(IIF([Section] = 'ADD'        ,[SectionCount],0)) +
     SUM(IIF([Section] = 'LUG'        ,[SectionCount],0)) +
     SUM(IIF([Section] = 'MIS'        ,[SectionCount],0))   AS [Sections UDL]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[SectionCount],0)) + 
     SUM(IIF([Section] = 'PRE_CAN_LGE',[SectionCount],0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[SectionCount],0)) +         
     SUM(IIF([Section] = 'ADD_LGE'    ,[SectionCount],0)) + 
     SUM(IIF([Section] = 'LUG_LGE'    ,[SectionCount],0)) + 
     SUM(IIF([Section] = 'MIS_LGE'    ,[SectionCount],0))   AS [Sections UDL_LGE]
    ,SUM(IIF([Section] = 'CAT'        ,[SectionCount],0))   AS [Sections CAT]
    ,SUM(IIF([Section] = 'COV'        ,[SectionCount],0))   AS [Sections COV]
    ,SUM(IIF([Section] = 'OTH'        ,[SectionCount],0))   AS [Sections OTH]
    ,SUM([SectionCount])                                    AS [Sections]

    ,SUM(IIF([Section] = 'MED'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil MED]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil MED_LGE]
    ,SUM(IIF([Section] = 'PRE_CAN'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil CAN]
    ,SUM(IIF([Section] = 'PRE_CAN_LGE',[SectionCountNonNil],0))   AS [Sections Non-Nil CAN_LGE]
    ,SUM(IIF([Section] = 'ADD'        ,[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[SectionCountNonNil],0))   AS [Sections Non-Nil ADD]
    ,SUM(IIF([Section] = 'ADD_LGE'    ,[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[SectionCountNonNil],0))   AS [Sections Non-Nil ADD_LGE]
    ,SUM(IIF([Section] = 'LUG'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil LUG]
    ,SUM(IIF([Section] = 'LUG_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil LUG_LGE]
    ,SUM(IIF([Section] = 'MIS'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil MIS]
    ,SUM(IIF([Section] = 'MIS_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil MIS_LGE]
    ,SUM(IIF([Section] = 'MED'        ,[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'PRE_CAN'    ,[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'ADD'        ,[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'LUG'        ,[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'MIS'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil UDL]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[SectionCountNonNil],0)) + 
     SUM(IIF([Section] = 'PRE_CAN_LGE',[SectionCountNonNil],0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[SectionCountNonNil],0)) +         
     SUM(IIF([Section] = 'ADD_LGE'    ,[SectionCountNonNil],0)) + 
     SUM(IIF([Section] = 'LUG_LGE'    ,[SectionCountNonNil],0)) + 
     SUM(IIF([Section] = 'MIS_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil UDL_LGE]
    ,SUM(IIF([Section] = 'CAT'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil CAT]
    ,SUM(IIF([Section] = 'COV'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil COV]
    ,SUM(IIF([Section] = 'OTH'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil OTH]
    ,SUM([SectionCountNonNil])                                    AS [Sections Non-Nil]

    ,SUM(IIF([Section] = 'MED'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MED]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MED_LGE]
    ,SUM(IIF([Section] = 'PRE_CAN'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments CAN]
    ,SUM(IIF([Section] = 'PRE_CAN_LGE',[NetPaymentMovementIncRecoveries] ,0))   AS [Payments CAN_LGE]
    ,SUM(IIF([Section] = 'ADD'        ,[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ADD]
    ,SUM(IIF([Section] = 'ADD_LGE'    ,[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ADD_LGE]
    ,SUM(IIF([Section] = 'LUG'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments LUG]
    ,SUM(IIF([Section] = 'LUG_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments LUG_LGE]
    ,SUM(IIF([Section] = 'MIS'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MIS]
    ,SUM(IIF([Section] = 'MIS_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MIS_LGE]
    ,SUM(IIF([Section] = 'MED'        ,[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'PRE_CAN'    ,[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'ADD'        ,[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'LUG'        ,[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'MIS'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments UDL]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF([Section] = 'PRE_CAN_LGE',[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[NetPaymentMovementIncRecoveries] ,0)) +         
     SUM(IIF([Section] = 'ADD_LGE'    ,[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF([Section] = 'LUG_LGE'    ,[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF([Section] = 'MIS_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments UDL_LGE]
    ,SUM(IIF([Section] = 'CAT'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments CAT]
    ,SUM(IIF([Section] = 'COV'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments COV]
    ,SUM(IIF([Section] = 'OTH'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments OTH]
    ,SUM([NetPaymentMovementIncRecoveries])                                     AS [Payments]

    ,SUM(IIF([Section] = 'MED'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MED]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MED_LGE]
    ,SUM(IIF([Section] = 'PRE_CAN'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred CAN]
    ,SUM(IIF([Section] = 'PRE_CAN_LGE',[NetIncurredMovementIncRecoveries],0))   AS [Incurred CAN_LGE]
    ,SUM(IIF([Section] = 'ADD'        ,[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred ADD]
    ,SUM(IIF([Section] = 'ADD_LGE'    ,[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred ADD_LGE]
    ,SUM(IIF([Section] = 'LUG'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred LUG]
    ,SUM(IIF([Section] = 'LUG_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred LUG_LGE]
    ,SUM(IIF([Section] = 'MIS'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MIS]
    ,SUM(IIF([Section] = 'MIS_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MIS_LGE]
    ,SUM(IIF([Section] = 'MED'        ,[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'PRE_CAN'    ,[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'ON_CAN'     ,[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'ADD'        ,[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'LUG'        ,[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'MIS'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred UDL]
    ,SUM(IIF([Section] = 'MED_LGE'    ,[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF([Section] = 'PRE_CAN_LGE',[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF([Section] = 'ON_CAN_LGE' ,[NetIncurredMovementIncRecoveries],0)) +         
     SUM(IIF([Section] = 'ADD_LGE'    ,[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF([Section] = 'LUG_LGE'    ,[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF([Section] = 'MIS_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred UDL_LGE]
    ,SUM(IIF([Section] = 'CAT'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred CAT]
    ,SUM(IIF([Section] = 'COV'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred COV]
    ,SUM(IIF([Section] = 'OTH'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred OTH]
    ,SUM([NetIncurredMovementIncRecoveries])                                    AS [Incurred]

FROM [Policy_Month_Return]
GROUP BY 
     [Domain Country]
    ,[Policy Status]
    ,[Policy Status Detailed]
    ,[UW Policy Status]
    ,[UW Rating Group]
    ,[JV Description]
    ,[Outlet Channel]
    ,[Product Code]
    ,[Product Name]
    ,[Plan Code]
    ,[Product Plan]
    ,[Product Group]
    ,[Policy Type]
    ,[Plan Type]
    ,[Trip Type]
    ,[CFAR Flag]

    ,[Traveller Count]
    ,[Max EMC Score]
    ,[Age Group]
    ,[GLM_Region_20242_Banded]
    ,[Trip Duration Group]

    ,CAST(EOMONTH([Return Date]) as datetime)
    ,YEAR([Return Date])
--ORDER BY 
--     [Domain Country]
--    ,[Policy Status]
--    ,[Policy Status Detailed]
--    ,[UW Policy Status]
--    ,[UW Rating Group]
--    ,[JV Description]
--    ,[Outlet Channel]
--    ,[Product Code]
--    ,[Plan Code]
--    ,[Product Plan]
--    ,[Product Group]
--    ,[Policy Type]
--    ,[Plan Type]
--    ,[Trip Type]
--    ,[CFAR Flag]

--    ,[Traveller Count]
--    ,[Max EMC Score]
--    ,[Age Group]
--    ,[GLM_Region_20242_Banded]
--    ,[Trip Duration]

--    ,CAST(EOMONTH([Departure Date]) as datetime)
--    ,YEAR([Departure Date])
--    ,CAST(EOMONTH([Return Date]) as datetime)
--    ,YEAR([Return Date])
;
GO
