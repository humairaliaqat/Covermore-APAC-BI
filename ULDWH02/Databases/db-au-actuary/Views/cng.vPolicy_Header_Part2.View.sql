USE [db-au-actuary]
GO
/****** Object:  View [cng].[vPolicy_Header_Part2]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vPolicy_Header_Part2] AS 

/****************************************************************************************************/
--  Name:           vPolicy_Header_Part2
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  2024-08-19 Cancellation Plus addon
/****************************************************************************************************/

WITH 
Policy_Header AS (
    SELECT 
         *
        ,CASE 
            WHEN CAST([Issue Date] as date) <= '2022-01-18' AND [JV Description]     IN ('Phone Sales','Websales')                       THEN -1
            WHEN CAST([Issue Date] as date) <= '2022-01-20' AND [JV Description] NOT IN ('Phone Sales','Websales')                       THEN -1
            WHEN CAST([Issue Date] as date) <= '2022-01-31' AND [JV Description] NOT IN ('Phone Sales','Websales') AND [Lead Time] >= 21 THEN -1
            WHEN CAST([Issue Date] as date) >= '2022-01-19' 
             AND [Lead Time]  >= 21
             AND [JV Description]     IN ('Phone Sales','Websales') 
             AND [Domain Country]     IN ('AU')   
             AND [Product Code]       IN ('ABD','ABI','ABW','AHM','AIN','AIO','AIR','AIW','ANC','ANF','ATO','BJD','BJI','BJW','CCP','CMB','CMC','CMH','CMW'
                                         ,'CPC','DII','DIT','DTP','FRG','FYI','FYP','GTS','ICC','MBC','MHA','NPP','PCR','VAS','VAW','VDC','VTC','WII','WJP'
                                         ,'IAL','NRI')
             AND [Product Plan] NOT LIKE '%-Med%'
             AND [Product Plan] NOT LIKE '%Medical%'
             AND [Product Plan] NOT LIKE '%Ess-%'
             AND [Product Plan] NOT LIKE '%Inbound%'
            THEN 1
            WHEN CAST([Issue Date] as date) >= '2022-01-19'
             AND [Lead Time]  >= 21
             AND [JV Description]     IN ('Phone Sales','Websales')
             AND [Domain Country]     IN ('NZ')   
             AND [Product Code]       IN ('AIA','AIW','AND','ANF','ANI','ETI','IAG','MHN','NZO','WDI','WII','WTI','WTP','YTI')
             AND [Product Plan] NOT LIKE '%-Med%'
             AND [Product Plan] NOT LIKE '%Medical%'
             AND [Product Plan] NOT LIKE '%Ess-%'
             AND [Product Plan] NOT LIKE '%Inbound%'
            THEN 1
            WHEN CAST([Issue Date] as date) >= '2022-02-01'
             AND [Lead Time]  >= 21
             AND [JV Description] NOT IN ('Phone Sales','Websales')
             AND [Domain Country]     IN ('AU')   
             AND [Product Code]       IN ('ABD','ABI','ABW','AHM','AIN','AIO','AIR','AIW','ANC','ANF','ATO','BJD','BJI','BJW','CCP','CMB','CMC','CMH','CMW'
                                         ,'CPC','DII','DIT','DTP','FRG','FYI','FYP','GTS','ICC','MBC','MHA','NPP','PCR','VAS','VAW','VDC','VTC','WII','WJP'
                                         ,'IAL','NRI')
             AND [Product Plan] NOT LIKE '%-Med%'
             AND [Product Plan] NOT LIKE '%Medical%'
             AND [Product Plan] NOT LIKE '%Ess-%'
             AND [Product Plan] NOT LIKE '%Inbound%'
            THEN 1
            WHEN CAST([Issue Date] as date) >= '2022-02-01'
             AND [Lead Time] >= 21
             AND [JV Description] NOT IN ('Phone Sales','Websales')
             AND [Domain Country]     IN ('NZ')   
             AND [Product Code]       IN ('AIA','AIW','AND','ANF','ANI','ETI','IAG','MHN','NZO','WDI','WII','WTI','WTP','YTI')
             AND [Product Plan] NOT LIKE '%-Med%'
             AND [Product Plan] NOT LIKE '%Medical%'
             AND [Product Plan] NOT LIKE '%Ess-%'
             AND [Product Plan] NOT LIKE '%Inbound%'
            THEN 1
            ELSE 0
         END AS [Has Pre-Trip]
        ,CASE WHEN [Has COVID19] = 1 THEN
            CASE WHEN [Domain Country] = ('AU') AND [Product Code] IN ('FYP','FYE','NPG')       AND CAST([Issue Date] as date) >= '2022-04-06' AND [Has Cruise] = 1 THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('NPP')                   AND CAST([Issue Date] as date) >= '2022-04-06' 
                                                                                                AND CAST([Issue Date] as date) <= '2022-06-28'                      THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('CBI','CPC','ICC','IEC') AND CAST([Issue Date] as date) >= '2022-04-20' AND [Has Cruise] = 1 THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('BCR','CCR','PCR')       AND CAST([Issue Date] as date) >= '2022-05-18'                      THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('AHM','MBC','MBM')       AND CAST([Issue Date] as date) >= '2022-05-18' AND [Has Cruise] = 1 THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('CMB','CMC')             AND CAST([Issue Date] as date) >= '2022-06-15'                      THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('NRI')                   AND CAST([Issue Date] as date) >= '2022-06-15' AND [Has Cruise] = 1 THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('NPP')                   AND CAST([Issue Date] as date) >= '2022-06-29' AND [Has Cruise] = 1 THEN 1
                 WHEN [Domain Country] = ('AU') AND [Product Code] IN ('WJP')                   AND CAST([Issue Date] as date) >= '2022-06-29' AND [Has Cruise] = 1 THEN 1
                 WHEN [Domain Country] = ('NZ') AND [Product Code] IN ('IAG','NZO','YTI')       AND CAST([Issue Date] as date) >= '2022-04-27' AND [Has Cruise] = 1 THEN 1 
                 ELSE 0
            END
            ELSE 0
         END AS [Has COVID19 Cruise]
        ,(SELECT MAX(v) 
          FROM (VALUES (CASE WHEN [Charged Traveller 1 Has EMC]  > 0 THEN [Charged Traveller 1 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 2 Has EMC]  > 0 THEN [Charged Traveller 2 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 3 Has EMC]  > 0 THEN [Charged Traveller 3 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 4 Has EMC]  > 0 THEN [Charged Traveller 4 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 5 Has EMC]  > 0 THEN [Charged Traveller 5 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 6 Has EMC]  > 0 THEN [Charged Traveller 6 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 7 Has EMC]  > 0 THEN [Charged Traveller 7 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 8 Has EMC]  > 0 THEN [Charged Traveller 8 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 9 Has EMC]  > 0 THEN [Charged Traveller 9 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 10 Has EMC] > 0 THEN [Charged Traveller 10 DOB] ELSE NULL END)
               ) AS value(v)
         ) AS [Youngest EMC DOB]
        ,(SELECT MIN(v) 
          FROM (VALUES (CASE WHEN [Charged Traveller 1 Has EMC]  > 0 THEN [Charged Traveller 1 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 2 Has EMC]  > 0 THEN [Charged Traveller 2 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 3 Has EMC]  > 0 THEN [Charged Traveller 3 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 4 Has EMC]  > 0 THEN [Charged Traveller 4 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 5 Has EMC]  > 0 THEN [Charged Traveller 5 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 6 Has EMC]  > 0 THEN [Charged Traveller 6 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 7 Has EMC]  > 0 THEN [Charged Traveller 7 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 8 Has EMC]  > 0 THEN [Charged Traveller 8 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 9 Has EMC]  > 0 THEN [Charged Traveller 9 DOB]  ELSE NULL END),
                       (CASE WHEN [Charged Traveller 10 Has EMC] > 0 THEN [Charged Traveller 10 DOB] ELSE NULL END)
               ) AS value(v)
         ) AS [Oldest EMC DOB]
    FROM [db-au-actuary].[cng].[Tmp_Policy_Header_Part1]
),

