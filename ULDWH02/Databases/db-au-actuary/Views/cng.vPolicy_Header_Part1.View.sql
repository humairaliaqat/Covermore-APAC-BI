USE [db-au-actuary]
GO
/****** Object:  View [cng].[vPolicy_Header_Part1]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vPolicy_Header_Part1] AS 

/****************************************************************************************************/
--  Name:           vPolicy_Header_Part1
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  
/****************************************************************************************************/

WITH 
DWHDataSetSummary AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Tmp_DWHDataSetSummary]
),

DWHDataSet AS (
    SELECT 
         [PolicyKey]
        ,[Product Code]
        ,[Policy Status]
        ,[Transaction Status]
        ,[Transaction Type]
        ,[Transaction Issue Date]
        ,[Departure Date]
        ,[Return Date]
    FROM [db-au-actuary].[cng].[Tmp_DWHDataSet]
),

penPolicy AS (
    SELECT 
         [PolicyKey]
        ,[PolicyNumber]
        ,[ProductCode] AS [Product Code]
        ,[TripStart]
        ,[TripEnd]
        ,[Area]
        ,[AreaCode]
        ,[MultiDestination]
    FROM [db-au-actuary].[cng].[Tmp_penPolicy]
),

penPolicyTransSummary AS (
    SELECT 
         a.[PolicyKey]
        ,a.[ProductCode] AS [Product Code]
        ,b.[CRMUserName] AS [Base CRM Username]
        ,SUM(a.[BasePolicyCountFix]) AS [Policy Count]
    FROM      [db-au-actuary].[cng].[Tmp_penPolicyTransSummary] a
    LEFT JOIN [db-au-actuary].[cng].[Tmp_penPolicyTransSummary] b ON a.[PolicyKey]   = b.[PolicyKey]   AND 
                                                                     a.[ProductCode] = b.[ProductCode] AND 
                                                                     b.[TransactionType]   = 'Base'     AND 
                                                                     b.[TransactionStatus] = 'Active'
    GROUP BY a.[PolicyKey],a.[ProductCode],b.[CRMUserName]
),

impPolicies_CBA AS (
    SELECT
         [PolicyKey]
        ,[ProductCode] AS [Product Code]
        ,[cbaChannelID] AS [CBA ChannelID]
    FROM [db-au-actuary].[cng].[Tmp_impPolicies_CBA]
),

dimOutlet AS (
    SELECT 
         ROW_NUMBER() OVER (PARTITION BY [OutletKey] ORDER BY [LoadDate] DESC) AS [Rank]
        ,[LoadDate]
        ,[OutletKey]          AS [Outlet Key]
        ,[OutletName]         AS [Outlet Name]
        ,[SubGroupCode]       AS [Outlet Sub Group Code]
        ,[SubGroupName]       AS [Outlet Sub Group Name]
        ,[GroupCode]          AS [Outlet Group Code]
        ,[GroupName]          AS [Outlet Group Name]
        ,[SuperGroupName]     AS [Outlet Super Group]
        ,[Channel]            AS [Outlet Channel]
        ,[BDMName]            AS [Outlet BDM]
        ,[ContactPostCode]    AS [Outlet Post Code]
        ,[StateSalesArea]     AS [Outlet Sales State Area]
        ,[TradingStatus]      AS [Outlet Trading Status]
        ,[OutletType]         AS [Outlet Type]
        ,[JV]                 AS [JV Code]
      --,[JVDesc]             AS [JV Description]
        ,[JVFix]              AS [JV Description]
    FROM  [db-au-actuary].[cng].[Tmp_dimOutlet]
    WHERE [isLatest] = 'Y' AND [OutletKey] <> ''
),

penOutlet AS (
    SELECT
         ROW_NUMBER() OVER (PARTITION BY [OutletKey] ORDER BY [OutletStartDate] DESC) AS [Rank]
        ,[OutletStartDate]
        ,[OutletKey]        AS [Outlet Key]
        ,[OutletName]       AS [Outlet Name]
        ,[SubGroupCode]     AS [Outlet Sub Group Code]
        ,[SubGroupName]     AS [Outlet Sub Group Name]
        ,[GroupCode]        AS [Outlet Group Code]
        ,[GroupName]        AS [Outlet Group Name]
        ,[SuperGroupName]   AS [Outlet Super Group]
        ,[Channel]          AS [Outlet Channel]
        ,[BDMName]          AS [Outlet BDM]
        ,[ContactPostCode]  AS [Outlet Post Code]
        ,[StateSalesArea]   AS [Outlet Sales State Area]
        ,[TradingStatus]    AS [Outlet Trading Status]
        ,[OutletType]       AS [Outlet Type]
        ,[JVCode]           AS [JV Code]
      --,[JV]               AS [JV Description]
        ,[JVFix]            AS [JV Description]
    FROM  [db-au-actuary].[cng].[Tmp_penOutlet]
    WHERE [OutletStatus] = 'Current'
),

penOutletLineage AS (
    SELECT a.[OutletKey]
          ,IIF(CHARINDEX(' ',a.[Lineage],0)=0,a.[Lineage],LEFT(a.[Lineage],CHARINDEX(' ',a.[Lineage],0)-1)) AS [AlphaCode]
          ,a.[Lineage]
          ,b.[OutletKey] AS [LatestOutletKey]
          ,LEFT(IIF(CHARINDEX(' ',REVERSE(a.[Lineage]),0)=0,a.[Lineage],RIGHT(a.[Lineage],CHARINDEX(' ',REVERSE(a.[Lineage]),0)-1)),7) AS [LatestAlphaCode]
    FROM      [db-au-cmdwh].[dbo].[penOutletLineage] a
    LEFT JOIN [db-au-cmdwh].[dbo].[penOutletLineage] b ON LEFT(IIF(CHARINDEX(' ',REVERSE(a.[Lineage]),0)=0,a.[Lineage],RIGHT(a.[Lineage],CHARINDEX(' ',REVERSE(a.[Lineage]),0)-1)),7)
                                                             = IIF(CHARINDEX(' ',        b.[Lineage] ,0)=0,b.[Lineage], LEFT(b.[Lineage],CHARINDEX(' ',        b.[Lineage] ,0)-1))
                                                          AND LEFT(a.[OutletKey],2) = LEFT(b.[OutletKey],2)
    GROUP BY 
           a.[OutletKey]
          ,IIF(CHARINDEX(' ',a.[Lineage],0)=0,a.[Lineage],LEFT(a.[Lineage],CHARINDEX(' ',a.[Lineage],0)-1))
          ,a.[Lineage]
          ,b.[OutletKey]
          ,LEFT(IIF(CHARINDEX(' ',REVERSE(a.[Lineage]),0)=0,a.[Lineage],RIGHT(a.[Lineage],CHARINDEX(' ',REVERSE(a.[Lineage]),0)-1)),7)
),

