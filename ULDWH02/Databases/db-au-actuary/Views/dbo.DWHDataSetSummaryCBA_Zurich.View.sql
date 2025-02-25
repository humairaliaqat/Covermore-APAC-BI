USE [db-au-actuary]
GO
/****** Object:  View [dbo].[DWHDataSetSummaryCBA_Zurich]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DWHDataSetSummaryCBA_Zurich] AS
WITH
penPolicyTransAddOn AS (
        SELECT
             a.[CountryKey]
            ,a.[CompanyKey]
            ,a.[PolicyTransactionKey]
            ,a.[AddOnGroup]
            ,a.[AddOnText]
            ,a.[CoverIncrease]
            ,a.[GrossPremium]
            ,a.[UnAdjGrossPremium]
            ,CASE WHEN b.[TransactionType] IN ('Base','Variation') AND b.[TransactionStatus] IN ('Active'                           ) THEN  1
                  WHEN b.[TransactionType] IN ('Base','Variation') AND b.[TransactionStatus] IN ('Cancelled','CancelledWithOverride') THEN -1
                  ELSE 0
             END AS [AddonCount]
            ,b.[PolicyKey]
            ,b.[TransactionStatus]
            ,b.[TransactionType]
            ,c.[ProductCode]
        FROM      [azsyddwh02].[db-au-CBA].[dbo].[penPolicyTransAddon]  a WITH(NOLOCK)
        LEFT JOIN [azsyddwh02].[db-au-CBA].[dbo].[penPolicyTransaction] b WITH(NOLOCK) ON a.[PolicyTransactionKey] = b.[PolicyTransactionKey]
        LEFT JOIN [azsyddwh02].[db-au-CBA].[dbo].[penPolicy]            c WITH(NOLOCK) ON b.[PolicyKey] = c.[PolicyKey]
),

penPolicyAddOn AS (
    SELECT 
         [PolicyKey]

	    ,SUM(CASE WHEN [AddOnGroup] IN ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus')   THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Adventure Activities]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Aged Cover')                                                                               THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Aged Cover]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Ancillary Products')                                                                       THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Ancillary Products]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancel For Any Reason')                                                                    THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Cancel For Any Reason]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation')                                                                             THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Cancellation]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation Plus Cover')                                                                  THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Cancellation Plus]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('COVID-19 Cover')                                                                           THEN [GrossPremium] ELSE 0 END) AS [Gross Premium COVID-19]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cruise','Cruise Cover2')                                                                   THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Cruise]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Electronics')                                                                              THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Electronics]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Freely Activity Packs','Freely Benefit Packs')                                             THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Freely Packs]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Medical')                                                                                  THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Medical]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Motorcycle','Motorcycle/Moped Riding')                                                     THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Motorcycle]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover')                                 THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Luggage]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Rental Car','Self-Skippered Boat Excess')                                                  THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Rental Car]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras')                  THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Winter Sport]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('TICKET')                                                                                   THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Ticket]

	    ,SUM(CASE WHEN [AddOnGroup] IN ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus')   THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Adventure Activities]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Aged Cover')                                                                               THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Aged Cover]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Ancillary Products')                                                                       THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Ancillary Products]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancel For Any Reason')                                                                    THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Cancel For Any Reason]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation')                                                                             THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Cancellation]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation Plus Cover')                                                                  THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Cancellation Plus]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('COVID-19 Cover')                                                                           THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium COVID-19]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cruise','Cruise Cover2')                                                                   THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Cruise]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Electronics')                                                                              THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Electronics]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Freely Activity Packs','Freely Benefit Packs')                                             THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Freely Packs]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Medical')                                                                                  THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Medical]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Motorcycle','Motorcycle/Moped Riding')                                                     THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Motorcycle]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover')                                 THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Luggage]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Rental Car','Self-Skippered Boat Excess')                                                  THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Rental Car]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras')                  THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Winter Sport]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('TICKET')                                                                                   THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Ticket]

	    ,SUM(CASE WHEN [AddOnGroup] IN ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus')   AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Adventure Activities]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Aged Cover')                                                                               AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Aged Cover]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Ancillary Products')                                                                       AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Ancillary Products]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancel For Any Reason')                                                                    AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Cancel For Any Reason]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation')                                                                             AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Cancellation]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation Plus Cover')                                                                  AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Cancellation Plus]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('COVID-19 Cover')                                                                           AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count COVID-19]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cruise','Cruise Cover2')                                                                   AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Cruise]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Electronics')                                                                              AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Electronics]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Freely Activity Packs','Freely Benefit Packs')                                             AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Freely Packs]
        ,SUM(CASE WHEN [AddOnGroup] IN ('Medical')                                                                                  AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Medical]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Motorcycle','Motorcycle/Moped Riding')                                                     AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Motorcycle]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover')                                 AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Luggage]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Rental Car','Self-Skippered Boat Excess')                                                  AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Rental Car]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras')                  AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Winter Sport]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('TICKET')                                                                                   AND [GrossPremium] <> 0 THEN [AddonCount] ELSE 0 END) AS [Addon Count Ticket]

    FROM penPolicyTransAddOn
    GROUP BY [PolicyKey]
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
    ,ds.[Last Transaction posting Date]
    ,ds.[Transaction Type]
    ,ds.[Departure Date]
    ,ds.[Return Date]
    ,ds.[Lead Time]
    ,ds.[Maximum Trip Length]
    ,ds.[Trip Duration]
    ,ds.[Trip Length]
    ,ds.[Area Name]
    ,ds.[Area Number]
    ,ds.[Destination]
    ,ds.[Excess]
    ,ds.[Group Policy]
    ,ds.[Has Rental Car]
    ,ds.[Has Motorcycle]
    ,ds.[Has Wintersport]
    ,ds.[Has Medical]
    ,ds.[Single/Family]
    ,ds.[Purchase Path]
    ,ds.[TRIPS Policy]
    ,ds.[Product Code]
    ,ds.[Plan Code]
    ,ds.[Product Name]
    ,ds.[Product Plan]
    ,ds.[Product Type]
    ,ds.[Product Group]
    ,ds.[Policy Type]
    ,ds.[Plan Type]
    ,ds.[Trip Type]
    ,ds.[Product Classification]
    ,ds.[Finance Product Code]
    ,ds.[OutletKey]
    ,ds.[Alpha Code]
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
    ,ds.[Luggage Increase]
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
    ,IIF(h.[Customer Policy Number] IS NOT NULL,h.[Gross Premium Inc Taxes],ds.[Sell Price]              ) AS [Sell Price]
    ,IIF(h.[Customer Policy Number] IS NOT NULL,h.[GST Cost]               ,ds.[GST on Sell Price]       ) AS [GST on Sell Price]
    ,IIF(h.[Customer Policy Number] IS NOT NULL,h.[Stamp Duty]             ,ds.[Stamp Duty on Sell Price]) AS [Stamp Duty on Sell Price]
    ,IIF(h.[Customer Policy Number] IS NOT NULL,h.[Gross Premium Exc Taxes],ds.[Premium]                 ) AS [Premium]
    ,ds.[Risk Nett]
    ,ds.[GUG]
    ,ds.[Agency Commission]
    ,ds.[GST on Agency Commission]
    ,ds.[Stamp Duty on Agency Commission]
    ,ds.[Admin Fee]
    ,ds.[NAP]
    ,ds.[NAP (incl Tax)]
    ,ds.[Policy Count]
    ,ds.[Price Beat Policy]
    ,ds.[Competitor Name]
    ,ds.[Competitor Price]
    ,ds.[Category]
    ,ds.[Rental Car Increase]
    ,ds.[ActuarialPolicyID]
    ,ds.[EMC Tier Oldest Charged]
    ,ds.[EMC Tier Youngest Charged]
    ,ds.[Has Cruise]
    ,ds.[Cruise Premium]
    ,ds.[Plan Name]

    ,ISNULL(do.[Outlet Name]            ,o.[Outlet Name])               AS [Outlet Name]
    ,ISNULL(do.[Outlet Sub Group Code]  ,o.[Outlet Sub Group Code])     AS [Outlet Sub Group Code]
    ,ISNULL(do.[Outlet Sub Group Name]  ,o.[Outlet Sub Group Name])     AS [Outlet Sub Group Name]
    ,ISNULL(do.[Outlet Group Code]      ,o.[Outlet Group Code])         AS [Outlet Group Code]
    ,ISNULL(do.[Outlet Group Name]      ,o.[Outlet Group Name])         AS [Outlet Group Name]
    ,CASE WHEN ISNULL(do.[Outlet Super Group],'') = '' AND ISNULL(o.[Outlet Super Group],'') =  '' THEN o.[Outlet Group Name]
          WHEN ISNULL(do.[Outlet Super Group],'') = '' AND ISNULL(o.[Outlet Super Group],'') <> '' THEN o.[Outlet Super Group]
          ELSE do.[Outlet Super Group] 
     END AS [Outlet Super Group]
    ,ISNULL(do.[Outlet Channel]         ,o.[Outlet Channel])            AS [Outlet Channel]
    ,ISNULL(do.[Outlet BDM]             ,o.[Outlet BDM])                AS [Outlet BDM]
    ,ISNULL(do.[Outlet Post Code]       ,o.[Outlet Post Code])          AS [Outlet Post Code]
    ,ISNULL(do.[Outlet Sales State Area],o.[Outlet Sales State Area])   AS [Outlet Sales State Area]
    ,ISNULL(do.[Outlet Trading Status]  ,o.[Outlet Trading Status])     AS [Outlet Trading Status]
    ,ISNULL(do.[Outlet Type]            ,o.[Outlet Type])               AS [Outlet Type]

    ,CASE 
        WHEN ISNULL(ds.[TRIPS Policy], 0) = 0 AND ISNULL(ds.[Purchase Path], '') <> ''  THEN ds.[Purchase Path]
        WHEN ds.[Oldest Age] < 70                                                       THEN 'Leisure'
        WHEN ds.[Area Number] = 'Area 1' THEN
            CASE
                WHEN ds.[Oldest Age] BETWEEN 70 AND 74 AND ds.[Trip Length] <   56 THEN ISNULL(ds.[Purchase Path],'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 75 AND 79 AND ds.[Trip Length] <   56 THEN ISNULL(ds.[Purchase Path],'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 80 AND 84 AND ds.[Trip Length] <   35 THEN ISNULL(ds.[Purchase Path],'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 85 AND 89 AND ds.[Trip Length] >= 180 THEN 'Invalid'
                WHEN ds.[Oldest Age] >= 90             AND ds.[Trip Length] >= 120 THEN 'Invalid'
                                                                                   ELSE 'Age Approved'
            END
        WHEN ds.[Area Number] IN ('Area 2','Area 3') THEN
            CASE
                WHEN ds.[Oldest Age] BETWEEN 70 AND 74 AND ds.[Trip Length] <  120 THEN ISNULL(ds.[Purchase Path],'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 75 AND 79 AND ds.[Trip Length] <   56 THEN ISNULL(ds.[Purchase Path],'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 80 AND 84 AND ds.[Trip Length] <   35 THEN ISNULL(ds.[Purchase Path],'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 85 AND 89 AND ds.[Trip Length] >= 180 THEN 'Invalid'
                WHEN ds.[Oldest Age] >= 90             AND ds.[Trip Length] >= 120 THEN 'Invalid'
                                                                                   ELSE 'Age Approved'
            END
        WHEN ds.[Area Number] IN ('Area 4','Area 5') THEN
            CASE
                WHEN ds.[Trip Length] >= 210                                       THEN 'Invalid'
                WHEN ds.[Oldest Age] < 80                                          THEN ISNULL(ds.[Purchase Path], 'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 80 AND 84 AND ds.[Trip Length] <  120 THEN ISNULL(ds.[Purchase Path],'Leisure')
                WHEN ds.[Oldest Age] BETWEEN 85 AND 89 AND ds.[Trip Length] >= 180 THEN 'Invalid'
                WHEN ds.[Oldest Age] >= 90             AND ds.[Trip Length] >= 120 THEN 'Invalid'
                                                                                   ELSE 'Age Approved'
            END
     END                                                                        AS [Derived Purchase Path]
    ,ISNULL(dp.[Derived Product Name]          ,ds.[Product Name])              AS [Derived Product Name]
    ,ISNULL(dp.[Derived Product Plan]          ,ds.[Product Plan])              AS [Derived Product Plan]
    ,ISNULL(dp.[Derived Product Type]          ,ds.[Product Type])              AS [Derived Product Type]
    ,ISNULL(dp.[Derived Product Group]         ,ds.[Product Group])             AS [Derived Product Group]
    ,ISNULL(dp.[Derived Policy Type]           ,ds.[Policy Type])               AS [Derived Policy Type]
    ,ISNULL(dp.[Derived Plan Type]             ,ds.[Plan Type])                 AS [Derived Plan Type]
    ,ISNULL(dp.[Derived Trip Type]             ,ds.[Trip Type])                 AS [Derived Trip Type]
    ,ISNULL(dp.[Derived Product Classification],ds.[Product Classification])    AS [Derived Product Classification]
    ,ISNULL(dp.[Derived Finance Product Code]  ,ds.[Finance Product Code])      AS [Derived Finance Product Code]

    ,ISNULL(do.[JV Code]                ,o.[JV Code])                   AS [JV Code]
    ,ISNULL(do.[JV Description]         ,o.[JV Description])            AS [JV Description]

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

	,COALESCE(tr.[Departure Date],pp.[TripStart],ds.[Departure Date]) AS [TripStart]
    ,COALESCE(tr.[Return Date]   ,pp.[TripEnd]  ,ds.[Return Date]   ) AS [TripEnd]

    ,pa.[Gross Premium Adventure Activities]
    ,pa.[Gross Premium Aged Cover]
    ,pa.[Gross Premium Ancillary Products]
    ,pa.[Gross Premium Cancel For Any Reason]
    ,pa.[Gross Premium Cancellation]
    ,pa.[Gross Premium Cancellation Plus]
    ,pa.[Gross Premium COVID-19]
    ,pa.[Gross Premium Cruise]
    ,pa.[Gross Premium Electronics]
    ,pa.[Gross Premium Freely Packs]
    ,pa.[Gross Premium Luggage]
    ,pa.[Gross Premium Medical]
    ,pa.[Gross Premium Motorcycle]
    ,pa.[Gross Premium Rental Car]
    ,pa.[Gross Premium Ticket]
    ,pa.[Gross Premium Winter Sport]

    ,pa.[UnAdj Gross Premium Adventure Activities]
    ,pa.[UnAdj Gross Premium Aged Cover]
    ,pa.[UnAdj Gross Premium Ancillary Products]
    ,pa.[UnAdj Gross Premium Cancel For Any Reason]
    ,pa.[UnAdj Gross Premium Cancellation]
    ,pa.[UnAdj Gross Premium Cancellation Plus]
    ,pa.[UnAdj Gross Premium COVID-19]
    ,pa.[UnAdj Gross Premium Cruise]
    ,pa.[UnAdj Gross Premium Electronics]
    ,pa.[UnAdj Gross Premium Freely Packs]
    ,pa.[UnAdj Gross Premium Luggage]
    ,pa.[UnAdj Gross Premium Medical]
    ,pa.[UnAdj Gross Premium Motorcycle]
    ,pa.[UnAdj Gross Premium Rental Car]
    ,pa.[UnAdj Gross Premium Ticket]
    ,pa.[UnAdj Gross Premium Winter Sport]

    ,pa.[Addon Count Adventure Activities]
    ,pa.[Addon Count Aged Cover]
    ,pa.[Addon Count Ancillary Products]
    ,pa.[Addon Count Cancel For Any Reason]
    ,pa.[Addon Count Cancellation]
    ,pa.[Addon Count Cancellation Plus]
    ,pa.[Addon Count COVID-19]
    ,pa.[Addon Count Cruise]
    ,pa.[Addon Count Electronics]
    ,pa.[Addon Count Freely Packs]
    ,pa.[Addon Count Luggage]
    ,pa.[Addon Count Medical]
    ,pa.[Addon Count Motorcycle]
    ,pa.[Addon Count Rental Car]
    ,pa.[Addon Count Ticket]
    ,pa.[Addon Count Winter Sport]

FROM [azsyddwh02].[db-au-actuary].[ws].[DWHDataSetSummary] ds WITH(NOLOCK)
LEFT JOIN penPolicyAddOn                                   pa ON ds.[PolicyKey] = pa.[PolicyKey]
OUTER APPLY (
    SELECT TOP 1 
         [OutletName]       AS [Outlet Name]
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
        ,[JV]               AS [JV Code]
        ,[JVDesc]           AS [JV Description]
    FROM [db-au-star].[dbo].[dimOutlet] do WITH(NOLOCK)
    WHERE do.[isLatest]  =  'Y' AND 
          do.[OutletKey] <> ''  AND 
          do.[OutletKey] = ds.[OutletKey]
    ) do
OUTER APPLY (
    SELECT TOP 1 
         [OutletName]       AS [Outlet Name]
        ,[SubGroupCode]     AS [Outlet Sub Group Code]
        ,[SubGroupName]     AS [Outlet Sub Group Name]
        ,[GroupCode]        AS [Outlet Group Code]
        ,[GroupName]        AS [Outlet Group Name]
        ,[SuperGroupName]   AS [Outlet Super Group]
        ,''                 AS [Outlet Channel]
        ,[BDMName]          AS [Outlet BDM]
        ,[ContactPostCode]  AS [Outlet Post Code]
        ,[StateSalesArea]   AS [Outlet Sales State Area]
        ,[TradingStatus]    AS [Outlet Trading Status]
        ,[OutletType]       AS [Outlet Type]
        ,[JVCode]           AS [JV Code]
        ,[JV]               AS [JV Description]
    FROM [azsyddwh02].[db-au-CBA].[dbo].[penOutlet] o WITH(NOLOCK)
    WHERE o.[OutletStatus] = 'Current' AND
          o.[OutletKey]    = ds.[OutletKey]
    ) o
OUTER APPLY (
    SELECT TOP 1 
         [ProductName]              AS [Derived Product Name]
        ,[ProductPlan]              AS [Derived Product Plan]
        ,[ProductType]              AS [Derived Product Type]
        ,[ProductGroup]             AS [Derived Product Group]
        ,[PolicyType]               AS [Derived Policy Type]
        ,[PlanType]                 AS [Derived Plan Type]
        ,[TripType]                 AS [Derived Trip Type]
        ,[ProductClassification]    AS [Derived Product Classification]
        ,[FinanceProductCode]       AS [Derived Finance Product Code]
    FROM [db-au-star].[dbo].[dimProduct] dp WITH(NOLOCK)
    WHERE (ds.[TRIPS Policy] = 1 OR ds.[Issue Date] < '2011-07-01') --Trips policies 
            AND
           dp.[ProductCode] = ds.[Product Code]                         
            AND
          (
           dp.[ProductPlan] = ds.[Plan Code]                                           OR
           dp.[ProductPlan] LIKE '%' + ds.[Plan Code]                                  OR
           dp.[ProductPlan] LIKE '%TRIPS' + ds.[Plan Code]                             OR
          (ds.[Plan Code] = 'DA' AND dp.[ProductPlan] LIKE '%' + ds.[Plan Code] + '%') OR
          (ds.[Plan Code] LIKE 'X%' AND ds.[Plan Code] <> 'X' AND dp.ProductPlan LIKE '%' + REPLACE(ds.[Plan Code],'X',''))
          )
    ) dp
OUTER APPLY (
    SELECT TOP 1 
         [PolicyKey]
        ,[Product Code]
        ,[Transaction Status]
        ,[Transaction Issue Date]
        ,[BIRowID]
        ,[Departure Date]
        ,[Return Date]
    FROM [azsyddwh02].[db-au-actuary].[ws].[DWHDataSet] tr WITH(NOLOCK)
    WHERE ds.[PolicyKey]    = tr.[PolicyKey]    AND
          ds.[Product Code] = tr.[Product Code] AND
          tr.[Transaction Status] = 'Active'
    ORDER BY [Transaction Issue Date] DESC, [BIRowID] DESC
    ) tr
OUTER APPLY (
    SELECT TOP 1 
         [PolicyKey]
        ,[PolicyNumber]
        ,[ProductCode]
        ,[TripStart]
        ,[TripEnd]
    FROM [azsyddwh02].[db-au-CBA].[dbo].[penPolicy] pp WITH(NOLOCK)
    WHERE pp.[PolicyKey]   = ds.[PolicyKey]   AND 
          pp.[ProductCode] = ds.[Product Code]
    ) pp
OUTER APPLY (
    SELECT
         [Customer Policy Number]
        ,SUM([Gross Premium Exc Taxes]) AS [Gross Premium Exc Taxes]
        ,SUM([GST Cost])                AS [GST Cost]
        ,SUM([Stamp Duty])              AS [Stamp Duty]
        ,SUM([Gross Premium Inc Taxes]) AS [Gross Premium Inc Taxes]
    FROM [db-au-actuary].[ws].[UK_Halo_SuperGroup] h WITH(NOLOCK)
    WHERE h.[Customer Policy Number] = ds.[Base Policy No]
    GROUP BY [Customer Policy Number]
    ) h
WHERE ds.[Domain Country] IN ('AU','NZ') AND CAST(ds.[Issue Date] as date) >= '2017-01-01' AND CAST(ds.[Issue Date] as date) <= EOMONTH(GETDATE(),-1)
GO
