USE [db-au-actuary]
GO
/****** Object:  View [cng].[vPolicy_Month_Summary_Issue]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [cng].[vPolicy_Month_Summary_Issue] AS 

/****************************************************************************************************/
--  Name:           vPolicy_Month_Summary_Issue
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  
/****************************************************************************************************/

SELECT 
     'Issue' AS [Date Type]
    ,[Domain Country]
    ,[Policy Status]
    ,[Policy Status Detailed]
    ,[UW Policy Status]
    ,[UW Rating Group]
    ,[JV Description]
    ,[Outlet Channel]
    ,[Product Code]
    ,[Plan Code]
    ,[Product Plan]
    ,[Product Group]
    ,[Policy Type]
    ,[Plan Type]
    ,[Trip Type]
    ,[CFAR Flag]
    ,CAST(EOMONTH([Issue Date]) as datetime) AS [Month]
    ,YEAR([Issue Date])                      AS [Year]

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

    ,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium MED % Total])                              AS [UW Premium MED]
    ,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',2,1)) AS [UW Premium CAN]
    ,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium ADD % Total])                              AS [UW Premium ADD]
    ,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium LUG % Total])                              AS [UW Premium LUG]
    ,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium MIS % Total])                              AS [UW Premium MIS]
    ,SUM([UW Premium]           * 1.00/1.04 * [Earned Premium %]) +
     SUM([UW Premium]           * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [UW Premium UDL]
    ,SUM([UW Premium]           * 0.04/1.04 * [Earned Premium %]) +
     SUM([UW Premium]           * 0.04/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [UW Premium CAT]
    ,SUM([UW Premium COVID19]   * 1.00      * [Earned Premium %])                                        AS [UW Premium COV]
    ,SUM([UW Premium]           * 1.00      * [Earned Premium %]) + 
     SUM([UW Premium COVID19]   * 1.00      * [Earned Premium %]) + 
     SUM([UW Premium]           * 1.00      * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [UW Premium]

    ,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium MED % Total])                              AS [Target Cost MED]
    ,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',2,1)) AS [Target Cost CAN]
    ,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium ADD % Total])                              AS [Target Cost ADD]
    ,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium LUG % Total])                              AS [Target Cost LUG]
    ,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium MIS % Total])                              AS [Target Cost MIS]
    ,SUM([Target Cost]          * 1.00/1.04 * [Earned Premium %]) + 
     SUM([Target Cost]          * 1.00/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [Target Cost UDL]
    ,SUM([Target Cost]          * 0.04/1.04 * [Earned Premium %]) +
     SUM([Target Cost]          * 0.04/1.04 * [Earned Premium CAN % Total] * IIF([CFAR Flag]='Yes',1,0)) AS [Target Cost CAT]
    ,SUM([Target Cost COVID19]  * 1.00      * [Earned Premium %])                                        AS [Target Cost COV]
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

FROM [db-au-actuary].[cng].[vPolicy_Month_Issue]
GROUP BY 
     [Domain Country]
    ,[Policy Status]
    ,[Policy Status Detailed]
    ,[UW Policy Status]
    ,[UW Rating Group]
    ,[JV Description]
    ,[Outlet Channel]
    ,[Product Code]
    ,[Plan Code]
    ,[Product Plan]
    ,[Product Group]
    ,[Policy Type]
    ,[Plan Type]
    ,[Trip Type]
    ,[CFAR Flag]
    ,CAST(EOMONTH([Issue Date]) as datetime)
    ,YEAR([Issue Date])
--ORDER BY 
--     [Domain Country]
--    ,[Policy Status]
--    ,[Policy Status Detailed]
--    ,COALESCE([UW Policy Status],'Not in UW Returns')
--    ,[UW Rating Group]
--    ,[JV Description] AS [JV]
--    ,[Outlet Channel]
--    ,[Product Code]
--    ,[Plan Code]
--    ,[Product Plan]
--    ,[Product Group]
--    ,[Policy Type]
--    ,[Plan Type]
--    ,[Trip Type]
--    ,[CFAR Flag]
--    ,CAST(EOMONTH([Issue Date]) as datetime)
--    ,YEAR([Issue Date])
;
GO