Regions AS (
    SELECT df.[Destination],dr.*
    FROM [db-au-actuary].[cng].[Tmp_Destination_Fix]     df
    JOIN [db-au-actuary].[cng].[Tmp_Destination_Regions] dr ON df.[Fix] = dr.[Country or Area]
),

Postcodes AS (
    SELECT
         RANK() OVER (PARTITION BY [postcode] ORDER BY COUNT(*) DESC) AS [Rank]
        ,[postcode]
        ,[state]
        ,COUNT(*) AS [Count]
    FROM [db-au-actuary].[cng].[Tmp_Postcodes]
    GROUP BY [postcode],[state] 
),

UK_Halo AS (
    SELECT
         [Customer Policy Number]
        ,SUM([Gross Premium Exc Taxes]) AS [Gross Premium Exc Taxes]
        ,SUM([GST Cost])                AS [GST Cost]
        ,SUM([Stamp Duty])              AS [Stamp Duty]
        ,SUM([Gross Premium Inc Taxes]) AS [Gross Premium Inc Taxes]
    FROM [db-au-actuary].[cng].[Tmp_UK_Halo_SuperGroup]
    GROUP BY [Customer Policy Number]
),

UWPremium AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Tmp_UW_Premiums] 
    WHERE [Rank] = 1
),

UWPremiumRescore AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Tmp_UW_Premiums_Rescore]
),

