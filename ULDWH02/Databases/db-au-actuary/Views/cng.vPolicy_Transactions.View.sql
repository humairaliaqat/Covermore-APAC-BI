USE [db-au-actuary]
GO
/****** Object:  View [cng].[vPolicy_Transactions]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [cng].[vPolicy_Transactions] AS 

/****************************************************************************************************/
--  Name:           vPolicy_Transactions
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  
/****************************************************************************************************/

WITH 
DWHDataSet AS (
    SELECT * 
    FROM [db-au-actuary].[cng].[Tmp_DWHDataSet]
),

Regions AS (
    SELECT df.[Destination],dr.*
    FROM [db-au-actuary].[cng].[Tmp_Destination_Fix]     df
    JOIN [db-au-actuary].[cng].[Tmp_Destination_Regions] dr ON df.[Fix] = dr.[Country or Area]
),

UWPremium AS (
    SELECT * FROM [db-au-actuary].[cng].[Tmp_UW_Premiums] WHERE [Rank] = 1
),

postcodes AS (
    SELECT
         RANK() OVER (PARTITION BY [postcode] ORDER BY COUNT(*) DESC) AS [Rank]
        ,[postcode]
        ,[state]
        ,COUNT(*) AS [Count]
    FROM [db-au-actuary].[cng].[Tmp_Postcodes]
    GROUP BY [postcode],[state] 
),

penPolicyTransSummary AS (
    SELECT 
         [PolicyTransactionKey]
        ,[PolicyKey]
        ,[ProductCode]
        ,[BasePolicyCount]
        ,[AutoComments]
        ,[UserComments]
        ,[TopUp]
        ,[RefundToCustomer]
        ,[CNStatus]
        ,[BasePolicyCountFix] AS [Policy Count]
    FROM [db-au-actuary].[cng].[Tmp_penPolicyTransSummary]
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
        ,[JVDesc]             AS [JV Description]
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
        ,[JV]               AS [JV Description]
    FROM  [db-au-actuary].[cng].[Tmp_penOutlet]
    WHERE [OutletStatus] = 'Current'
)