UW_Premium_Ratio AS (
    SELECT
         [Domain Country]
        ,EOMONTH([Issue Date]) AS [Issue Month]
        ,[JV Description]
        ,[Product Code]
        ,[Policy Type]
        ,[Plan Type]
        ,[Trip Type]
        ,SUM([Premium])     AS [Premium]
        ,SUM([UW Premium])  AS [UW Premium]
        ,SUM([UW Premium])/SUM([Premium]) AS [UW Premium %]
    FROM [db-au-actuary].[cng].[Tmp_Policy_Header_Part1]
    WHERE 
        EOMONTH([Issue Date]) = (SELECT MAX(EOMONTH([Issue Date])) FROM [db-au-actuary].[cng].[Tmp_Policy_Header_Part1] WHERE [UW Premium] > 0) AND 
        [Premium]    > 0 AND 
        [UW Premium] > 0
    GROUP BY 
         [Domain Country]
        ,EOMONTH([Issue Date])
        ,[JV Description]
        ,[Product Code]
        ,[Policy Type]
        ,[Plan Type]
        ,[Trip Type]
),

penPolicyAddOn AS (
    SELECT 
         [PolicyKey]
	    ,[ProductCode] AS [Product Code]

	    ,SUM(CASE WHEN [AddOnGroup] IN ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus')   THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Adventure Activities]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Aged Cover')                                                                               THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Aged Cover]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Ancillary Products','DUTY')                                                                THEN [GrossPremium] ELSE 0 END) AS [Gross Premium Ancillary Products]
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
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Ancillary Products','DUTY')                                                                THEN [UnAdjGrossPremium] ELSE 0 END) AS [UnAdj Gross Premium Ancillary Products]
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

	    ,SUM(CASE WHEN [AddOnGroup] IN ('Adventure Activities','Adventure Activities 2','Adventure Activities3','Adventure Plus')   /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Adventure Activities]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Aged Cover')                                                                               /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Aged Cover]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Ancillary Products','DUTY')                                                                /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Ancillary Products]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancel For Any Reason')                                                                    /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Cancel For Any Reason]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation')                                                                             /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Cancellation]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cancellation Plus Cover')                                                                  /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Cancellation Plus]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('COVID-19 Cover')                                                                           /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count COVID-19]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Cruise','Cruise Cover2')                                                                   /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Cruise]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Electronics')                                                                              /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Electronics]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Freely Activity Packs','Freely Benefit Packs')                                             /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Freely Packs]
        ,SUM(CASE WHEN [AddOnGroup] IN ('Medical')                                                                                  /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Medical]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Motorcycle','Motorcycle/Moped Riding')                                                     /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Motorcycle]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Luggage','Premium Luggage Cover','Optional Luggage Cover')                                 /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Luggage]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Rental Car','Self-Skippered Boat Excess')                                                  /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Rental Car]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('Winter Sport','Snow Sports','Snow Sports +','Snow Sports3','Snow Extras')                  /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Winter Sport]
	    ,SUM(CASE WHEN [AddOnGroup] IN ('TICKET')                                                                                   /*AND [GrossPremium] <> 0*/ THEN [AddonCount] ELSE 0 END) AS [Addon Count Ticket]

    FROM [db-au-actuary].[cng].[Tmp_penPolicyTransAddOn] --[ULDWH02].[db-au-cmdwh].[dbo].[penPolicyTransAddon]
    GROUP BY [PolicyKey],[ProductCode]
),

