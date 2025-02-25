USE [db-au-actuary]
GO
/****** Object:  View [dbo].[Claims_Monitoring]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









   
  
CREATE VIEW [dbo].[Claims_Monitoring] AS      

WITH 
[Policies] AS (
    SELECT 
        --Dimensions
         pol.[Domain Country]
        ,EOMONTH(pol.[Return Date]) AS [Return Month]
		,EOMONTH(pol.[Departure Date]) AS [Departure Month] 
        ,CASE WHEN pol.[Domain Country] = 'AU' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
              WHEN pol.[Domain Country] = 'NZ' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
              ELSE pol.[Plan Type]
         END AS [Plan Type]
                             , CASE WHEN pol.[Traveller Count]=1 THEN '1' 
                              WHEN pol.[Traveller Count]= 2 THEN '2' 
                              ELSE '3+'
                             END AS [Traveller Count]
                             ,CASE WHEN pol.[Max EMC Score] =  0 then 'No EMC'
                             WHEN pol.[Max EMC Score] < 1.4 then '<1.4'
                             ELSE '1.4+'
                             END as [Max EMC Score]
        ,pol.[Area Name]
        ,pol.[Product Name]
        ,pol.[Latest JV Description]
        ,b.[GLM_Region_20242_Banded]
		,CASE
        WHEN pol.[Trip Duration] > 0 AND pol.[Trip Duration] <=  14 THEN '<2 Weeks'
        WHEN pol.[Trip Duration] >  14								THEN '>2 Weeks'
	    ELSE NULL 
		END AS [Trip Duration]
                             --,pol.PolicyKey
                             , Case    
                             When pt.Age between 0 and 16 then 'Age Group 0 - 16'    
                             When pt.Age between 17 and 24 then 'Age Group 17 - 24'    
                             When pt.Age between 25 and 34 then 'Age Group 25 - 34'    
                             When pt.Age between 35 and 49 then 'Age Group 35 - 49'    
                             When pt.Age between 50 and 59 then 'Age Group 50 - 59'    
                             When pt.Age between 60 and 64 then 'Age Group 60 - 64'    
                             When pt.Age between 65 and 69 then 'Age Group 65 - 69'    
                             When pt.Age between 70 and 74 then 'Age Group 70 - 74'    
                             When pt.Age >= 75 then 'Age Group 75+'    
                             End [AgeGroup]
        --Measures
        ,SUM(pol.[Policy Count])    AS [Policy Count]
        ,SUM(pol.[Premium])         AS [Premium]
        ,SUM(pol.[UW Premium])      AS [UW Premium]
        ,0                          AS [Claims]
        ,0                          AS [Sections]
        ,0                          AS [Payments]
        ,0                          AS [Incurred]

        ,SUM(glm.[add_and_on_trip_can_freq_u]) as [add_and_on_trip_can_freq_u]
        ,SUM(glm.[add_and_on_trip_can_pred_u]) as [add_and_on_trip_can_pred_u]
        ,SUM(glm.[add_and_on_trip_can_sev_u])  as [add_and_on_trip_can_sev_u]
        ,SUM(glm.[can_freq_u])                                                           as [can_freq_u]
        ,SUM(glm.[can_pred_u])                                                          as [can_pred_u]
        ,SUM(glm.[can_sev_u])                                                            as [can_sev_u]
        ,SUM(glm.[lug_freq_u])                                                             as [lug_freq_u]
        ,SUM(glm.[lug_pred_u])                                                            as [lug_pred_u]
        ,SUM(glm.[lug_sev_u])                                               as [lug_sev_u]
        ,SUM(glm.[med_freq_u])                                                          as [med_freq_u]
        ,SUM(glm.[med_pred_u])                                                         as [med_pred_u]
        ,SUM(glm.[med_sev_u])                                                           as [med_sev_u]
        ,SUM(glm.[oth_freq_u])                                                            as [oth_freq_u]
        ,SUM(glm.[oth_pred_u])                                                           as [oth_pred_u]
        ,SUM(glm.[oth_sev_u])                                               as [oth_sev_u]
        ,SUM(glm.[Pred_l])                                                                     as [Pred_l]
		,SUM(pol.[Lead Time])		AS [Lead Time]
    FROM [uldwh02].[db-au-actuary].[cng].[Policy_Header] pol WITH(NOLOCK)
     LEFT JOIN  [bhdwh02].[db-au-actuary].[cng].[UW_Destinations] b WITH(NOLOCK) ON pol.Destination = b.Destination 
              LEFT JOIN [bhdwh02].[db-au-actuary].[cz].[BookingEstimate20230101_20240831actualUWP] glm WITH(NOLOCK) ON glm.PolicyKey = pol.PolicyKey 
              outer apply    
(    
 select    
  pt.Age    
 From    
  [uldwh02].[db-au-cmdwh].[dbo].penPolicyTraveller pt    WITH(NOLOCK)
 Where    
  pt.PolicyKey = pol.PolicyKey    
  and pt.IsPrimary = 1    
) pt
    WHERE CAST(pol.[Return Date] as date) >= '2023-01-01' AND pol.[Product Code] <> 'CMC' AND pol.[JV Description] NOT IN ('CBA NAC','BW NAC')
            --  and pol.PolicyKey = 'AU-TIP7-2673500'
    GROUP BY 
         pol.[Domain Country]
        ,EOMONTH(pol.[Return Date])
		,EOMONTH(pol.[Departure Date])
        ,CASE WHEN pol.[Domain Country] = 'AU' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
              WHEN pol.[Domain Country] = 'NZ' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
              ELSE pol.[Plan Type]
         END
                   ,pol.[Area Name]
        ,b.[GLM_Region_20242_Banded] 
                             ,pol.[Product Name]
                             ,pol.[Latest JV Description]

		,CASE
        WHEN pol.[Trip Duration] > 0 AND pol.[Trip Duration] <=  14 THEN '<2 Weeks'
        WHEN pol.[Trip Duration] >  14								THEN '>2 Weeks'
	    ELSE NULL 
		END 
                             --,pol.PolicyKey
                             , Case    
                             When pt.Age between 0 and 16 then 'Age Group 0 - 16'    
                             When pt.Age between 17 and 24 then 'Age Group 17 - 24'    
                             When pt.Age between 25 and 34 then 'Age Group 25 - 34'    
                             When pt.Age between 35 and 49 then 'Age Group 35 - 49'    
                             When pt.Age between 50 and 59 then 'Age Group 50 - 59'    
                             When pt.Age between 60 and 64 then 'Age Group 60 - 64'    
                             When pt.Age between 65 and 69 then 'Age Group 65 - 69'    
                             When pt.Age between 70 and 74 then 'Age Group 70 - 74'    
                             When pt.Age >= 75 then 'Age Group 75+'    
                             End
                             ,  CASE WHEN pol.[Traveller Count]=1 THEN '1' 
                              WHEN pol.[Traveller Count]= 2 THEN '2' 
                              ELSE '3+'
                             END 
                             ,CASE WHEN [Max EMC Score] =  0 then 'No EMC'
                             WHEN [Max EMC Score] < 1.4 then '<1.4'
                             ELSE '1.4+'
                             END
),

[Claims] AS (
    SELECT 
        --Dimensions
         pol.[Domain Country] AS [Domain Country]
        ,EOMONTH(pol.[Return Date]) AS [Return Month]
		,EOMONTH(pol.[Departure Date]) AS [Departure Month] 
        ,CASE WHEN pol.[Domain Country] = 'AU' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
              WHEN pol.[Domain Country] = 'NZ' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
              ELSE pol.[Plan Type]
         END AS [Plan Type]
                                                          , CASE WHEN pol.[Traveller Count]=1 THEN '1' 
                              WHEN pol.[Traveller Count]= 2 THEN '2' 
                              ELSE '3+'
                             END AS [Traveller Count]
                             ,CASE WHEN pol.[Max EMC Score] =  0 then 'No EMC'
                             WHEN pol.[Max EMC Score] < 1.4 then '<1.4'
                             ELSE '1.4+'
                             END as [Max EMC Score]

        ,pol.[Area Name]
        --,pol.[Destination]
		 ,pol.[Product Name]
        ,pol.[Latest JV Description]
        ,b.[GLM_Region_20242_Banded]

			,CASE
        WHEN pol.[Trip Duration] > 0 AND pol.[Trip Duration] <=  14 THEN '<2 Weeks'
        WHEN pol.[Trip Duration] >  14								THEN '>2 Weeks'
	    ELSE NULL 
		END AS [Trip Duration]
		                                                          , Case    
                             When pt.Age between 0 and 16 then 'Age Group 0 - 16'    
                             When pt.Age between 17 and 24 then 'Age Group 17 - 24'    
                             When pt.Age between 25 and 34 then 'Age Group 25 - 34'    
                             When pt.Age between 35 and 49 then 'Age Group 35 - 49'    
                             When pt.Age between 50 and 59 then 'Age Group 50 - 59'    
                             When pt.Age between 60 and 64 then 'Age Group 60 - 64'    
                             When pt.Age between 65 and 69 then 'Age Group 65 - 69'    
                             When pt.Age between 70 and 74 then 'Age Group 70 - 74'    
                             When pt.Age >= 75 then 'Age Group 75+'    
                             End [AgeGroup]
       
        --Measures
        ,0                                              AS [Policy Count]
        ,0                                              AS [Premium]
        ,0                                              AS [UW Premium]
        ,SUM(clm.[ClaimCount])                          AS [Claims]
        ,SUM(clm.[SectionCount])                        AS [Sections]
        ,SUM(clm.[NetPaymentMovementIncRecoveries])     AS [Payments]
        ,SUM(clm.[NetIncurredMovementIncRecoveries])    AS [Incurred]
                             ,0  as [add_and_on_trip_can_freq_u]
                             ,0 as [add_and_on_trip_can_pred_u]
                             ,0  as [add_and_on_trip_can_sev_u]
                             ,0                                                         as [can_freq_u]
                             ,0                                           as [can_pred_u]
                             ,0                                                         as [can_sev_u]
                             ,0                                                         as [lug_freq_u]
                             ,0                                                         as [lug_pred_u]
                             ,0                                                         as [lug_sev_u]
                             ,0                                           as [med_freq_u]
                             ,0                                                         as [med_pred_u]
                             ,0                                                         as [med_sev_u]
                             ,0                                                         as [oth_freq_u]
                             ,0                                                         as [oth_pred_u]
                             ,0                                                         as [oth_sev_u]
                             ,0                                                                       as [Pred_l]
							 ,SUM(pol.[Lead Time])		AS [Lead Time]
    FROM      [uldwh02].[db-au-actuary].[cng].[Claim_Transactions]  clm WITH(NOLOCK)
    LEFT JOIN [uldwh02].[db-au-actuary].[cng].[Policy_Header]      pol WITH(NOLOCK) ON clm.[PolicyKey] = pol.[PolicyKey] AND clm.[ProductCode] = pol.[Product Code]
    LEFT JOIN  [bhdwh02].[db-au-actuary].[cng].[UW_Destinations] b WITH(NOLOCK) ON pol.Destination = b.Destination 
                             outer apply    
(    
 select    
  pt.Age    
 From    
  [uldwh02].[db-au-cmdwh].[dbo].penPolicyTraveller pt   WITH(NOLOCK) 
 Where    
  pt.PolicyKey = pol.PolicyKey    
  and pt.IsPrimary = 1    
) pt
    WHERE CAST(pol.[Return Date] as date) >= '2023-01-01' AND clm.[ProductCode] <> 'CMC' AND pol.[JV Description] NOT IN ('CBA NAC','BW NAC') AND pol.[PolicyKey] IS NOT NULL
            --  and pol.PolicyKey = 'AU-TIP7-2673500'
    GROUP BY 
         pol.[Domain Country]
        ,EOMONTH(pol.[Return Date])
		,EOMONTH(pol.[Departure Date])
        ,CASE WHEN pol.[Domain Country] = 'AU' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'New Zealand' THEN 'Intl Trans-Tasman'
              WHEN pol.[Domain Country] = 'NZ' AND pol.[Plan Type] = 'International' AND pol.[Country or Area] = 'Australia'   THEN 'Intl Trans-Tasman'
              ELSE pol.[Plan Type]
         END
                                                          , CASE WHEN pol.[Traveller Count]=1 THEN '1' 
                              WHEN pol.[Traveller Count]= 2 THEN '2' 
                              ELSE '3+'
                             END 
                             ,CASE WHEN pol.[Max EMC Score] =  0 then 'No EMC'
                             WHEN pol.[Max EMC Score] < 1.4 then '<1.4'
                             ELSE '1.4+'
                             END 
        ,pol.[Area Name]
        --,pol.[Destination]
		,CASE
        WHEN pol.[Trip Duration] > 0 AND pol.[Trip Duration] <=  14 THEN '<2 Weeks'
        WHEN pol.[Trip Duration] >  14								THEN '>2 Weeks'
	    ELSE NULL 
		END 
                             ,pol.[Product Name]
                             ,pol.[Latest JV Description]
                             ,b.[GLM_Region_20242_Banded]
                                                          , Case    
                             When pt.Age between 0 and 16 then 'Age Group 0 - 16'    
                             When pt.Age between 17 and 24 then 'Age Group 17 - 24'    
                             When pt.Age between 25 and 34 then 'Age Group 25 - 34'    
                             When pt.Age between 35 and 49 then 'Age Group 35 - 49'    
                             When pt.Age between 50 and 59 then 'Age Group 50 - 59'    
                             When pt.Age between 60 and 64 then 'Age Group 60 - 64'    
                             When pt.Age between 65 and 69 then 'Age Group 65 - 69'    
                             When pt.Age between 70 and 74 then 'Age Group 70 - 74'    
                             When pt.Age >= 75 then 'Age Group 75+'    
                             End 
),

[Combined] AS (
    SELECT * FROM [Policies]
    UNION ALL
    SELECT * FROM [Claims]
)

--Re-summarise
SELECT
    --Dimensions
     [Domain Country]
    ,[Return Month]
	,[Departure Month]
    ,[Plan Type]
    --,[Area Name]
              ,[Traveller Count]
              ,[Max EMC Score]
              ,[AgeGroup]
              ,[Product Name]
              ,[Latest JV Description]
    ,[GLM_Region_20242_Banded]

	,[Trip Duration]
    --Measures

    ,SUM([Policy Count]) AS [Policy Count]
    ,SUM([Premium])      AS [Premium]
    ,SUM([UW Premium])   AS [UW Premium]
    ,SUM([Claims])       AS [Claims]
    ,SUM([Sections])     AS [Sections]
    ,SUM([Payments])     AS [Payments]
    ,SUM([Incurred])     AS [Incurred]
	,SUM([Lead Time]) AS [Lead Time] 
	,SUM([add_and_on_trip_can_freq_u])	 AS [add_and_on_trip_can_freq_u]
    ,SUM([add_and_on_trip_can_pred_u])	AS [add_and_on_trip_can_pred_u]
    ,SUM([add_and_on_trip_can_sev_u])	 AS [add_and_on_trip_can_sev_u]
    ,SUM([can_freq_u]) AS [can_freq_u]
    ,SUM([can_pred_u]) AS [can_pred_u]
    ,SUM([can_sev_u]) AS [can_sev_u]
    ,SUM([lug_freq_u]) AS [lug_freq_u]
    ,SUM([lug_pred_u]) AS [lug_pred_u]
    ,SUM([lug_sev_u]) AS [lug_sev_u]
    ,SUM([med_freq_u]) AS [med_freq_u]
    ,SUM([med_pred_u]) AS [med_pred_u]
    ,SUM([med_sev_u]) AS [med_sev_u]
    ,SUM([oth_freq_u]) AS [oth_freq_u]
    ,SUM([oth_pred_u]) AS [oth_pred_u]
    ,SUM([oth_sev_u]) AS [oth_sev_u]
     ,SUM([Pred_l]) AS [Pred_l]
FROM [Combined]
GROUP BY 
     [Domain Country]
    ,[Return Month]
	,[Departure Month]
    ,[Plan Type]
    --,[Area Name]
              ,[Traveller Count]
              ,[Max EMC Score]
              ,[AgeGroup]
              ,[Product Name]
              ,[Latest JV Description]
    ,[GLM_Region_20242_Banded]

	,[Trip Duration]



  
GO
