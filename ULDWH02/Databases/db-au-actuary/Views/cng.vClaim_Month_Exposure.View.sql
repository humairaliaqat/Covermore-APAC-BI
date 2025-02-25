USE [db-au-actuary]
GO
/****** Object:  View [cng].[vClaim_Month_Exposure]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vClaim_Month_Exposure] AS 

/****************************************************************************************************/
--  Name:           vClaim_Month_Exposure
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  
/****************************************************************************************************/

WITH Claim_Month_Exposure AS (
(
SELECT 
     b.[Domain Country]
    ,b.[Product Group]
    ,b.[Policy Type]
    ,b.[UW Rating Group]
    ,b.[JV Description] AS [JV]
    ,b.[Outlet Channel]
    ,CASE WHEN b.[Domain Country] = 'AU' AND b.[Plan Type] = 'International' AND b.[Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
          WHEN b.[Domain Country] = 'NZ' AND b.[Plan Type] = 'International' AND b.[Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
          ELSE b.[Plan Type]
     END AS [Plan Type]
    ,b.[Trip Type]
    ,b.[Product Plan]
    ,CASE WHEN (b.[Addon Count Cancel For Any Reason] > 0 OR b.[Gross Premium Cancel For Any Reason] > 0)
            THEN 'Yes'
            ELSE 'No'
     END AS [CFAR Flag]

    ,EOMONTH(a.[LossMonth])     AS [Month]
    ,EOMONTH(a.[IncurredMonth]) AS [Incurred Month]
    ,IIF(a.[LossDevelopmentMonth]<0,0,IIF(a.[LossDevelopmentMonth]>47,47,a.[LossDevelopmentMonth])) AS [Development Month]

    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[SectionCount],0))   AS [Sections MED]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[SectionCount],0))   AS [Sections MED_LGE]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[SectionCount],0))   AS [Sections CAN]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[SectionCount],0))   AS [Sections CAN_LGE]
    ,SUM(IIF(a.[Section3] = 'ADD'        ,a.[SectionCount],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[SectionCount],0))   AS [Sections ADD]
    ,SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[SectionCount],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[SectionCount],0))   AS [Sections ADD_LGE]
    ,SUM(IIF(a.[Section3] = 'LUG'        ,a.[SectionCount],0))   AS [Sections LUG]
    ,SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[SectionCount],0))   AS [Sections LUG_LGE]
    ,SUM(IIF(a.[Section3] = 'MIS'        ,a.[SectionCount],0))   AS [Sections MIS]
    ,SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[SectionCount],0))   AS [Sections MIS_LGE]
    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'ADD'        ,a.[SectionCount],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'LUG'        ,a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'MIS'        ,a.[SectionCount],0))   AS [Sections UDL]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[SectionCount],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[SectionCount],0)) + 
     SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[SectionCount],0))   AS [Sections UDL_LGE]
    ,SUM(IIF(a.[Section3] = 'CAT'        ,a.[SectionCount],0))   AS [Sections CAT]
    ,SUM(IIF(a.[Section3] = 'COV'        ,a.[SectionCount],0))   AS [Sections COV]
    ,SUM(IIF(a.[Section3] = 'OTH'        ,a.[SectionCount],0))   AS [Sections OTH]
    ,SUM(a.[SectionCount])                                       AS [Sections]

    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil MED]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil MED_LGE]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil CAN]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[SectionCountNonNil],0))   AS [Sections Non-Nil CAN_LGE]
    ,SUM(IIF(a.[Section3] = 'ADD'        ,a.[SectionCountNonNil],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil ADD]
    ,SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[SectionCountNonNil],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil ADD_LGE]
    ,SUM(IIF(a.[Section3] = 'LUG'        ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil LUG]
    ,SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil LUG_LGE]
    ,SUM(IIF(a.[Section3] = 'MIS'        ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil MIS]
    ,SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil MIS_LGE]
    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'ADD'        ,a.[SectionCountNonNil],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'LUG'        ,a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'MIS'        ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil UDL]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[SectionCountNonNil],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[SectionCountNonNil],0)) + 
     SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil UDL_LGE]
    ,SUM(IIF(a.[Section3] = 'CAT'        ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil CAT]
    ,SUM(IIF(a.[Section3] = 'COV'        ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil COV]
    ,SUM(IIF(a.[Section3] = 'OTH'        ,a.[SectionCountNonNil],0))   AS [Sections Non-Nil OTH]
    ,SUM(a.[SectionCountNonNil])                                       AS [Sections Non-Nil]

    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MED]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MED_LGE]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments CAN]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments CAN_LGE]
    ,SUM(IIF(a.[Section3] = 'ADD'        ,a.[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ADD]
    ,SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments ADD_LGE]
    ,SUM(IIF(a.[Section3] = 'LUG'        ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments LUG]
    ,SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments LUG_LGE]
    ,SUM(IIF(a.[Section3] = 'MIS'        ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MIS]
    ,SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments MIS_LGE]
    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'ADD'        ,a.[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'LUG'        ,a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'MIS'        ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments UDL]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0)) + 
     SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments UDL_LGE]
    ,SUM(IIF(a.[Section3] = 'CAT'        ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments CAT]
    ,SUM(IIF(a.[Section3] = 'COV'        ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments COV]
    ,SUM(IIF(a.[Section3] = 'OTH'        ,a.[NetPaymentMovementIncRecoveries] ,0))   AS [Payments OTH]
    ,SUM(a.[NetPaymentMovementIncRecoveries])                                        AS [Payments]

    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred MED]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred MED_LGE]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred CAN]
    ,SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred CAN_LGE]
    ,SUM(IIF(a.[Section3] = 'ADD'        ,a.[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred ADD]
    ,SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred ADD_LGE]
    ,SUM(IIF(a.[Section3] = 'LUG'        ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred LUG]
    ,SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred LUG_LGE]
    ,SUM(IIF(a.[Section3] = 'MIS'        ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred MIS]
    ,SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred MIS_LGE]
    ,SUM(IIF(a.[Section3] = 'MED'        ,a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN'    ,a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'ADD'        ,a.[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN'     ,a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'LUG'        ,a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'MIS'        ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred UDL]
    ,SUM(IIF(a.[Section3] = 'MED_LGE'    ,a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'PRE_CAN_LGE',a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'ADD_LGE'    ,a.[NetIncurredMovementIncRecoveries],0)) +
     SUM(IIF(a.[Section3] = 'ON_CAN_LGE' ,a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'LUG_LGE'    ,a.[NetIncurredMovementIncRecoveries],0)) + 
     SUM(IIF(a.[Section3] = 'MIS_LGE'    ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred UDL_LGE]
    ,SUM(IIF(a.[Section3] = 'CAT'        ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred CAT]
    ,SUM(IIF(a.[Section3] = 'COV'        ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred COV]
    ,SUM(IIF(a.[Section3] = 'OTH'        ,a.[NetIncurredMovementIncRecoveries],0))   AS [Incurred OTH]
    ,SUM(a.[NetIncurredMovementIncRecoveries])                                       AS [Incurred]

    ,0 AS [Policy MED - Active]
    ,0 AS [Policy CAN - Active]
    ,0 AS [Policy ADD - Active]
    ,0 AS [Policy LUG - Active]
    ,0 AS [Policy MIS - Active]
    ,0 AS [Policy - Active]

    ,0 AS [UW Premium MED]
    ,0 AS [UW Premium CAN]
    ,0 AS [UW Premium ADD]
    ,0 AS [UW Premium LUG]
    ,0 AS [UW Premium MIS]
    ,0 AS [UW Premium UDL]
    ,0 AS [UW Premium CAT]
    ,0 AS [UW Premium COV]
    ,0 AS [UW Premium]

    ,0 AS [Premium]

    ,0 AS [GLM Freq MED]
    ,0 AS [GLM Freq CAN]
    ,0 AS [GLM Freq ADD]
    ,0 AS [GLM Freq LUG]
    ,0 AS [GLM Freq MIS]
    ,0 AS [GLM Freq UDL]
    ,0 AS [GLM Freq]

    ,0 AS [GLM CPP MED]
    ,0 AS [GLM CPP LGE]
    ,0 AS [GLM CPP MED+LGE]
    ,0 AS [GLM CPP CAN]
    ,0 AS [GLM CPP ADD]
    ,0 AS [GLM CPP LUG]
    ,0 AS [GLM CPP MIS]
    ,0 AS [GLM CPP UDL]
    ,0 AS [GLM CPP CAT]
    ,0 AS [GLM CPP]

    --,0 AS [GLM UWP MED]
    --,0 AS [GLM UWP LGE]
    --,0 AS [GLM UWP MED+LGE]
    --,0 AS [GLM UWP CAN]
    --,0 AS [GLM UWP ADD]
    --,0 AS [GLM UWP LUG]
    --,0 AS [GLM UWP MIS]
    --,0 AS [GLM UWP UDL]
    --,0 AS [GLM UWP CAT]
    --,0 AS [GLM UWP]

FROM [db-au-actuary].[cng].[Claim_Transactions] a
JOIN [db-au-actuary].[cng].[Policy_Header]      b ON a.[PolicyKey] = b.[PolicyKey] AND a.[ProductCode] = b.[Product Code]

WHERE EOMONTH(a.[LossDate]) >= '2017-06-01' AND EOMONTH(b.[Issue Date]) >= '2017-06-01'

GROUP BY 
     b.[Domain Country]
    ,b.[Product Group]
    ,b.[Policy Type]
    ,b.[UW Rating Group]
    ,b.[JV Description]
    ,b.[Outlet Channel]
    ,CASE WHEN b.[Domain Country] = 'AU' AND b.[Plan Type] = 'International' AND b.[Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
          WHEN b.[Domain Country] = 'NZ' AND b.[Plan Type] = 'International' AND b.[Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
          ELSE b.[Plan Type]
     END
    ,b.[Trip Type]
    ,b.[Product Plan]
    ,CASE WHEN (b.[Addon Count Cancel For Any Reason] > 0 OR b.[Gross Premium Cancel For Any Reason] > 0)
          THEN 'Yes'
          ELSE 'No'
     END
    ,EOMONTH(a.[LossMonth])
    ,EOMONTH(a.[IncurredMonth])
    ,IIF(a.[LossDevelopmentMonth]<0,0,IIF(a.[LossDevelopmentMonth]>47,47,a.[LossDevelopmentMonth]))
)
UNION ALL
(
SELECT 
     [Domain Country]
    ,[Product Group]
    ,[Policy Type]
    ,[UW Rating Group]
    ,[JV Description] AS [JV]
    ,[Outlet Channel]
    ,[Plan Type]
    ,[Trip Type]
    ,[Product Plan]
    ,[CFAR Flag]

    ,[Month] AS [Month]
    ,[Month] AS [Incurred Month]
    ,0       AS [Development Month]

    ,0 AS [Sections MED]
    ,0 AS [Sections MED_LGE]
    ,0 AS [Sections CAN]
    ,0 AS [Sections CAN_LGE]
    ,0 AS [Sections ADD]
    ,0 AS [Sections ADD_LGE]
    ,0 AS [Sections LUG]
    ,0 AS [Sections LUG_LGE]
    ,0 AS [Sections MIS]
    ,0 AS [Sections MIS_LGE]
    ,0 AS [Sections UDL]
    ,0 AS [Sections UDL_LGE]
    ,0 AS [Sections CAT]
    ,0 AS [Sections COV]
    ,0 AS [Sections OTH]
    ,0 AS [Sections]

    ,0 AS [Sections Non-Nil MED]
    ,0 AS [Sections Non-Nil MED_LGE]
    ,0 AS [Sections Non-Nil CAN]
    ,0 AS [Sections Non-Nil CAN_LGE]
    ,0 AS [Sections Non-Nil ADD]
    ,0 AS [Sections Non-Nil ADD_LGE]
    ,0 AS [Sections Non-Nil LUG]
    ,0 AS [Sections Non-Nil LUG_LGE]
    ,0 AS [Sections Non-Nil MIS]
    ,0 AS [Sections Non-Nil MIS_LGE]
    ,0 AS [Sections Non-Nil UDL]
    ,0 AS [Sections Non-Nil UDL_LGE]
    ,0 AS [Sections Non-Nil CAT]
    ,0 AS [Sections Non-Nil COV]
    ,0 AS [Sections Non-Nil OTH]
    ,0 AS [Sections Non-Nil]

    ,0 AS [Payments MED]
    ,0 AS [Payments MED_LGE]
    ,0 AS [Payments CAN]
    ,0 AS [Payments CAN_LGE]
    ,0 AS [Payments ADD]
    ,0 AS [Payments ADD_LGE]
    ,0 AS [Payments LUG]
    ,0 AS [Payments LUG_LGE]
    ,0 AS [Payments MIS]
    ,0 AS [Payments MIS_LGE]
    ,0 AS [Payments UDL]
    ,0 AS [Payments UDL_LGE]
    ,0 AS [Payments CAT]
    ,0 AS [Payments COV]
    ,0 AS [Payments OTH]
    ,0 AS [Payments]

    ,0 AS [Incurred MED]
    ,0 AS [Incurred MED_LGE]
    ,0 AS [Incurred CAN]
    ,0 AS [Incurred CAN_LGE]
    ,0 AS [Incurred ADD]
    ,0 AS [Incurred ADD_LGE]
    ,0 AS [Incurred LUG]
    ,0 AS [Incurred LUG_LGE]
    ,0 AS [Incurred MIS]
    ,0 AS [Incurred MIS_LGE]
    ,0 AS [Incurred UDL]
    ,0 AS [Incurred UDL_LGE]
    ,0 AS [Incurred CAT]
    ,0 AS [Incurred COV]
    ,0 AS [Incurred OTH]
    ,0 AS [Incurred]

    ,SUM([Policy MED - Active]) AS [Policy MED - Active]
    ,SUM([Policy CAN - Active]) AS [Policy CAN - Active]
    ,SUM([Policy ADD - Active]) AS [Policy ADD - Active]
    ,SUM([Policy LUG - Active]) AS [Policy LUG - Active]
    ,SUM([Policy MIS - Active]) AS [Policy MIS - Active]
    ,SUM([Policy - Active])     AS [Policy - Active]

    ,SUM([UW Premium MED])  AS [UW Premium MED]
    ,SUM([UW Premium CAN])  AS [UW Premium CAN]
    ,SUM([UW Premium ADD])  AS [UW Premium ADD]
    ,SUM([UW Premium LUG])  AS [UW Premium LUG]
    ,SUM([UW Premium MIS])  AS [UW Premium MIS]
    ,SUM([UW Premium UDL])  AS [UW Premium UDL]
    ,SUM([UW Premium CAT])  AS [UW Premium CAT]
    ,SUM([UW Premium COV])  AS [UW Premium COV]
    ,SUM([UW Premium])      AS [UW Premium]

    ,SUM([Premium]) AS [Premium]

    ,SUM([GLM Freq MED])    AS [GLM Freq MED]
    ,SUM([GLM Freq CAN])    AS [GLM Freq CAN]
    ,SUM([GLM Freq ADD])    AS [GLM Freq ADD]
    ,SUM([GLM Freq LUG])    AS [GLM Freq LUG]
    ,SUM([GLM Freq MIS])    AS [GLM Freq MIS]
    ,SUM([GLM Freq UDL])    AS [GLM Freq UDL]
    ,SUM([GLM Freq]    )    AS [GLM Freq]

    ,SUM([GLM CPP MED])     AS [GLM CPP MED]
    ,SUM([GLM CPP LGE])     AS [GLM CPP LGE]
    ,SUM([GLM CPP MED+LGE]) AS [GLM CPP MED+LGE]
    ,SUM([GLM CPP CAN])     AS [GLM CPP CAN]
    ,SUM([GLM CPP ADD])     AS [GLM CPP ADD]
    ,SUM([GLM CPP LUG])     AS [GLM CPP LUG]
    ,SUM([GLM CPP MIS])     AS [GLM CPP MIS]
    ,SUM([GLM CPP UDL])     AS [GLM CPP UDL]
    ,SUM([GLM CPP CAT])     AS [GLM CPP CAT]
    ,SUM([GLM CPP])         AS [GLM CPP]

    --,SUM([GLM UWP MED])     AS [GLM UWP MED]
    --,SUM([GLM UWP LGE])     AS [GLM UWP LGE]
    --,SUM([GLM UWP MED+LGE]) AS [GLM UWP MED+LGE]
    --,SUM([GLM UWP CAN])     AS [GLM UWP CAN]
    --,SUM([GLM UWP ADD])     AS [GLM UWP ADD]
    --,SUM([GLM UWP LUG])     AS [GLM UWP LUG]
    --,SUM([GLM UWP MIS])     AS [GLM UWP MIS]
    --,SUM([GLM UWP UDL])     AS [GLM UWP UDL]
    --,SUM([GLM UWP CAT])     AS [GLM UWP CAT]
    --,SUM([GLM UWP])         AS [GLM UWP]

FROM [db-au-actuary].[cng].[Policy_Month_Summary_Exposure]

GROUP BY 
     [Domain Country]
    ,[Product Group]
    ,[Policy Type]
    ,[UW Rating Group]
    ,[JV Description]
    ,[Outlet Channel]
    ,[Plan Type]
    ,[Trip Type]
    ,[Product Plan]
    ,[CFAR Flag]
    ,[Month]
)
)

SELECT
     [Domain Country]
    ,[Product Group]
    ,[Policy Type]
    ,[UW Rating Group]
    ,[JV]
    ,[Outlet Channel]
    ,[Plan Type]
    ,[Trip Type]
    ,[Product Plan]
    ,[CFAR Flag]
    ,[Month]
    ,[Incurred Month]
    ,[Development Month]

    ,SUM([Sections MED])        AS [Sections MED]
    ,SUM([Sections MED_LGE])    AS [Sections MED_LGE]
    ,SUM([Sections CAN])        AS [Sections CAN]
    ,SUM([Sections CAN_LGE])    AS [Sections CAN_LGE]
    ,SUM([Sections ADD])        AS [Sections ADD]
    ,SUM([Sections ADD_LGE])    AS [Sections ADD_LGE]
    ,SUM([Sections LUG])        AS [Sections LUG]
    ,SUM([Sections LUG_LGE])    AS [Sections LUG_LGE]
    ,SUM([Sections MIS])        AS [Sections MIS]
    ,SUM([Sections MIS_LGE])    AS [Sections MIS_LGE]
    ,SUM([Sections UDL])        AS [Sections UDL]
    ,SUM([Sections UDL_LGE])    AS [Sections UDL_LGE]
    ,SUM([Sections CAT])        AS [Sections CAT]
    ,SUM([Sections COV])        AS [Sections COV]
    ,SUM([Sections OTH])        AS [Sections OTH]
    ,SUM([Sections])            AS [Sections]

    ,SUM([Sections Non-Nil MED])        AS [Sections Non-Nil MED]
    ,SUM([Sections Non-Nil MED_LGE])    AS [Sections Non-Nil MED_LGE]
    ,SUM([Sections Non-Nil CAN])        AS [Sections Non-Nil CAN]
    ,SUM([Sections Non-Nil CAN_LGE])    AS [Sections Non-Nil CAN_LGE]
    ,SUM([Sections Non-Nil ADD])        AS [Sections Non-Nil ADD]
    ,SUM([Sections Non-Nil ADD_LGE])    AS [Sections Non-Nil ADD_LGE]
    ,SUM([Sections Non-Nil LUG])        AS [Sections Non-Nil LUG]
    ,SUM([Sections Non-Nil LUG_LGE])    AS [Sections Non-Nil LUG_LGE]
    ,SUM([Sections Non-Nil MIS])        AS [Sections Non-Nil MIS]
    ,SUM([Sections Non-Nil MIS_LGE])    AS [Sections Non-Nil MIS_LGE]
    ,SUM([Sections Non-Nil UDL])        AS [Sections Non-Nil UDL]
    ,SUM([Sections Non-Nil UDL_LGE])    AS [Sections Non-Nil UDL_LGE]
    ,SUM([Sections Non-Nil CAT])        AS [Sections Non-Nil CAT]
    ,SUM([Sections Non-Nil COV])        AS [Sections Non-Nil COV]
    ,SUM([Sections Non-Nil OTH])        AS [Sections Non-Nil OTH]
    ,SUM([Sections Non-Nil])            AS [Sections Non-Nil]

    ,SUM([Payments MED])        AS [Payments MED]
    ,SUM([Payments MED_LGE])    AS [Payments MED_LGE]
    ,SUM([Payments CAN])        AS [Payments CAN]
    ,SUM([Payments CAN_LGE])    AS [Payments CAN_LGE]
    ,SUM([Payments ADD])        AS [Payments ADD]
    ,SUM([Payments ADD_LGE])    AS [Payments ADD_LGE]
    ,SUM([Payments LUG])        AS [Payments LUG]
    ,SUM([Payments LUG_LGE])    AS [Payments LUG_LGE]
    ,SUM([Payments MIS])        AS [Payments MIS]
    ,SUM([Payments MIS_LGE])    AS [Payments MIS_LGE]
    ,SUM([Payments UDL])        AS [Payments UDL]
    ,SUM([Payments UDL_LGE])    AS [Payments UDL_LGE]
    ,SUM([Payments CAT])        AS [Payments CAT]
    ,SUM([Payments COV])        AS [Payments COV]
    ,SUM([Payments OTH])        AS [Payments OTH]
    ,SUM([Payments])            AS [Payments]

    ,SUM([Incurred MED])        AS [Incurred MED]
    ,SUM([Incurred MED_LGE])    AS [Incurred MED_LGE]
    ,SUM([Incurred CAN])        AS [Incurred CAN]
    ,SUM([Incurred CAN_LGE])    AS [Incurred CAN_LGE]
    ,SUM([Incurred ADD])        AS [Incurred ADD]
    ,SUM([Incurred ADD_LGE])    AS [Incurred ADD_LGE]
    ,SUM([Incurred LUG])        AS [Incurred LUG]
    ,SUM([Incurred LUG_LGE])    AS [Incurred LUG_LGE]
    ,SUM([Incurred MIS])        AS [Incurred MIS]
    ,SUM([Incurred MIS_LGE])    AS [Incurred MIS_LGE]
    ,SUM([Incurred UDL])        AS [Incurred UDL]
    ,SUM([Incurred UDL_LGE])    AS [Incurred UDL_LGE]
    ,SUM([Incurred CAT])        AS [Incurred CAT]
    ,SUM([Incurred COV])        AS [Incurred COV]
    ,SUM([Incurred OTH])        AS [Incurred OTH]
    ,SUM([Incurred])            AS [Incurred]

    ,SUM([Policy MED - Active]) AS [Policy MED - Active]
    ,SUM([Policy CAN - Active]) AS [Policy CAN - Active]
    ,SUM([Policy ADD - Active]) AS [Policy ADD - Active]
    ,SUM([Policy LUG - Active]) AS [Policy LUG - Active]
    ,SUM([Policy MIS - Active]) AS [Policy MIS - Active]
    ,SUM([Policy - Active])     AS [Policy - Active]

    ,SUM([UW Premium MED])  AS [UW Premium MED]
    ,SUM([UW Premium CAN])  AS [UW Premium CAN]
    ,SUM([UW Premium ADD])  AS [UW Premium ADD]
    ,SUM([UW Premium LUG])  AS [UW Premium LUG]
    ,SUM([UW Premium MIS])  AS [UW Premium MIS]
    ,SUM([UW Premium UDL])  AS [UW Premium UDL]
    ,SUM([UW Premium CAT])  AS [UW Premium CAT]
    ,SUM([UW Premium COV])  AS [UW Premium COV]
    ,SUM([UW Premium])      AS [UW Premium]

    ,SUM([Premium])         AS [Premium]

    ,SUM([GLM Freq MED])    AS [GLM Freq MED]
    ,SUM([GLM Freq CAN])    AS [GLM Freq CAN]
    ,SUM([GLM Freq ADD])    AS [GLM Freq ADD]
    ,SUM([GLM Freq LUG])    AS [GLM Freq LUG]
    ,SUM([GLM Freq MIS])    AS [GLM Freq MIS]
    ,SUM([GLM Freq UDL])    AS [GLM Freq UDL]
    ,SUM([GLM Freq]    )    AS [GLM Freq]

    ,SUM([GLM CPP MED])     AS [GLM CPP MED]
    ,SUM([GLM CPP LGE])     AS [GLM CPP LGE]
    ,SUM([GLM CPP MED+LGE]) AS [GLM CPP MED+LGE]
    ,SUM([GLM CPP CAN])     AS [GLM CPP CAN]
    ,SUM([GLM CPP ADD])     AS [GLM CPP ADD]
    ,SUM([GLM CPP LUG])     AS [GLM CPP LUG]
    ,SUM([GLM CPP MIS])     AS [GLM CPP MIS]
    ,SUM([GLM CPP UDL])     AS [GLM CPP UDL]
    ,SUM([GLM CPP CAT])     AS [GLM CPP CAT]
    ,SUM([GLM CPP])         AS [GLM CPP]

    --,SUM([GLM UWP MED])     AS [GLM UWP MED]
    --,SUM([GLM UWP LGE])     AS [GLM UWP LGE]
    --,SUM([GLM UWP MED+LGE]) AS [GLM UWP MED+LGE]
    --,SUM([GLM UWP CAN])     AS [GLM UWP CAN]
    --,SUM([GLM UWP ADD])     AS [GLM UWP ADD]
    --,SUM([GLM UWP LUG])     AS [GLM UWP LUG]
    --,SUM([GLM UWP MIS])     AS [GLM UWP MIS]
    --,SUM([GLM UWP UDL])     AS [GLM UWP UDL]
    --,SUM([GLM UWP CAT])     AS [GLM UWP CAT]
    --,SUM([GLM UWP])         AS [GLM UWP]

FROM Claim_Month_Exposure
GROUP BY 
     [Domain Country]
    ,[Product Group]
    ,[Policy Type]
    ,[UW Rating Group]
    ,[JV]
    ,[Outlet Channel]
    ,[Plan Type]
    ,[Trip Type]
    ,[Product Plan]
    ,[CFAR Flag]
    ,[Month]
    ,[Incurred Month]
    ,[Development Month]
;
GO