Claim_Header AS (
    SELECT 
         [PolicyKey]    AS [PolicyKey]
        ,[ProductCode]  AS [Product Code]

		,SUM([ClaimCount]                      ) AS [ClaimCount]
		,SUM([SectionCount]                    ) AS [SectionCount]
        ,SUM([SectionCountNonNil]              ) AS [SectionCountNonNil]
		,SUM([NetPaymentMovementIncRecoveries] ) AS [NetPaymentMovementIncRecoveries]
		,SUM([NetIncurredMovementIncRecoveries]) AS [NetIncurredMovementIncRecoveries]

        ,SUM(IIF([Section3] = 'MED'        ,[SectionCount],0))   AS [Sections MED]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[SectionCount],0))   AS [Sections MED_LGE]
        ,SUM(IIF([Section3] = 'PRE_CAN'    ,[SectionCount],0))   AS [Sections PRE_CAN]
        ,SUM(IIF([Section3] = 'PRE_CAN_LGE',[SectionCount],0))   AS [Sections PRE_CAN_LGE]
        ,SUM(IIF([Section3] = 'ON_CAN'     ,[SectionCount],0))   AS [Sections ON_CAN]
        ,SUM(IIF([Section3] = 'ON_CAN_LGE' ,[SectionCount],0))   AS [Sections ON_CAN_LGE]
        ,SUM(IIF([Section3] = 'ADD'        ,[SectionCount],0))   AS [Sections ADD]
        ,SUM(IIF([Section3] = 'ADD_LGE'    ,[SectionCount],0))   AS [Sections ADD_LGE]
        ,SUM(IIF([Section3] = 'LUG'        ,[SectionCount],0))   AS [Sections LUG]
        ,SUM(IIF([Section3] = 'LUG_LGE'    ,[SectionCount],0))   AS [Sections LUG_LGE]
        ,SUM(IIF([Section3] = 'MIS'        ,[SectionCount],0))   AS [Sections MIS]
        ,SUM(IIF([Section3] = 'MIS_LGE'    ,[SectionCount],0))   AS [Sections MIS_LGE]
        ,SUM(IIF([Section3] = 'MED'        ,[SectionCount],0)) +
         SUM(IIF([Section3] = 'PRE_CAN'    ,[SectionCount],0)) +
         SUM(IIF([Section3] = 'ON_CAN'     ,[SectionCount],0)) +
         SUM(IIF([Section3] = 'ADD'        ,[SectionCount],0)) +
         SUM(IIF([Section3] = 'LUG'        ,[SectionCount],0)) +
         SUM(IIF([Section3] = 'MIS'        ,[SectionCount],0))   AS [Sections UDL]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[SectionCount],0)) + 
         SUM(IIF([Section3] = 'PRE_CAN_LGE',[SectionCount],0)) +
         SUM(IIF([Section3] = 'ON_CAN_LGE' ,[SectionCount],0)) +         
         SUM(IIF([Section3] = 'ADD_LGE'    ,[SectionCount],0)) + 
         SUM(IIF([Section3] = 'LUG_LGE'    ,[SectionCount],0)) + 
         SUM(IIF([Section3] = 'MIS_LGE'    ,[SectionCount],0))   AS [Sections UDL_LGE]
        ,SUM(IIF([Section3] = 'CAT'        ,[SectionCount],0))   AS [Sections CAT]
        ,SUM(IIF([Section3] = 'COV'        ,[SectionCount],0))   AS [Sections COV]
        ,SUM(IIF([Section3] = 'OTH'        ,[SectionCount],0))   AS [Sections OTH]

        ,SUM(IIF([Section3] = 'MED'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil MED]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil MED_LGE]
        ,SUM(IIF([Section3] = 'PRE_CAN'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil PRE_CAN]
        ,SUM(IIF([Section3] = 'PRE_CAN_LGE',[SectionCountNonNil],0))   AS [Sections Non-Nil PRE_CAN_LGE]
        ,SUM(IIF([Section3] = 'ON_CAN'     ,[SectionCountNonNil],0))   AS [Sections Non-Nil ON_CAN]
        ,SUM(IIF([Section3] = 'ON_CAN_LGE' ,[SectionCountNonNil],0))   AS [Sections Non-Nil ON_CAN_LGE]
        ,SUM(IIF([Section3] = 'ADD'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil ADD]
        ,SUM(IIF([Section3] = 'ADD_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil ADD_LGE]
        ,SUM(IIF([Section3] = 'LUG'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil LUG]
        ,SUM(IIF([Section3] = 'LUG_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil LUG_LGE]
        ,SUM(IIF([Section3] = 'MIS'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil MIS]
        ,SUM(IIF([Section3] = 'MIS_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil MIS_LGE]
        ,SUM(IIF([Section3] = 'MED'        ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'PRE_CAN'    ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'ON_CAN'     ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'ADD'        ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'LUG'        ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'MIS'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil UDL]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'PRE_CAN_LGE',[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'ON_CAN_LGE' ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'ADD_LGE'    ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'LUG_LGE'    ,[SectionCountNonNil],0)) +
         SUM(IIF([Section3] = 'MIS_LGE'    ,[SectionCountNonNil],0))   AS [Sections Non-Nil UDL_LGE]
        ,SUM(IIF([Section3] = 'CAT'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil CAT]
        ,SUM(IIF([Section3] = 'COV'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil COV]
        ,SUM(IIF([Section3] = 'OTH'        ,[SectionCountNonNil],0))   AS [Sections Non-Nil OTH]

        ,SUM(IIF([Section3] = 'MED'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MED]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MED_LGE]
        ,SUM(IIF([Section3] = 'PRE_CAN'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments PRE_CAN]
        ,SUM(IIF([Section3] = 'PRE_CAN_LGE',[NetPaymentMovementIncRecoveries] ,0))   AS [Payments PRE_CAN_LGE]
        ,SUM(IIF([Section3] = 'ON_CAN'     ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ON_CAN]
        ,SUM(IIF([Section3] = 'ON_CAN_LGE' ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ON_CAN_LGE]
        ,SUM(IIF([Section3] = 'ADD'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ADD]
        ,SUM(IIF([Section3] = 'ADD_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ADD_LGE]
        ,SUM(IIF([Section3] = 'LUG'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments LUG]
        ,SUM(IIF([Section3] = 'LUG_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments LUG_LGE]
        ,SUM(IIF([Section3] = 'MIS'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MIS]
        ,SUM(IIF([Section3] = 'MIS_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MIS_LGE]
        ,SUM(IIF([Section3] = 'MED'        ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'PRE_CAN'    ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'ON_CAN'     ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'ADD'        ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'LUG'        ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'MIS'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments UDL]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'PRE_CAN_LGE',[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'ON_CAN_LGE' ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'ADD_LGE'    ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'LUG_LGE'    ,[NetPaymentMovementIncRecoveries] ,0)) +
         SUM(IIF([Section3] = 'MIS_LGE'    ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments UDL_LGE]
        ,SUM(IIF([Section3] = 'CAT'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments CAT]
        ,SUM(IIF([Section3] = 'COV'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments COV]
        ,SUM(IIF([Section3] = 'OTH'        ,[NetPaymentMovementIncRecoveries] ,0))   AS [Payments OTH]

        ,SUM(IIF([Section3] = 'MED'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MED]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MED_LGE]
        ,SUM(IIF([Section3] = 'PRE_CAN'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred PRE_CAN]
        ,SUM(IIF([Section3] = 'PRE_CAN_LGE',[NetIncurredMovementIncRecoveries],0))   AS [Incurred PRE_CAN_LGE]
        ,SUM(IIF([Section3] = 'ON_CAN'     ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred ON_CAN]
        ,SUM(IIF([Section3] = 'ON_CAN_LGE' ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred ON_CAN_LGE]
        ,SUM(IIF([Section3] = 'ADD'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred ADD]
        ,SUM(IIF([Section3] = 'ADD_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred ADD_LGE]
        ,SUM(IIF([Section3] = 'LUG'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred LUG]
        ,SUM(IIF([Section3] = 'LUG_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred LUG_LGE]
        ,SUM(IIF([Section3] = 'MIS'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MIS]
        ,SUM(IIF([Section3] = 'MIS_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred MIS_LGE]
        ,SUM(IIF([Section3] = 'MED'        ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'PRE_CAN'    ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'ON_CAN'     ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'ADD'        ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'LUG'        ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'MIS'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred UDL]
        ,SUM(IIF([Section3] = 'MED_LGE'    ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'PRE_CAN_LGE',[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'ON_CAN_LGE' ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'ADD_LGE'    ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'LUG_LGE'    ,[NetIncurredMovementIncRecoveries],0)) +
         SUM(IIF([Section3] = 'MIS_LGE'    ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred UDL_LGE]
        ,SUM(IIF([Section3] = 'CAT'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred CAT]
        ,SUM(IIF([Section3] = 'COV'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred COV]
        ,SUM(IIF([Section3] = 'OTH'        ,[NetIncurredMovementIncRecoveries],0))   AS [Incurred OTH]

    FROM [db-au-actuary].[cng].[Claim_Header]
    GROUP BY [PolicyKey],[ProductCode]
)

SELECT 
     ds.[BIRowID]
    ,ds.[Domain Country]
    ,ds.[Company]
    ,ds.[PolicyKey]
    ,ds.[Base Policy No]
    ,ds.[Policy Status]
    ,ds.[Issue Date]
    ,ds.[Posting Date]
    ,ds.[Last Transaction Issue Date]
    ,ds.[Last Transaction Posting Date]
    ,ds.[Transaction Type]
    --,ds.[Departure Date]
    --,ds.[Return Date]
    --,ds.[Lead Time]
    --,ds.[Trip Duration]
    --,ds.[Trip Length]
	,COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date],ds.[Issue Date]                ) AS [Departure Date]
    ,COALESCE(tr.[Return Date]   ,pp.[TripEnd]  ,ds.[Return Date]   ,DATEADD(year,1,ds.[Issue Date])) AS [Return Date]
    ,CASE WHEN DATEDIFF(DAY,ds.[Issue Date],COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date],ds.[Issue Date])) > 0
          THEN DATEDIFF(DAY,ds.[Issue Date],COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date],ds.[Issue Date]))   
          ELSE 0
     END AS [Lead Time]
    ,CASE WHEN DATEDIFF(DAY,COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date],ds.[Issue Date]),COALESCE(tr.[Return Date],pp.[TripEnd],ds.[Return Date],DATEADD(year,1,ds.[Issue Date]))) + 1 > 0
          THEN DATEDIFF(DAY,COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date],ds.[Issue Date]),COALESCE(tr.[Return Date],pp.[TripEnd],ds.[Return Date],DATEADD(year,1,ds.[Issue Date]))) + 1
          ELSE 0
     END AS [Trip Duration]
    ,CASE WHEN ds.[TRIPS Policy] = 1 
          THEN ds.[Trip Length]
          WHEN DATEDIFF(DAY,COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date],ds.[Issue Date]),COALESCE(tr.[Return Date],pp.[TripEnd],ds.[Return Date],DATEADD(year,1,ds.[Issue Date]))) + 1 > 0
          THEN DATEDIFF(DAY,COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date],ds.[Issue Date]),COALESCE(tr.[Return Date],pp.[TripEnd],ds.[Return Date],DATEADD(year,1,ds.[Issue Date]))) + 1
          ELSE 0
     END AS [Trip Length]
    ,ds.[Maximum Trip Length]
    ,ds.[Area Name]
    ,ds.[Area Number]
    ,pp.[Area]
    ,pp.[AreaCode]
    ,ds.[Destination]
    ,pp.[MultiDestination] AS [Multi Destination]
    ,ds.[Excess]
    ,ds.[Group Policy]
    ,ds.[Has Rental Car]
    ,ds.[Has Motorcycle]
    ,ds.[Has Wintersport]
    ,ds.[Has Medical]
    ,ds.[Has Cruise]
    ,ds.[Single/Family]
    ,ds.[Purchase Path]
    ,ds.[TRIPS Policy]
    ,ds.[Product Code]
    ,ds.[Plan Code]
    ,ds.[Plan Name]
    ,ds.[Product Name]
    ,ds.[Product Plan]
    ,ds.[Product Type]
    ,CASE WHEN COALESCE(do.[JV Description],po.[JV Description]) IN ('CBA NAC','BW NAC') THEN 'NAC'
          WHEN ds.[Product Group] = ''     THEN 'Travel'
          WHEN ds.[Product Group] = 'NULL' THEN 'Travel'
          WHEN ds.[Product Group] IS NULL  THEN 'Travel'
          ELSE ds.[Product Group]
     END AS [Product Group]
    ,CASE WHEN ds.[Trip Type] = 'Car Hire'      THEN 'Car Hire'
          WHEN ds.[Policy Type] = ''            THEN 'Leisure'
          WHEN ds.[Policy Type] = 'Leisure_CBA' THEN 'Leisure'
          WHEN ds.[Policy Type] = 'Other'       THEN 'Leisure'
          WHEN ds.[Policy Type] = 'UNKNOWN'     THEN 'Leisure'          
          WHEN ds.[Policy Type] = 'NULL'        THEN 'Leisure'
          WHEN ds.[Policy Type] IS NULL         THEN 'Leisure'
          ELSE ds.[Policy Type]
     END AS [Policy Type]
    ,CASE WHEN ds.[Plan Type] = 'Other' THEN 'Corporate'
          WHEN ds.[Plan Type] = ''      THEN 'International'
          WHEN ds.[Plan Type] = 'NULL'  THEN 'International'
          WHEN ds.[Plan Type] IS NULL   THEN 'International'
          ELSE ds.[Plan Type]
     END AS [Plan Type]
    ,CASE WHEN ds.[Trip Type] = 'Annual Multi Trip' THEN 'AMT'
          WHEN ds.[Trip Type] = 'Other'             THEN 'Corporate'
          WHEN ds.[Trip Type] = 'Car Hire'          THEN 'Single Trip'
          WHEN ds.[Trip Type] = ''                  THEN 'Single Trip'
          WHEN ds.[Trip Type] IS NULL               THEN 'Single Trip'
          ELSE ds.[Trip Type]
     END AS [Trip Type]
    ,ds.[Product Classification]
    ,ds.[Finance Product Code]
    ,ds.[OutletKey]
    ,ds.[Alpha Code]
    ,pl.[LatestOutletKey] AS [Latest OutletKey]
    ,pl.[LatestAlphaCode] AS [Latest Alpha Code]
    ,ds.[Customer Post Code]
    ,ds.[Unique Traveller Count]
    ,ds.[Unique Charged Traveller Count]
    ,ds.[Traveller Count]
    ,ds.[Charged Traveller Count]
    ,ds.[Adult Traveller Count]
    ,ds.[EMC Traveller Count]
    ,ds.[Youngest Charged DOB]
    ,ds.[Oldest Charged DOB]
    ,ds.[Youngest Age]
    ,ds.[Oldest Age]
    ,ds.[Youngest Charged Age]
    ,ds.[Oldest Charged Age]
    ,ds.[Max EMC Score]
    ,ds.[Total EMC Score]
    ,ds.[EMC Tier Oldest Charged]
    ,ds.[EMC Tier Youngest Charged]
    ,ds.[Gender]
    ,ds.[Has EMC]
    ,ds.[Has Manual EMC]
    ,ds.[Charged Traveller 1 Gender]
    ,ds.[Charged Traveller 1 DOB]
    ,ds.[Charged Traveller 1 Has EMC]
    ,ds.[Charged Traveller 1 Has Manual EMC]
    ,ds.[Charged Traveller 1 EMC Score]
    ,ds.[Charged Traveller 1 EMC Reference]
    ,ds.[Charged Traveller 2 Gender]
    ,ds.[Charged Traveller 2 DOB]
    ,ds.[Charged Traveller 2 Has EMC]
    ,ds.[Charged Traveller 2 Has Manual EMC]
    ,ds.[Charged Traveller 2 EMC Score]
    ,ds.[Charged Traveller 2 EMC Reference]
    ,ds.[Charged Traveller 3 Gender]
    ,ds.[Charged Traveller 3 DOB]
    ,ds.[Charged Traveller 3 Has EMC]
    ,ds.[Charged Traveller 3 Has Manual EMC]
    ,ds.[Charged Traveller 3 EMC Score]
    ,ds.[Charged Traveller 3 EMC Reference]
    ,ds.[Charged Traveller 4 Gender]
    ,ds.[Charged Traveller 4 DOB]
    ,ds.[Charged Traveller 4 Has EMC]
    ,ds.[Charged Traveller 4 Has Manual EMC]
    ,ds.[Charged Traveller 4 EMC Score]
    ,ds.[Charged Traveller 4 EMC Reference]
    ,ds.[Charged Traveller 5 Gender]
    ,ds.[Charged Traveller 5 DOB]
    ,ds.[Charged Traveller 5 Has EMC]
    ,ds.[Charged Traveller 5 Has Manual EMC]
    ,ds.[Charged Traveller 5 EMC Score]
    ,ds.[Charged Traveller 5 EMC Reference]
    ,ds.[Charged Traveller 6 Gender]
    ,ds.[Charged Traveller 6 DOB]
    ,ds.[Charged Traveller 6 Has EMC]
    ,ds.[Charged Traveller 6 Has Manual EMC]
    ,ds.[Charged Traveller 6 EMC Score]
    ,ds.[Charged Traveller 6 EMC Reference]
    ,ds.[Charged Traveller 7 Gender]
    ,ds.[Charged Traveller 7 DOB]
    ,ds.[Charged Traveller 7 Has EMC]
    ,ds.[Charged Traveller 7 Has Manual EMC]
    ,ds.[Charged Traveller 7 EMC Score]
    ,ds.[Charged Traveller 7 EMC Reference]
    ,ds.[Charged Traveller 8 Gender]
    ,ds.[Charged Traveller 8 DOB]
    ,ds.[Charged Traveller 8 Has EMC]
    ,ds.[Charged Traveller 8 Has Manual EMC]
    ,ds.[Charged Traveller 8 EMC Score]
    ,ds.[Charged Traveller 8 EMC Reference]
    ,ds.[Charged Traveller 9 Gender]
    ,ds.[Charged Traveller 9 DOB]
    ,ds.[Charged Traveller 9 Has EMC]
    ,ds.[Charged Traveller 9 Has Manual EMC]
    ,ds.[Charged Traveller 9 EMC Score]
    ,ds.[Charged Traveller 9 EMC Reference]
    ,ds.[Charged Traveller 10 Gender]
    ,ds.[Charged Traveller 10 DOB]
    ,ds.[Charged Traveller 10 Has EMC]
    ,ds.[Charged Traveller 10 Has Manual EMC]
    ,ds.[Charged Traveller 10 EMC Score]
    ,ds.[Charged Traveller 10 EMC Reference]
    ,ds.[Commission Tier]
    ,ds.[Volume Commission]
    ,ds.[Discount]
    ,ds.[Base Base Premium]
    ,ds.[Base Premium]
    ,ds.[Canx Premium]
    ,ds.[Undiscounted Canx Premium]
    ,ds.[Rental Car Premium]
    ,ds.[Motorcycle Premium]
    ,ds.[Luggage Premium]
    ,ds.[Medical Premium]
    ,ds.[Winter Sport Premium]
    ,ds.[Cruise Premium]
    ,ds.[Luggage Increase]
    ,ds.[Rental Car Increase]
    ,ds.[Trip Cost]
    ,ds.[Unadjusted Sell Price]
    ,ds.[Unadjusted GST on Sell Price]
    ,ds.[Unadjusted Stamp Duty on Sell Price]
    ,ds.[Unadjusted Agency Commission]
    ,ds.[Unadjusted GST on Agency Commission]
    ,ds.[Unadjusted Stamp Duty on Agency Commission]
    ,ds.[Unadjusted Admin Fee]
    --,ds.[Sell Price]
    --,ds.[GST on Sell Price]
    --,ds.[Stamp Duty on Sell Price]
    --,ds.[Premium]
    ,IIF(hl.[Customer Policy Number] IS NOT NULL,hl.[Gross Premium Inc Taxes],ds.[Sell Price]              ) AS [Sell Price]
    ,IIF(hl.[Customer Policy Number] IS NOT NULL,hl.[GST Cost]               ,ds.[GST on Sell Price]       ) AS [GST on Sell Price]
    ,IIF(hl.[Customer Policy Number] IS NOT NULL,hl.[Stamp Duty]             ,ds.[Stamp Duty on Sell Price]) AS [Stamp Duty on Sell Price]
    ,IIF(hl.[Customer Policy Number] IS NOT NULL,hl.[Gross Premium Exc Taxes],ds.[Premium]                 ) AS [Premium]
    ,ds.[Risk Nett]
    ,ds.[GUG]
    ,ds.[Agency Commission]
    ,ds.[GST on Agency Commission]
    ,ds.[Stamp Duty on Agency Commission]
    ,ds.[Admin Fee]
    ,ds.[NAP]
    ,ds.[NAP (incl Tax)]
    ,COALESCE(pt.[Policy Count],ds.[Policy Count]) AS [Policy Count]
    ,ds.[Price Beat Policy]
    ,ds.[Competitor Name]
    ,ds.[Competitor Price]
    ,ds.[Category]
    ,ds.[ActuarialPolicyID] AS [PolicyID]

    ,CASE WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND COALESCE(do.[JV Description],po.[JV Description]) IN ('CBA NAC','CBA WL','BW NAC','BW WL')
          THEN 0
          WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND COALESCE(do.[Outlet Super Group],po.[Outlet Super Group]) IN ('Easy Travel Insurance')
          THEN 0
          WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND ds.[Product Code] IN ('APB','APC','API','APP','CMY','CTD','CTI','HIF',/*'IAL','NRI',*/'RCP','STY','SYC','SYE','TTI','VAR')
          THEN 0
          WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND ds.[Product Code] IN ('ABD','ABI','ABW','AHM','AIN','AIO','AIR','AIW','ANB','ANC','ANF','ATO','ATR','AWT','BCR','BJD',
                                                                                                                     'BJI','BJW','CBI','CCP','CCR','CHH','CMB','CMC','CMH','CMI','CMO','CMT','CMW','CPC','DII','DIT',
                                                                                                                     'DTP','DTS','FCC','FCI','FCO','FCT','FPG','FPP','FY2','FYE','FYI','FYP','GMC','GTS','HBC','HCC',
                                                                                                                     'HPC','ICC','IEC','MBC','MBM','MHA','MNC','MNM','NCC','NPG','NPP','OHT','PCR','TMT','VAI','VAS',
                                                                                                                     'VAW','VBC','VDC','VTC','VTI','WDI','WII','WJP','WJS','WTI')
          THEN 1
          WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2022-06-15' AND ds.[Product Code] IN ('IAL','NRI')
          THEN 1
          WHEN ds.[Domain Country] ='NZ' AND CAST(ds.[Issue Date] as date) >= '2020-10-27' AND ds.[Product Plan] IN ('AND Domestic Dom-ST'
                                                                                                                    ,'IAG Travel Insurance Dom-ST'
                                                                                                                    ,'NZO Options Dom-ST'
                                                                                                                    ,'YTI YourCover Travel Insurance Dom-ST')
          THEN 1
          WHEN ds.[Domain Country] ='NZ' AND CAST(ds.[Issue Date] as date) >= '2020-10-27' AND ds.[Product Plan] IN ('IAG Travel Insurance Inbound-ST'
                                                                                                                    ,'NZO Options Inbound-ST'
                                                                                                                    ,'YTI YourCover Travel Insurance Inbound-Plus')
          THEN 1
          WHEN ds.[Domain Country] ='NZ' AND CAST(ds.[Issue Date] as date) >= '2020-10-27' AND ds.[Product Plan] IN ('AIA Australia Travel Insurance Int-ST'
                                                                                                                    ,'AIW Worldwide Travel Insurance Int-ST','ANB Business Int  ST'
                                                                                                                    ,'ANF Air NZ Staff Travel Insurance Int-ST'
                                                                                                                    ,'ANI International Int-ST'
                                                                                                                    ,'MHN MH Insure Int-ST'
                                                                                                                    ,'NZO Options Int-ST'
                                                                                                                    ,'YTI YourCover Travel Insurance Int-ST-Y') AND ds.[Destination] = 'Australia' 
          THEN 1
          WHEN ds.[Domain Country] ='NZ' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND ds.[Product Plan] IN ('AIA Australia Travel Insurance Int-ST'
                                                                                                                    ,'AIW Worldwide Travel Insurance Int-ST'
                                                                                                                    ,'ANB Business Int  ST'
                                                                                                                    ,'ANF Air NZ Staff Travel Insurance Int-ST'
                                                                                                                    ,'ANI International Int-ST'
                                                                                                                    ,'MHN MH Insure Int-ST'
                                                                                                                    ,'NZO Options Int-ST'
                                                                                                                    ,'YTI YourCover Travel Insurance Int-ST-Y')
          THEN 1
          WHEN ds.[Domain Country] ='NZ' AND CAST(ds.[Issue Date] as date) >= '2020-10-27' AND ds.[Product Plan] IN ('IAG Travel Insurance Int-ST'
                                                                                                                    ,'WTP Westpac TravelPlus Int-ST') AND ds.[Destination] = 'Australia' 
          THEN 1
          WHEN ds.[Domain Country] ='NZ' AND CAST(ds.[Issue Date] as date) >= '2021-02-02' AND ds.[Product Plan] IN ('IAG Travel Insurance Int-ST'
                                                                                                                    ,'WTP Westpac TravelPlus Int-ST')
          THEN 1
          WHEN ds.[Domain Country] ='NZ' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND ds.[Product Code] IN ('WDI','WII','WTI')
          THEN 1
          ELSE 0
     END AS [Has COVID19]

    ,COALESCE(dr.[Country or Area]         ,'Missing') AS [Country or Area]
    ,COALESCE(dr.[Intermediate Region Name],'Missing') AS [Intermediate Region Name]
    ,COALESCE(dr.[Region Name]             ,'Missing') AS [Region Name]

    ,pc.[State] AS [Customer State]

    ,uw.[UW_Policy_Status]         AS [UW Policy Status]
    ,uw.[UW_Premium]               AS [UW Premium]
  --,uw.[Previous_Policy_Status]   AS [Previous Policy Status]
  --,uw.[Previous_UW_Premium]      AS [Previous UW Premium]
  --,uw.[Movement]                 AS [UW Movement]
  --,uw.[Total_Movement]           AS [UW Premium]
    ,uw.[UW_Premium_COVID19]       AS [UW Premium COVID19]
    ,uw.[Domain_Country]           AS [UW Domain Country]
    ,uw.[Issue_Mth]                AS [UW Issue Month]
  --,uw.[Rating_Group]             AS [UW Rating Group]
    ,CASE 
        WHEN uw.[Rating_Group] IS NOT NULL THEN uw.[Rating_Group]

        WHEN ds.[Domain Country] IN ('AU','NZ') AND COALESCE(do.[JV Description],po.[JV Description]) = 'Ticketek'  THEN 'Ticketek'

        WHEN ds.[Domain Country] IN ('AU','NZ') AND ds.[Product Code] IN ('CMC')                    THEN 'Corporate'
        WHEN ds.[Domain Country] IN ('AU')      AND ds.[Product Code] IN ('FCI','BJD','ABD','CTD')  THEN 'FCI + Coles'
        WHEN ds.[Domain Country] IN ('AU')      AND ds.[Product Code] IN ('ATO','ATR','VAR')        THEN 'Virgin'
        WHEN ds.[Domain Country] IN ('AU')      AND ds.[Product Code] IN ('RCP')                    THEN 'Halo'
        WHEN ds.[Domain Country] IN ('AU','NZ') AND ds.[Product Code] IN ('WDI','WTI','WD2','WT2')  THEN 'Webjet'


        WHEN ds.[Domain Country] IN ('AU') AND ds.[Plan Type] = 'Domestic' AND ds.[Product Code] = 'FYE'        THEN 'Domestic Canx'
        WHEN ds.[Domain Country] IN ('AU') AND ds.[Plan Type] = 'Domestic' AND ds.[Trip Type] = 'Cancellation'  THEN 'Domestic Canx'

        WHEN ds.[Domain Country] IN ('NZ') AND ds.[Product Code] IN ('AID','ANR')                               THEN 'ANZ + Domestic Canx'
        WHEN ds.[Domain Country] IN ('NZ') AND ds.[Plan Type] = 'Domestic' AND ds.[Trip Type] = 'Cancellation'  THEN 'ANZ + Domestic Canx'

        WHEN COALESCE(do.[JV Description],po.[JV Description]) IN ('CBA NAC','BW NAC') THEN 'NAC'

        ELSE 'GLM'
     END AS [UW Rating Group]
    ,uw.[JV_Description_Orig]      AS [UW JV Description Orig]
    ,uw.[JV_Group]                 AS [UW JV Group]
    ,uw.[Product_Code]             AS [UW Product Code]

    ,re.[GLM Freq MED]
    ,re.[GLM Freq CAN]
    ,re.[GLM Freq ADD]
    ,re.[GLM Freq LUG]
    ,re.[GLM Freq MIS]
    ,re.[GLM Freq UDL]
    ,re.[GLM Size MED]
    ,re.[GLM Size LGE]
    ,re.[GLM Size CAN]
    ,re.[GLM Size ADD]
    ,re.[GLM Size LUG]
    ,re.[GLM Size MIS]
    ,re.[GLM Size ULD]
    ,re.[GLM CPP MED]
    ,re.[GLM CPP LGE]
    ,re.[GLM CPP CAN]
    ,re.[GLM CPP ADD]
    ,re.[GLM CPP LUG]
    ,re.[GLM CPP MIS]
    ,COALESCE(re.[GLM CPP UDL],re.[UW_Premium] * 0.88 * 1.00/1.04) AS [GLM CPP UDL]
    ,COALESCE(re.[GLM CPP CAT],re.[UW_Premium] * 0.88 * 0.04/1.04) AS [GLM CPP CAT]
    ,COALESCE(re.[GLM CPP]    ,re.[UW_Premium] * 0.88            ) AS [GLM CPP]
    ,re.[GLM UWP MED]
    ,re.[GLM UWP LGE]
    ,re.[GLM UWP CAN]
    ,re.[GLM UWP ADD]
    ,re.[GLM UWP LUG]
    ,re.[GLM UWP MIS]
    ,COALESCE(re.[GLM UWP UDL],re.[UW_Premium] * 1.00/1.04) AS [GLM UWP UDL]
    ,COALESCE(re.[GLM UWP CAT],re.[UW_Premium] * 0.04/1.04) AS [GLM UWP CAT]
    ,re.[UW_Premium] AS [GLM UWP]

    ,COALESCE(do.[Outlet Name]              ,po.[Outlet Name])              AS [Outlet Name]
    ,COALESCE(do.[Outlet Sub Group Code]    ,po.[Outlet Sub Group Code])    AS [Outlet Sub Group Code]
    ,COALESCE(do.[Outlet Sub Group Name]    ,po.[Outlet Sub Group Name])    AS [Outlet Sub Group Name]
    ,COALESCE(do.[Outlet Group Code]        ,po.[Outlet Group Code])        AS [Outlet Group Code]
    ,COALESCE(do.[Outlet Group Name]        ,po.[Outlet Group Name])        AS [Outlet Group Name]
    ,COALESCE(do.[Outlet Super Group]       ,po.[Outlet Super Group])       AS [Outlet Super Group]
    ,COALESCE(do.[Outlet Channel]           ,po.[Outlet Channel])           AS [Outlet Channel]
    ,COALESCE(do.[Outlet BDM]               ,po.[Outlet BDM])               AS [Outlet BDM]
    ,COALESCE(do.[Outlet Post Code]         ,po.[Outlet Post Code])         AS [Outlet Post Code]
    ,COALESCE(do.[Outlet Sales State Area]  ,po.[Outlet Sales State Area])  AS [Outlet Sales State Area]
    ,COALESCE(do.[Outlet Trading Status]    ,po.[Outlet Trading Status])    AS [Outlet Trading Status]
    ,COALESCE(do.[Outlet Type]              ,po.[Outlet Type])              AS [Outlet Type]

    ,COALESCE(ldo.[Outlet Name]             ,lpo.[Outlet Name])             AS [Latest Outlet Name]
    ,COALESCE(ldo.[Outlet Sub Group Code]   ,lpo.[Outlet Sub Group Code])   AS [Latest Outlet Sub Group Code]
    ,COALESCE(ldo.[Outlet Sub Group Name]   ,lpo.[Outlet Sub Group Name])   AS [Latest Outlet Sub Group Name]
    ,COALESCE(ldo.[Outlet Group Code]       ,lpo.[Outlet Group Code])       AS [Latest Outlet Group Code]
    ,COALESCE(ldo.[Outlet Group Name]       ,lpo.[Outlet Group Name])       AS [Latest Outlet Group Name]
    ,COALESCE(ldo.[Outlet Super Group]      ,lpo.[Outlet Super Group])      AS [Latest Outlet Super Group]
    ,COALESCE(ldo.[Outlet Channel]          ,lpo.[Outlet Channel])          AS [Latest Outlet Channel]
    ,COALESCE(ldo.[Outlet BDM]              ,lpo.[Outlet BDM])              AS [Latest Outlet BDM]
    ,COALESCE(ldo.[Outlet Post Code]        ,lpo.[Outlet Post Code])        AS [Latest Outlet Post Code]
    ,COALESCE(ldo.[Outlet Sales State Area] ,lpo.[Outlet Sales State Area]) AS [Latest Outlet Sales State Area]
    ,COALESCE(ldo.[Outlet Trading Status]   ,lpo.[Outlet Trading Status])   AS [Latest Outlet Trading Status]
    ,COALESCE(ldo.[Outlet Type]             ,lpo.[Outlet Type])             AS [Latest Outlet Type]

    ,pt.[Base CRM Username]
    ,ip.[CBA ChannelID]
    ,CASE 
        WHEN COALESCE(do.[JV Code],po.[JV Code]) NOT IN ('6A','6B','6C','6D')  THEN NULL
        WHEN ip.[CBA ChannelID] = 'CBAAPP'                                     THEN 'App'
        WHEN ip.[CBA ChannelID] = 'CBANB'                                      THEN 'NetBank'
        WHEN ip.[CBA ChannelID] IS NULL AND pt.[Base CRM Username] IS NULL     THEN 'NetBank'
        WHEN ip.[CBA ChannelID] IS NULL AND pt.[Base CRM Username] IS NOT NULL THEN 'Phone'
     END AS [CBA Channel]

    ,COALESCE(do.[JV Code]                  ,po.[JV Code])                  AS [JV Code]
    ,COALESCE(do.[JV Description]           ,po.[JV Description])           AS [JV Description]
    ,COALESCE(ldo.[JV Code]                 ,lpo.[JV Code])                 AS [Latest JV Code]
    ,COALESCE(ldo.[JV Description]          ,lpo.[JV Description])          AS [Latest JV Description]
   
    ,CASE 
        WHEN ds.[Company] = 'TIP' AND (ds.[Issue Date] >= '2017-06-01' OR (ds.[Alpha Code] IN ('APN0004', 'APN0005') AND ds.[Issue Date] >= '2017-07-01')) THEN 'TIP-ZURICH'
        WHEN ds.[Company] = 'TIP' AND (ds.[Issue Date] <  '2017-06-01' OR (ds.[Alpha Code] IN ('APN0004', 'APN0005') AND ds.[Issue Date] <  '2017-07-01')) THEN 'TIP-GLA'

        WHEN ds.[Domain Country] IN ('AU','NZ') AND ds.[Issue Date] >= '2017-06-01'                                    THEN 'ZURICH'
        WHEN ds.[Domain Country] IN ('AU','NZ') AND ds.[Issue Date] >= '2009-07-01' and ds.[Issue Date] < '2017-06-01' THEN 'GLA'
        WHEN ds.[Domain Country] IN ('AU','NZ') AND ds.[Issue Date] <  '2009-07-01'                                    THEN 'VERO'

        WHEN ds.[Domain Country] IN ('UK') AND ds.[Issue Date] >= '2009-09-01' THEN 'ETI'
        WHEN ds.[Domain Country] IN ('UK') AND ds.[Issue Date] <  '2009-09-01' THEN 'UKU'

        WHEN ds.[Domain Country] IN ('CN')      THEN 'CCIC'
        WHEN ds.[Domain Country] IN ('ID')      THEN 'Simas Net'
        WHEN ds.[Domain Country] IN ('MY','SG') THEN 'ETIQA'
        WHEN ds.[Domain Country] IN ('US')      THEN 'AON'

        ELSE 'OTHER' 
     END AS Underwriter

    ,cl.[ClaimCount]
    ,cl.[SectionCount]
    ,cl.[SectionCountNonNil]
    ,cl.[NetIncurredMovementIncRecoveries]
    ,cl.[NetPaymentMovementIncRecoveries]

	,cl.[Sections MED]
	,cl.[Sections MED_LGE]
	,cl.[Sections PRE_CAN]
	,cl.[Sections PRE_CAN_LGE]
	,cl.[Sections ON_CAN]
	,cl.[Sections ON_CAN_LGE]
	,cl.[Sections ADD]
	,cl.[Sections ADD_LGE]
	,cl.[Sections LUG]
	,cl.[Sections LUG_LGE]
	,cl.[Sections MIS]
	,cl.[Sections MIS_LGE]
	,cl.[Sections UDL]
	,cl.[Sections UDL_LGE]
	,cl.[Sections CAT]
	,cl.[Sections COV]
	,cl.[Sections OTH]

	,cl.[Sections Non-Nil MED]
	,cl.[Sections Non-Nil MED_LGE]
	,cl.[Sections Non-Nil PRE_CAN]
	,cl.[Sections Non-Nil PRE_CAN_LGE]
	,cl.[Sections Non-Nil ON_CAN]
	,cl.[Sections Non-Nil ON_CAN_LGE]
	,cl.[Sections Non-Nil ADD]
	,cl.[Sections Non-Nil ADD_LGE]
	,cl.[Sections Non-Nil LUG]
	,cl.[Sections Non-Nil LUG_LGE]
	,cl.[Sections Non-Nil MIS]
	,cl.[Sections Non-Nil MIS_LGE]
	,cl.[Sections Non-Nil UDL]
	,cl.[Sections Non-Nil UDL_LGE]
	,cl.[Sections Non-Nil CAT]
	,cl.[Sections Non-Nil COV]
	,cl.[Sections Non-Nil OTH]

	,cl.[Payments MED]
	,cl.[Payments MED_LGE]
	,cl.[Payments PRE_CAN]
	,cl.[Payments PRE_CAN_LGE]
	,cl.[Payments ON_CAN]
	,cl.[Payments ON_CAN_LGE]
	,cl.[Payments ADD]
	,cl.[Payments ADD_LGE]
	,cl.[Payments LUG]
	,cl.[Payments LUG_LGE]
	,cl.[Payments MIS]
	,cl.[Payments MIS_LGE]
	,cl.[Payments UDL]
	,cl.[Payments UDL_LGE]
	,cl.[Payments CAT]
	,cl.[Payments COV]
	,cl.[Payments OTH]

	,cl.[Incurred MED]
	,cl.[Incurred MED_LGE]
	,cl.[Incurred PRE_CAN]
	,cl.[Incurred PRE_CAN_LGE]
	,cl.[Incurred ON_CAN]
	,cl.[Incurred ON_CAN_LGE]
	,cl.[Incurred ADD]
	,cl.[Incurred ADD_LGE]
	,cl.[Incurred LUG]
	,cl.[Incurred LUG_LGE]
	,cl.[Incurred MIS]
	,cl.[Incurred MIS_LGE]
	,cl.[Incurred UDL]
	,cl.[Incurred UDL_LGE]
	,cl.[Incurred CAT]
	,cl.[Incurred COV]
	,cl.[Incurred OTH]

FROM DWHDataSetSummary ds
OUTER APPLY (
    SELECT TOP 1 *
    FROM DWHDataSet tr
    WHERE ds.[PolicyKey]    = tr.[PolicyKey]    AND
          ds.[Product Code] = tr.[Product Code] AND
          tr.[Policy Status] = 'Active'
    ORDER BY [Transaction Issue Date] DESC, [BIRowID] DESC
    ) tr
OUTER APPLY (
    SELECT *
    FROM penPolicy pp 
    WHERE ds.[PolicyKey]    = pp.[PolicyKey]   AND 
          ds.[Product Code] = pp.[Product Code]
    ) pp
OUTER APPLY (
    SELECT *
    FROM penPolicyTransSummary pt
    WHERE ds.[PolicyKey]    = pt.[PolicyKey]   AND 
          ds.[Product Code] = pt.[Product Code]
    ) pt
OUTER APPLY (
    SELECT *
    FROM impPolicies_CBA ip
    WHERE ds.[PolicyKey]    = ip.[PolicyKey]   AND 
          ds.[Product Code] = ip.[Product Code]
    ) ip
OUTER APPLY (
    SELECT TOP 1 *
    FROM dimOutlet do 
    WHERE ds.[OutletKey] = do.[Outlet Key]
    ORDER BY [LoadDate] DESC
    ) do
OUTER APPLY (
    SELECT TOP 1 *
    FROM penOutlet po 
    WHERE ds.[OutletKey] = po.[Outlet Key]
    ORDER BY [OutletStartDate] DESC
    ) po
OUTER APPLY (
    SELECT *
    FROM penOutletLineage pl
    WHERE ds.[OutletKey] = pl.[OutletKey]
    ) pl
OUTER APPLY (
    SELECT TOP 1 *
    FROM dimOutlet ldo 
    WHERE pl.[LatestOutletKey] = ldo.[Outlet Key]
    ORDER BY [LoadDate] DESC
    ) ldo
OUTER APPLY (
    SELECT TOP 1 *
    FROM penOutlet lpo 
    WHERE pl.[LatestOutletKey] = lpo.[Outlet Key]
    ORDER BY [OutletStartDate] DESC
    ) lpo
OUTER APPLY (
    SELECT *
    FROM Regions dr
    WHERE ds.[Destination] = dr.[Destination]
    ) dr
OUTER APPLY (
    SELECT TOP 1 *
    FROM Postcodes pc
    WHERE ds.[Customer Post Code] = pc.[postcode]
    ORDER BY [Count] DESC
    ) pc
OUTER APPLY (
    SELECT TOP 1 *
    FROM UK_Halo AS hl
    WHERE hl.[Customer Policy Number] = ds.[Base Policy No]
    ) hl
OUTER APPLY (
    SELECT TOP 1 * 
    FROM UWPremium uw 
    WHERE ds.[PolicyKey]    = uw.[PolicyKey] AND 
          ds.[Product Code] = uw.[Product_Code]
    ) uw
OUTER APPLY (
    SELECT * 
    FROM UWPremiumRescore re 
    WHERE ds.[PolicyKey]    = re.[PolicyKey] AND 
          ds.[Product Code] = re.[Product Code]
    ) re
OUTER APPLY (
    SELECT *
    FROM Claim_Header cl 
    WHERE ds.[PolicyKey]    = cl.[PolicyKey] AND 
          ds.[Product Code] = cl.[Product Code]
    ) cl

--LEFT JOIN DWHDataSet            tr ON ds.[PolicyKey] = tr.[PolicyKey]   AND ds.[Product Code] = tr.[Product Code]   AND tr.[Transaction Status] = 'Active'
--LEFT JOIN penPolicy             pp ON ds.[PolicyKey] = pp.[PolicyKey]   AND ds.[Product Code] = pp.[Product Code]
--LEFT JOIN penPolicyTransSummary pt ON ds.[PolicyKey] = pt.[PolicyKey]   AND ds.[Product Code] = pt.[Product Code]
--LEFT JOIN UWPremium             uw ON ds.[PolicyKey] = uw.[PolicyKey]   AND ds.[Product Code] = uw.[Product_Code]
--LEFT JOIN Claim_Header          cl ON ds.[PolicyKey] = cl.[PolicyKey]   AND ds.[Product Code] = cl.[Product Code]
--LEFT JOIN penOutlet             po ON ds.[OutletKey] = po.[Outlet Key]  AND po.[Rank] = 1
--LEFT JOIN dimOutlet             do ON ds.[OutletKey] = do.[Outlet Key]  AND do.[Rank] = 1
--LEFT JOIN Regions               dr ON ds.[Destination] = dr.[Destination]
--LEFT JOIN Postcodes             pc ON ds.[Customer Post Code] = pc.[postcode] AND pc.[Rank] = 1
--LEFT JOIN UK_Halo               hl ON hl.[Customer Policy Number] = ds.[Base Policy No]
;
GO