promoCode AS (
    SELECT 
         [PolicyKey]
        ,[ProductCode]      AS [Product Code]
        ,[PromoCode]        AS [Promo Code]
        ,[PromoName]        AS [Promo Name]
        ,[PromoType]        AS [Promo Type]
        ,[PromoDiscount]    AS [Promo Discount]
    FROM [db-au-actuary].[cng].[Tmp_penPolicyTransSummary]
    WHERE [AutoComments] = 'Base Policy Issued' AND [PromoCode] IS NOT NULL
    GROUP BY [PolicyKey],[ProductCode],[PromoCode],[PromoName],[PromoType],[PromoDiscount]
),

DWHDataSet AS (
    SELECT
         ds.[PolicyKey]
        ,ds.[Product Code]

        ,SUM([Sell Price]) AS [Sell Price - Total]

        ,SUM(CASE WHEN [Transaction Status] =  'Active'                                                                  THEN [Sell Price] ELSE 0 END) AS [Sell Price - Active]
        ,SUM(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END) AS [Sell Price - Active Base]
        ,SUM(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END) AS [Sell Price - Active Extension]

        ,SUM(CASE WHEN [Transaction Status] <> 'Active'                                                                  THEN [Sell Price] ELSE 0 END) AS [Sell Price - Cancelled]
        ,SUM(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END) AS [Sell Price - Cancelled Base]
        ,SUM(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END) AS [Sell Price - Cancelled Extension]

        ,SUM([Premium]) AS [Premium - Total]

        ,SUM(CASE WHEN [Transaction Status] =  'Active'                                                                  THEN [Premium] ELSE 0 END) AS [Premium - Active]
        ,SUM(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END) AS [Premium - Active Base]
        ,SUM(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END) AS [Premium - Active Extension]

        ,SUM(CASE WHEN [Transaction Status] <> 'Active'                                                                  THEN [Premium] ELSE 0 END) AS [Premium - Cancelled]
        ,SUM(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END) AS [Premium - Cancelled Base]
        ,SUM(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END) AS [Premium - Cancelled Extension]

        ,MIN(CASE WHEN [Transaction Status] =  'Active'                                                                  THEN [Transaction Issue Date] ELSE NULL END) AS [First Active Date]
        ,MIN(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [First Active Date - Base]
        ,MIN(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [First Active Date - Extension]
        ,MAX(CASE WHEN [Transaction Status] =  'Active'                                                                  THEN [Transaction Issue Date] ELSE NULL END) AS [Last Active Date]
        ,MAX(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [Last Active Date - Base]
        ,MAX(CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [Last Active Date - Extension]

        ,MIN(CASE WHEN [Transaction Status] <> 'Active'                                                                  THEN [Transaction Issue Date] ELSE NULL END) AS [First Cancelled Date]
        ,MIN(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [First Cancelled Date - Base]
        ,MIN(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [First Cancelled Date - Extension]
        ,MAX(CASE WHEN [Transaction Status] <> 'Active'                                                                  THEN [Transaction Issue Date] ELSE NULL END) AS [Last Cancelled Date]
        ,MAX(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [Last Cancelled Date - Base]
        ,MAX(CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Transaction Issue Date] ELSE NULL END) AS [Last Cancelled Date - Extension]

    FROM [db-au-actuary].[cng].[Tmp_DWHDataSet] ds
    OUTER APPLY (
        SELECT * 
        FROM [db-au-actuary].[cng].[Tmp_penPolicyTransSummary] pt 
        WHERE ds.[PolicyTransactionKey] = pt.[PolicyTransactionKey] AND 
              ds.[Product Code]         = pt.[ProductCode]
        ) pt
    WHERE pt.[UserComments] <> 'Topup Remediation'
    GROUP BY ds.[PolicyKey],ds.[Product Code]
),

penPolicyCreditNote AS (
    SELECT 
         *
        ,SUM([RedeemAmount]) OVER (PARTITION BY [CreditNoteNumber] ORDER BY [UpdateDateTime])      AS [RedeemAmountTotal]
        ,ROW_NUMBER()        OVER (PARTITION BY [CreditNoteNumber] ORDER BY [UpdateDateTime] DESC) AS [Rank]
    FROM [db-au-actuary].[cng].[Tmp_penPolicyCreditNote]
),

Run_Date AS (
    SELECT CAST(MAX([Posting Date]) AS date) AS [Run Date]
    FROM [db-au-actuary].[cng].[Tmp_DWHDataSet]
    WHERE [Product Name] <> 'Corporate'
)

SELECT 
     ph.[BIRowID]
    ,ph.[Domain Country]
    ,ph.[Company]
    ,ph.[PolicyKey]
    ,ph.[Base Policy No]
    ,ph.[Policy Status]
    ,ph.[Issue Date]
    ,ph.[Posting Date]
    ,ph.[Last Transaction Issue Date]
    ,ph.[Last Transaction Posting Date]
    ,ph.[Transaction Type]
    ,ph.[Departure Date]
    ,ph.[Return Date]
    ,ph.[Lead Time]
    ,ph.[Trip Duration]
    ,ph.[Trip Length]
    ,ph.[Maximum Trip Length]
    ,ph.[Area Name]
    ,ph.[Area Number]
    ,ph.[Area]
    ,ph.[AreaCode]
    ,ph.[Destination]
    ,ph.[Multi Destination]
    ,ph.[Excess]
    ,ph.[Group Policy]
    ,ph.[Has Rental Car]
    ,ph.[Has Motorcycle]
    ,ph.[Has Wintersport]
    ,ph.[Has Medical]
    ,ph.[Single/Family]
    ,ph.[Purchase Path]
    ,ph.[TRIPS Policy]
    ,ph.[Product Code]
    ,ph.[Plan Code]
    ,ph.[Product Name]
    ,ph.[Product Plan]
    ,ph.[Product Type]
    ,ph.[Product Group]
    ,ph.[Policy Type]
    ,ph.[Plan Type]
    ,ph.[Trip Type]
    ,ph.[Product Classification]
    ,ph.[Finance Product Code]
    ,ph.[OutletKey]
    ,ph.[Alpha Code]
    ,ph.[Latest OutletKey]
    ,ph.[Latest Alpha Code]
    ,ph.[Customer Post Code]
    ,ph.[Unique Traveller Count]
    ,ph.[Unique Charged Traveller Count]
    ,ph.[Traveller Count]
    ,ph.[Charged Traveller Count]
    ,ph.[Adult Traveller Count]
    ,ph.[EMC Traveller Count]
    ,ph.[Youngest Charged DOB]
    ,ph.[Oldest Charged DOB]
    ,ph.[Youngest Age]
    ,ph.[Oldest Age]
    ,ph.[Youngest Charged Age]
    ,ph.[Oldest Charged Age]
    ,ph.[Max EMC Score]
    ,ph.[Total EMC Score]
    ,ph.[Gender]
    ,ph.[Has EMC]
    ,ph.[Has Manual EMC]
    ,ph.[Charged Traveller 1 Gender]
    ,ph.[Charged Traveller 1 DOB]
    ,ph.[Charged Traveller 1 Has EMC]
    ,ph.[Charged Traveller 1 Has Manual EMC]
    ,ph.[Charged Traveller 1 EMC Score]
    ,ph.[Charged Traveller 1 EMC Reference]
    ,ph.[Charged Traveller 2 Gender]
    ,ph.[Charged Traveller 2 DOB]
    ,ph.[Charged Traveller 2 Has EMC]
    ,ph.[Charged Traveller 2 Has Manual EMC]
    ,ph.[Charged Traveller 2 EMC Score]
    ,ph.[Charged Traveller 2 EMC Reference]
    ,ph.[Charged Traveller 3 Gender]
    ,ph.[Charged Traveller 3 DOB]
    ,ph.[Charged Traveller 3 Has EMC]
    ,ph.[Charged Traveller 3 Has Manual EMC]
    ,ph.[Charged Traveller 3 EMC Score]
    ,ph.[Charged Traveller 3 EMC Reference]
    ,ph.[Charged Traveller 4 Gender]
    ,ph.[Charged Traveller 4 DOB]
    ,ph.[Charged Traveller 4 Has EMC]
    ,ph.[Charged Traveller 4 Has Manual EMC]
    ,ph.[Charged Traveller 4 EMC Score]
    ,ph.[Charged Traveller 4 EMC Reference]
    ,ph.[Charged Traveller 5 Gender]
    ,ph.[Charged Traveller 5 DOB]
    ,ph.[Charged Traveller 5 Has EMC]
    ,ph.[Charged Traveller 5 Has Manual EMC]
    ,ph.[Charged Traveller 5 EMC Score]
    ,ph.[Charged Traveller 5 EMC Reference]
    ,ph.[Charged Traveller 6 Gender]
    ,ph.[Charged Traveller 6 DOB]
    ,ph.[Charged Traveller 6 Has EMC]
    ,ph.[Charged Traveller 6 Has Manual EMC]
    ,ph.[Charged Traveller 6 EMC Score]
    ,ph.[Charged Traveller 6 EMC Reference]
    ,ph.[Charged Traveller 7 Gender]
    ,ph.[Charged Traveller 7 DOB]
    ,ph.[Charged Traveller 7 Has EMC]
    ,ph.[Charged Traveller 7 Has Manual EMC]
    ,ph.[Charged Traveller 7 EMC Score]
    ,ph.[Charged Traveller 7 EMC Reference]
    ,ph.[Charged Traveller 8 Gender]
    ,ph.[Charged Traveller 8 DOB]
    ,ph.[Charged Traveller 8 Has EMC]
    ,ph.[Charged Traveller 8 Has Manual EMC]
    ,ph.[Charged Traveller 8 EMC Score]
    ,ph.[Charged Traveller 8 EMC Reference]
    ,ph.[Charged Traveller 9 Gender]
    ,ph.[Charged Traveller 9 DOB]
    ,ph.[Charged Traveller 9 Has EMC]
    ,ph.[Charged Traveller 9 Has Manual EMC]
    ,ph.[Charged Traveller 9 EMC Score]
    ,ph.[Charged Traveller 9 EMC Reference]
    ,ph.[Charged Traveller 10 Gender]
    ,ph.[Charged Traveller 10 DOB]
    ,ph.[Charged Traveller 10 Has EMC]
    ,ph.[Charged Traveller 10 Has Manual EMC]
    ,ph.[Charged Traveller 10 EMC Score]
    ,ph.[Charged Traveller 10 EMC Reference]
    ,ph.[Commission Tier]
    ,ph.[Volume Commission]
    ,ph.[Discount]
    ,ph.[Base Base Premium]
    ,ph.[Base Premium]
    ,ph.[Canx Premium]
    ,ph.[Undiscounted Canx Premium]
    ,ph.[Rental Car Premium]
    ,ph.[Motorcycle Premium]
    ,ph.[Luggage Premium]
    ,ph.[Medical Premium]
    ,ph.[Winter Sport Premium]
    ,ph.[Luggage Increase]
    ,ph.[Trip Cost]
    ,ph.[Unadjusted Sell Price]
    ,ph.[Unadjusted GST on Sell Price]
    ,ph.[Unadjusted Stamp Duty on Sell Price]
    ,ph.[Unadjusted Agency Commission]
    ,ph.[Unadjusted GST on Agency Commission]
    ,ph.[Unadjusted Stamp Duty on Agency Commission]
    ,ph.[Unadjusted Admin Fee]
    ,ph.[Sell Price]
    ,ph.[GST on Sell Price]
    ,ph.[Stamp Duty on Sell Price]
    ,ph.[Premium]
    ,ph.[Risk Nett]
    ,ph.[GUG]
    ,ph.[Agency Commission]
    ,ph.[GST on Agency Commission]
    ,ph.[Stamp Duty on Agency Commission]
    ,ph.[Admin Fee]
    ,ph.[NAP]
    ,ph.[NAP (incl Tax)]
    ,ph.[Policy Count]
    ,ph.[Price Beat Policy]
    ,ph.[Competitor Name]
    ,ph.[Competitor Price]
    ,ph.[Category]
    ,ph.[Rental Car Increase]
    ,ph.[PolicyID]
    ,ph.[EMC Tier Oldest Charged]
    ,ph.[EMC Tier Youngest Charged]
    ,ph.[Has Cruise]
    ,ph.[Cruise Premium]
    ,ph.[Plan Name]
    ,ph.[Has COVID19]
    ,ph.[Has Pre-Trip]
    ,ph.[Has COVID19 Cruise]
    ,ph.[Country or Area]
    ,ph.[Intermediate Region Name]
    ,ph.[Region Name]
    ,ph.[Customer State]
    ,ph.[UW Policy Status]
    ,COALESCE(ph.[UW Premium],ph.[Premium]*uw.[UW Premium %],ph.[Premium]*0.38) AS [UW Premium]
    ,COALESCE(ph.[UW Premium COVID19],0) AS [UW Premium COVID19]
    ,ph.[UW Domain Country]
    ,ph.[UW Issue Month]
    ,ph.[UW Rating Group]
    ,ph.[UW JV Description Orig]
    ,ph.[UW JV Group]
    ,ph.[UW Product Code]
    ,ph.[GLM Freq MED]
    ,ph.[GLM Freq CAN]
    ,ph.[GLM Freq ADD]
    ,ph.[GLM Freq LUG]
    ,ph.[GLM Freq MIS]
    ,ph.[GLM Freq UDL]
    ,ph.[GLM Size MED]
    ,ph.[GLM Size LGE]
    ,ph.[GLM Size CAN]
    ,ph.[GLM Size ADD]
    ,ph.[GLM Size LUG]
    ,ph.[GLM Size MIS]
    ,ph.[GLM Size ULD]
    ,ph.[GLM CPP MED]
    ,ph.[GLM CPP LGE]
    ,ph.[GLM CPP CAN]
    ,ph.[GLM CPP ADD]
    ,ph.[GLM CPP LUG]
    ,ph.[GLM CPP MIS]
    ,ph.[GLM CPP UDL]
    ,ph.[GLM CPP CAT]
    ,ph.[GLM CPP]
    ,ph.[GLM UWP MED]
    ,ph.[GLM UWP LGE]
    ,ph.[GLM UWP CAN]
    ,ph.[GLM UWP ADD]
    ,ph.[GLM UWP LUG]
    ,ph.[GLM UWP MIS]
    ,ph.[GLM UWP UDL]
    ,ph.[GLM UWP CAT]
    ,ph.[GLM UWP]
    ,ph.[Outlet Name]
    ,ph.[Outlet Sub Group Code]
    ,ph.[Outlet Sub Group Name]
    ,ph.[Outlet Group Code]
    ,ph.[Outlet Group Name]
    ,ph.[Outlet Super Group]
    ,ph.[Outlet Channel]
    ,ph.[Outlet BDM]
    ,ph.[Outlet Post Code]
    ,ph.[Outlet Sales State Area]
    ,ph.[Outlet Trading Status]
    ,ph.[Outlet Type]
    ,ph.[Latest Outlet Name]
    ,ph.[Latest Outlet Sub Group Code]
    ,ph.[Latest Outlet Sub Group Name]
    ,ph.[Latest Outlet Group Code]
    ,ph.[Latest Outlet Group Name]
    ,ph.[Latest Outlet Super Group]
    ,ph.[Latest Outlet Channel]
    ,ph.[Latest Outlet BDM]
    ,ph.[Latest Outlet Post Code]
    ,ph.[Latest Outlet Sales State Area]
    ,ph.[Latest Outlet Trading Status]
    ,ph.[Latest Outlet Type]
    ,ph.[Base CRM Username]
    ,ph.[CBA ChannelID]
    ,ph.[CBA Channel]
    ,ph.[JV Code]
    ,ph.[JV Description]
    ,ph.[Latest JV Code]
    ,ph.[Latest JV Description]
    ,ph.[Underwriter]
    ,ph.[ClaimCount]
    ,ph.[SectionCount]
    ,ph.[SectionCountNonNil]
    ,ph.[NetIncurredMovementIncRecoveries]
    ,ph.[NetPaymentMovementIncRecoveries]
    ,ph.[Sections MED]
    ,ph.[Sections MED_LGE]
    ,ph.[Sections PRE_CAN]
    ,ph.[Sections PRE_CAN_LGE]
    ,ph.[Sections ON_CAN]
    ,ph.[Sections ON_CAN_LGE]
    ,ph.[Sections ADD]
    ,ph.[Sections ADD_LGE]
    ,ph.[Sections LUG]
    ,ph.[Sections LUG_LGE]
    ,ph.[Sections MIS]
    ,ph.[Sections MIS_LGE]
    ,ph.[Sections UDL]
    ,ph.[Sections UDL_LGE]
    ,ph.[Sections CAT]
    ,ph.[Sections COV]
    ,ph.[Sections OTH]
    ,ph.[Sections Non-Nil MED]
    ,ph.[Sections Non-Nil MED_LGE]
    ,ph.[Sections Non-Nil PRE_CAN]
    ,ph.[Sections Non-Nil PRE_CAN_LGE]
    ,ph.[Sections Non-Nil ON_CAN]
    ,ph.[Sections Non-Nil ON_CAN_LGE]
    ,ph.[Sections Non-Nil ADD]
    ,ph.[Sections Non-Nil ADD_LGE]
    ,ph.[Sections Non-Nil LUG]
    ,ph.[Sections Non-Nil LUG_LGE]
    ,ph.[Sections Non-Nil MIS]
    ,ph.[Sections Non-Nil MIS_LGE]
    ,ph.[Sections Non-Nil UDL]
    ,ph.[Sections Non-Nil UDL_LGE]
    ,ph.[Sections Non-Nil CAT]
    ,ph.[Sections Non-Nil COV]
    ,ph.[Sections Non-Nil OTH]
    ,ph.[Payments MED]
    ,ph.[Payments MED_LGE]
    ,ph.[Payments PRE_CAN]
    ,ph.[Payments PRE_CAN_LGE]
    ,ph.[Payments ON_CAN]
    ,ph.[Payments ON_CAN_LGE]
    ,ph.[Payments ADD]
    ,ph.[Payments ADD_LGE]
    ,ph.[Payments LUG]
    ,ph.[Payments LUG_LGE]
    ,ph.[Payments MIS]
    ,ph.[Payments MIS_LGE]
    ,ph.[Payments UDL]
    ,ph.[Payments UDL_LGE]
    ,ph.[Payments CAT]
    ,ph.[Payments COV]
    ,ph.[Payments OTH]
    ,ph.[Incurred MED]
    ,ph.[Incurred MED_LGE]
    ,ph.[Incurred PRE_CAN]
    ,ph.[Incurred PRE_CAN_LGE]
    ,ph.[Incurred ON_CAN]
    ,ph.[Incurred ON_CAN_LGE]
    ,ph.[Incurred ADD]
    ,ph.[Incurred ADD_LGE]
    ,ph.[Incurred LUG]
    ,ph.[Incurred LUG_LGE]
    ,ph.[Incurred MIS]
    ,ph.[Incurred MIS_LGE]
    ,ph.[Incurred UDL]
    ,ph.[Incurred UDL_LGE]
    ,ph.[Incurred CAT]
    ,ph.[Incurred COV]
    ,ph.[Incurred OTH]
    ,ph.[Youngest EMC DOB]
    ,ph.[Oldest EMC DOB]
    ,CASE WHEN ph.[Issue Date] IS NULL OR ph.[Youngest EMC DOB] IS NULL THEN -1
          ELSE FLOOR((DATEDIFF(MONTH,ph.[Youngest EMC DOB],[Issue Date]) - CASE WHEN DATEPART(DAY,ph.[Issue Date]) < DATEPART(DAY,ph.[Youngest EMC DOB]) THEN 1 ELSE 0 END) / 12 )
     END [Youngest EMC Age]
    ,CASE WHEN ph.[Issue Date] IS NULL OR ph.[Oldest EMC DOB] IS NULL THEN -1
          ELSE FLOOR((DATEDIFF(MONTH,ph.[Oldest EMC DOB],[Issue Date]) - CASE WHEN DATEPART(DAY,ph.[Issue Date]) < DATEPART(DAY,ph.[Oldest EMC DOB]) THEN 1 ELSE 0 END) / 12 )
     END [Oldest EMC Age]

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

    ,pc.[Promo Code]
    ,pc.[Promo Name]
    ,pc.[Promo Type]
    ,pc.[Promo Discount]

    ,pt.[Sell Price - Total]
    ,pt.[Sell Price - Active]
    ,pt.[Sell Price - Active Base]
    ,pt.[Sell Price - Active Extension]
    ,pt.[Sell Price - Cancelled]
    ,pt.[Sell Price - Cancelled Base]
    ,pt.[Sell Price - Cancelled Extension]

    ,pt.[Premium - Total]
    ,pt.[Premium - Active]
    ,pt.[Premium - Active Base]
    ,pt.[Premium - Active Extension]
    ,pt.[Premium - Cancelled]
    ,pt.[Premium - Cancelled Base]
    ,pt.[Premium - Cancelled Extension]

    ,pt.[First Active Date]
    ,pt.[First Active Date - Base]
    ,pt.[First Active Date - Extension]
    ,pt.[Last Active Date]
    ,pt.[Last Active Date - Base]
    ,pt.[Last Active Date - Extension]

    ,pt.[First Cancelled Date]
    ,pt.[First Cancelled Date - Base]
    ,pt.[First Cancelled Date - Extension]
    ,pt.[Last Cancelled Date]
    ,pt.[Last Cancelled Date - Base]
    ,pt.[Last Cancelled Date - Extension]

    ,DATEDIFF(DAY,ph.[Issue Date],pt.[First Cancelled Date - Base])     AS [Days to Cancelled]
    ,DATEDIFF(DAY,ph.[Issue Date],pt.[First Cancelled Date - Base])
     - 2 * (DATEPART(WEEK,pt.[First Cancelled Date - Base]) - DATEPART(WEEK,ph.[Issue Date]))
     - IIF(DATEPART(WEEKDAY,ph.[Issue Date])                  = 1,1,0) 
     - IIF(DATEPART(WEEKDAY,pt.[First Cancelled Date - Base]) = 7,1,0)  AS [Work Days to Cancelled]

    ,CASE WHEN ph.[Policy Status] = 'Active' AND pt.[First Cancelled Date - Base] IS NULL AND ph.[Departure Date] >  rd.[Run Date] THEN 'Active - Pre-Trip'
          WHEN ph.[Policy Status] = 'Active' AND pt.[First Cancelled Date - Base] IS NULL AND ph.[Return Date]    >= rd.[Run Date] THEN 'Active - On-Trip'
          WHEN ph.[Policy Status] = 'Active' AND pt.[First Cancelled Date - Base] IS NULL AND ph.[Return Date]    <  rd.[Run Date] THEN 'Active - Returned'
          WHEN ph.[Sell Price] <= 0          AND pt.[Sell Price - Cancelled] <  0 THEN 'Cancelled - Full Refund'
          WHEN ph.[Sell Price] >  0          AND pt.[Sell Price - Cancelled] <  0 THEN 'Cancelled - Partial Refund'
          WHEN pt.[Sell Price - Active] >  0 AND pt.[Sell Price - Cancelled] >= 0 THEN 'Cancelled - No Refund'
          WHEN pt.[Sell Price - Active] <= 0 AND pt.[Sell Price - Cancelled] >= 0 THEN 'Cancelled - No Premium to Refund'
                                                                                  ELSE 'Error'
     END AS [Policy Status Detailed]

    ,cn.[CreditNoteNumber]                                                  AS [Credit Note Number]
    ,cn.[CreateDateTime]                                                    AS [Credit Note Issue Date]
    ,cn.[CreditNoteStartDate]                                               AS [Credit Note Start Date]
    ,cn.[CreditNoteExpiryDate]                                              AS [Credit Note Expiry Date]
    ,CASE WHEN cn.[Amount] - COALESCE(cn.[RedeemAmount],0) = 0
          THEN 'Redeemed'
          ELSE cn.[Status]
     END                                                                    AS [Credit Note Status]
    ,cn.[RedeemAmountTotal] + cn.[Amount] - COALESCE(cn.[RedeemAmount],0)   AS [Credit Note Amount]
    ,CASE WHEN cn.[Status] = 'Expired' 
          THEN cn.[RedeemAmountTotal] + cn.[Amount] - COALESCE(cn.[RedeemAmount],0)
          ELSE cn.[RedeemAmountTotal]
     END                                                                    AS [Credit Note Amount Redeemed]
    ,CASE WHEN cn.[Status] = 'Expired' 
          THEN 0
          ELSE cn.[Amount] - COALESCE(cn.[RedeemAmount],0)
     END                                                                    AS [Credit Note Amount Remaining]

  --,rd.[Run Date]

 FROM      Policy_Header        ph
 LEFT JOIN penPolicyAddOn       pa ON ph.[PolicyKey] = pa.[PolicyKey] AND ph.[Product Code] = pa.[Product Code]
 LEFT JOIN promoCode            pc ON ph.[PolicyKey] = pc.[PolicyKey] AND ph.[Product Code] = pc.[Product Code]
 LEFT JOIN DWHDataSet           pt ON ph.[PolicyKey] = pt.[PolicyKey] AND ph.[Product Code] = pt.[Product Code]
 LEFT JOIN penPolicyCreditNote  cn ON ph.[PolicyKey] = cn.[OriginalPolicyKey] AND ph.[Product Code] = cn.[OriginalProductCode] AND cn.[Rank] = 1
 LEFT JOIN UW_Premium_Ratio     uw ON ph.[Domain Country] = uw.[Domain Country] AND
                                      ph.[Issue Date]     > uw.[Issue Month]    AND
                                      ph.[JV Description] = uw.[JV Description] AND
                                      ph.[Product Code]   = uw.[Product Code]   AND
                                      ph.[Policy Type]    = uw.[Policy Type]    AND
                                      ph.[Plan Type]      = uw.[Plan Type]      AND
                                      ph.[Trip Type]      = uw.[Trip Type]
CROSS JOIN Run_Date             rd

--OUTER APPLY (
--    SELECT *
--    FROM penPolicyAddOn pa 
--    WHERE ph.[PolicyKey]    = pa.[PolicyKey]   AND 
--          ph.[Product Code] = pa.[Product Code]
--    ) pa
--OUTER APPLY (
--    SELECT *
--    FROM promoCode pc 
--    WHERE ph.[PolicyKey]    = pc.[PolicyKey]   AND 
--          ph.[Product Code] = pc.[Product Code]
--    ) pc
--OUTER APPLY (
--    SELECT *
--    FROM DWHDataSet pt
--    WHERE ph.[PolicyKey]    = pt.[PolicyKey]   AND 
--          ph.[Product Code] = pt.[Product Code]
--    ) pt
--OUTER APPLY (
--    SELECT *
--    FROM penPolicyCreditNote cn
--    WHERE ph.[PolicyKey]    = cn.[OriginalPolicyKey]   AND 
--          ph.[Product Code] = cn.[OriginalProductCode] AND 
--          cn.[Rank] = 1
--    --ORDER BY [UpdateDateTime] DESC
--    ) cn
--OUTER APPLY (
--    SELECT *
--    FROM Run_Date rd
--    ) rd
;
GO