SELECT 
     ds.[BIRowID]
    ,ds.[Domain Country]
    ,ds.[Company]
    ,ds.[PolicyKey]
    ,ds.[Base Policy No]
    ,ds.[isParent]
    ,ds.[PolicyTransactionKey]
    ,ds.[Policy No]
    ,ds.[Policy Status]
    ,ds.[Issue Date]
    ,ds.[Transaction Issue Date]
    ,ds.[Posting Date]
    ,ds.[Transaction Type]
    ,ds.[Transaction Status]
    ,ds.[Departure Date]
    ,ds.[Return Date]
    ,ds.[Lead Time]
    ,ds.[Trip Duration]
    ,ds.[Trip Length]
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
    ,IIF(ds.[Product Group] IS NULL OR ds.[Product Group] IN ('','NULL')                                ,'Travel' ,ds.[Product Group]) AS [Product Group]
    ,IIF(ds.[Policy Type]   IS NULL OR ds.[Policy Type]   IN ('','NULL','UNKNOWN','Other','Leisure_CBA'),'Leisure',ds.[Policy Type]  ) AS [Policy Type]
    ,ds.[Plan Type]
    ,ds.[Trip Type]
    ,ds.[Product Classification]
    ,ds.[Finance Product Code]
    ,ds.[OutletKey]
    ,ds.[Alpha Code]
    ,ds.[Original Alpha Code]
    ,ds.[Transaction Alpha Code]
    ,ds.[Transaction OutletKey]
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
    ,ds.[Sell Price]
    ,ds.[GST on Sell Price]
    ,ds.[Stamp Duty on Sell Price]
    ,ds.[Premium]
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
    ,ds.[PolicyID]

    ,CASE WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND COALESCE(po.[JV Description],do.[JV Description]) IN ('CBA NAC','CBA WL','BW NAC','BW WL')
          THEN 0
          WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND COALESCE(po.[Outlet Super Group],do.[Outlet Super Group]) IN ('Easy Travel Insurance')
          THEN 0
          WHEN ds.[Domain Country] ='AU' AND CAST(ds.[Issue Date] as date) >= '2020-12-09' AND ds.[Product Code] IN ('APB','APC','API','APP','CMY','CTD','CTI','HIF','IAL','NRI','RCP','STY','SYC','SYE','TTI','VAR')
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

    ,pt.[AutoComments]
    ,pt.[UserComments]
    ,pt.[TopUp]
    ,pt.[RefundToCustomer]
    ,pt.[CNStatus]

	,COALESCE(pp.[TripStart],ds.[Departure Date],ds.[Issue Date]                ) AS [TripStart]
    ,COALESCE(pp.[TripEnd]  ,ds.[Return Date]   ,DATEADD(year,1,ds.[Issue Date])) AS [TripEnd]
    ,CASE WHEN DATEDIFF(DAY,ds.[Issue Date],COALESCE(pp.[TripStart],ds.[Departure Date],ds.[Issue Date]                )) > 0
          THEN DATEDIFF(DAY,ds.[Issue Date],COALESCE(pp.[TripStart],ds.[Departure Date],ds.[Issue Date]                ))   
          ELSE 0
     END AS [LeadTime]
    ,CASE WHEN DATEDIFF(DAY,COALESCE(pp.[TripStart],ds.[Departure Date],ds.[Issue Date]                ),COALESCE(pp.[TripEnd]  ,ds.[Return Date]   ,DATEADD(year,1,ds.[Issue Date]))) + 1 > 0
          THEN DATEDIFF(DAY,COALESCE(pp.[TripStart],ds.[Departure Date],ds.[Issue Date]                ),COALESCE(pp.[TripEnd]  ,ds.[Return Date]   ,DATEADD(year,1,ds.[Issue Date]))) + 1
          ELSE 0
     END AS [TripDuration]

    ,COALESCE(po.[Outlet Name]              ,do.[Outlet Name])              AS [Outlet Name]
    ,COALESCE(po.[Outlet Sub Group Code]    ,do.[Outlet Sub Group Code])    AS [Outlet Sub Group Code]
    ,COALESCE(po.[Outlet Sub Group Name]    ,do.[Outlet Sub Group Name])    AS [Outlet Sub Group Name]
    ,COALESCE(po.[Outlet Group Code]        ,do.[Outlet Group Code])        AS [Outlet Group Code]
    ,COALESCE(po.[Outlet Group Name]        ,do.[Outlet Group Name])        AS [Outlet Group Name]
    ,COALESCE(po.[Outlet Super Group]       ,do.[Outlet Super Group])       AS [Outlet Super Group]
    ,COALESCE(po.[Outlet Channel]           ,do.[Outlet Channel])           AS [Outlet Channel]
    ,COALESCE(po.[Outlet BDM]               ,do.[Outlet BDM])               AS [Outlet BDM]
    ,COALESCE(po.[Outlet Post Code]         ,do.[Outlet Post Code])         AS [Outlet Post Code]
    ,COALESCE(po.[Outlet Sales State Area]  ,do.[Outlet Sales State Area])  AS [Outlet Sales State Area]
    ,COALESCE(po.[Outlet Trading Status]    ,do.[Outlet Trading Status])    AS [Outlet Trading Status]
    ,COALESCE(po.[Outlet Type]              ,do.[Outlet Type])              AS [Outlet Type]

    ,COALESCE(po.[JV Code]                  ,do.[JV Code])                  AS [JV Code]
    ,COALESCE(po.[JV Description]           ,do.[JV Description])           AS [JV Description]
    
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

    ,[Sell Price] AS [Sell Price - Total]

    ,CASE WHEN [Transaction Status] =  'Active'                                                                  THEN [Sell Price] ELSE 0 END AS [Sell Price - Active]
    ,CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END AS [Sell Price - Active Base]
    ,CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END AS [Sell Price - Active Extension]

    ,CASE WHEN [Transaction Status] <> 'Active'                                                                  THEN [Sell Price] ELSE 0 END AS [Sell Price - Cancelled]
    ,CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END AS [Sell Price - Cancelled Base]
    ,CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Sell Price] ELSE 0 END AS [Sell Price - Cancelled Extension]

    ,[Premium] AS [Premium - Total]

    ,CASE WHEN [Transaction Status] =  'Active'                                                                  THEN [Premium] ELSE 0 END AS [Premium - Active]
    ,CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END AS [Premium - Active Base]
    ,CASE WHEN [Transaction Status] =  'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END AS [Premium - Active Extension]

    ,CASE WHEN [Transaction Status] <> 'Active'                                                                  THEN [Premium] ELSE 0 END AS [Premium - Cancelled]
    ,CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type]     IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END AS [Premium - Cancelled Base]
    ,CASE WHEN [Transaction Status] <> 'Active' AND [Transaction Type] NOT IN ('Base','Partial Refund','Refund') THEN [Premium] ELSE 0 END AS [Premium - Cancelled Extension]

FROM DWHDataSet ds
OUTER APPLY (
    SELECT *
    FROM Regions dr
    WHERE ds.[Destination] = dr.[Destination]
    ) dr
OUTER APPLY (
    SELECT * 
    FROM UWPremium uw 
    WHERE ds.[PolicyKey]    = uw.[PolicyKey] AND 
          ds.[Product Code] = uw.[Product_Code]
    ) uw
OUTER APPLY (
    SELECT TOP 1 *
    FROM postcodes pc
    WHERE ds.[Customer Post Code] = pc.[postcode]
    ORDER BY [Count] DESC
    ) pc
OUTER APPLY (
    SELECT * 
    FROM penPolicyTransSummary pt 
    WHERE ds.[PolicyTransactionKey] = pt.[PolicyTransactionKey] AND 
          ds.[Product Code]         = pt.[ProductCode]
    ) pt
OUTER APPLY (
    SELECT *
    FROM penPolicy pp 
    WHERE ds.[PolicyKey]    = pp.[PolicyKey]   AND 
          ds.[Product Code] = pp.[Product Code]
    ) pp
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
;
GO
