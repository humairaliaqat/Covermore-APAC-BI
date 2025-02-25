USE [db-au-actuary]
GO
/****** Object:  View [cng].[vClaim_Day_Count]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vClaim_Day_Count] AS 

/****************************************************************************************************/
--  Name:           vClaim_Day_Count
--  Author:         Calvin Ng
--  Date Created:   2024-03-12
--  Description:    
--
--  Change History: 2024-03-12 Initial code to calculate claim day count
--                  
/****************************************************************************************************/

--DECLARE @Date nvarchar(50);
--SET @Date = '2021-01-01';

WITH 
[Calendar] AS (
    SELECT 
         c.[Date]
        ,c.[isHoliday]
        ,c.[isWeekDay]
    FROM [db-au-cmdwh].[dbo].[Calendar] c
    WHERE c.[Date] > ='2017-01-01'
)

,[WorkStatus_01] AS(
    SELECT
         w.[Country]
        ,w.[ClaimKey]
        ,w.[WorkType]
        ,we.[EventName]
        ,we.[StatusName]
        ,w.[StatusName] as [e5_StatusName]
        ,we.[EventDate]
        ,ROW_NUMBER() OVER (PARTITION BY w.[ClaimKey],CAST(we.[EventDate] as date) ORDER BY we.[EventDate] DESC) AS [EndOfDay]

    FROM      [db-au-cmdwh].[dbo].[e5WorkEvent] we WITH (NOLOCK) 
    LEFT JOIN [db-au-cmdwh].[dbo].[e5Work]      w  WITH (NOLOCK) ON w.[Work_ID]  = we.[Work_ID]
    LEFT JOIN [db-au-cmdwh].[dbo].[clmClaim]    c  WITH (NOLOCK) ON c.[ClaimKey] =  w.[ClaimKey]

    WHERE  w.[WorkType] IN ('Claim','New Claim')
       AND (we.[EventName] = 'Changed Work Status' OR (we.[EventName] = 'Saved Work' AND we.[EventUser] IN ('e5 Launch Service', 'svc-e5-prd-services')))
       AND NOT (we.[EventDate] >= '2015-10-03' AND we.[EventDate] < '2015-10-04' AND we.EventUser in ('Dataract e5 Exchange Service', 'e5 Launch Service')) 
       AND c.[CreateDate] >= '2017-01-01'
      -- AND c.[ClaimKey] IN ('AU-1457154')
    --ORDER BY we.[EventDate]
    )

,[WorkStatus_02] AS (
    SELECT 
         *
        ,ROW_NUMBER() OVER (PARTITION BY [ClaimKey] ORDER BY [EventDate] ASC ) AS [First]
        ,ROW_NUMBER() OVER (PARTITION BY [ClaimKey] ORDER BY [EventDate] DESC) AS [Last]
    FROM [WorkStatus_01]
    WHERE [EndOfDay] = 1
    )

,[WorkStatus_03] AS (
    SELECT
         a.*
        ,CASE WHEN a.[StatusName] IN ('Active','Diarised') AND a.[Last] = 1 THEN GETDATE()
              WHEN a.[StatusName] IN ('Complete','Rejected')                THEN NULL
                                                                            ELSE b.[EventDate]
         END AS [NextEventDate]
    FROM      [WorkStatus_02] a 
    LEFT JOIN [WorkStatus_02] b ON a.[ClaimKey] = b.[ClaimKey] AND a.[First] = b.[First]-1
    )

,[WorkStatus_05] AS (
    SELECT 
         *
        ,cal.[Date] AS [Day]
        ,SUM(1) OVER (PARTITION BY [ClaimKey],[EventDate] ORDER BY cal.[Date]) AS [DayCount]
        ,ROW_NUMBER() OVER (PARTITION BY [ClaimKey] ORDER BY cal.[Date] DESC) AS [Rank]
        ,1 AS [Count]
    FROM [WorkStatus_03] a
    OUTER APPLY (SELECT * 
                 FROM [Calendar] cal 
                 WHERE CAST(cal.[Date] as date) >= CAST(a.[EventDate] as date) 
                   AND CAST(cal.[Date] as date) <  COALESCE(CAST(a.[NextEventDate] as date),CAST(DATEADD(day,1,a.[EventDate]) as date)) --NextEventDate is NULL for Complete, so add 1 day to EventDate.
                ) cal
    WHERE cal.[isWeekDay] = 1 AND cal.[isHoliday] <> 1
)

SELECT 
     [Country]
    ,[ClaimKey]
    ,[WorkType]
    ,[EventDate]
    ,[NextEventDate]
    ,CAST([Day] as date) AS [Date]
    ,[StatusName]
    ,[e5_StatusName]
    ,[DayCount]
    ,[Rank]
    ,SUM([Count]) AS [Count]
FROM [WorkStatus_05]
--Where ClaimKey = 'AU-1406937'
GROUP BY 
     [Country]
    ,[ClaimKey]
    ,[WorkType]
    ,[EventDate]
    ,[NextEventDate]
    ,[Day]
    ,[StatusName]
    ,[e5_StatusName]
    ,[DayCount]
    ,[Rank]
--ORDER BY
--     [Country]
--    ,[ClaimKey]
--    ,[WorkType]
--    ,[EventDate]
--    ,[Day]
--    ,[StatusName]
--    ,[e5_StatusName]
--    ,[DayCount]
--;
GO
