USE [db-au-actuary]
GO
/****** Object:  View [dbo].[Claims_Dashboard_CM]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Claims_Dashboard_CM] AS 

WITH
--Fix received date
Claims AS (
    SELECT
         [CountryKey]
        ,[PolicyKey]
        ,[ClaimKey]
        ,[CreateDate]
        ,CASE
            WHEN [ReceivedDate] IS NULL                                     THEN [CreateDate]
            WHEN [ReceivedDate] > DATEADD(DAY,1,CONVERT(DATE,[CreateDate])) THEN [CreateDate]
            ELSE [ReceivedDate]
         END AS [ReceivedDate]
        ,[FinalisedDate]
        ,[OfficerName]

    FROM [uldwh02].[db-au-cmdwh].[dbo].[clmClaim]

    WHERE
        [CountryKey] = 'AU' AND
        (CASE
            WHEN [ReceivedDate] IS NULL                                     THEN [CreateDate]
            WHEN [ReceivedDate] > DATEADD(DAY,1,CONVERT(DATE,[CreateDate])) THEN [CreateDate]
            ELSE [ReceivedDate]
         END) >= '2016-01-01'
)

--Assessments 
,Assessments AS (
    SELECT 
         w.[Country]                        AS [CountryKey]
        ,w.[Country]+'-'+[PolicyNumber]     AS [PolicyKey]
        ,w.[ClaimKey]                       AS [ClaimKey]
        ,wa.[CompletionUser]                AS [OfficerName]
        ,wa.[CompletionDate]                AS [Date]
        ,'Assessment'                       AS [Action]
        ,ISNULL(we.[StatusName],'Active')   AS [Status]
        ,wa.[AssessmentOutcomeDescription]  AS [Assessment]
        ,1                                  AS [Assessment Count]

    FROM       [uldwh02].[db-au-cmdwh].[dbo].[e5WorkActivity]   wa
    INNER JOIN [uldwh02].[db-au-cmdwh].[dbo].[e5Work]           w   ON wa.[Work_ID] = w.[Work_ID]
    INNER JOIN Claims                                           cl  ON w.[ClaimKey] = cl.[ClaimKey]
    OUTER APPLY (
        SELECT TOP 1 we.[StatusName] AS [StatusName]
        FROM [uldwh02].[db-au-cmdwh].[dbo].[e5WorkEvent] we
        WHERE
                we.[Work_Id]    = w.[Work_ID]
            AND we.[EventDate] >= wa.[CompletionDate]
            AND we.[EventName]  = 'Changed Work Status'
        ORDER BY
            we.[EventDate]
        ) we

    WHERE
             w.[Country] = 'AU'
        AND  w.[ClaimKey] IS NOT NULL
        AND wa.[CompletionDate] IS NOT NULL
        AND wa.[CategoryActivityName] = 'Assessment Outcome'
)

--Received date
,Received AS (
    SELECT
         [CountryKey]       AS [CountryKey]
        ,[PolicyKey]        AS [PolicyKey]
        ,[ClaimKey]         AS [ClaimKey]
        ,NULL               AS [OfficerName]
        ,[ReceivedDate]     AS [Date]
        ,'Received'         AS [Action]
        ,NULL               AS [Status]
        ,NULL               AS [Assessment]
        ,NULL               AS [Assessment Count]
    FROM Claims
)

--Created date
,Created AS (
    SELECT
         [CountryKey]       AS [CountryKey]
        ,[PolicyKey]        AS [PolicyKey]
        ,[ClaimKey]         AS [ClaimKey]
        ,NULL               AS [OfficerName]
        ,[CreateDate]       AS [Date]
        ,'Created'          AS [Action]
        ,NULL               AS [Status]
        ,NULL               AS [Assessment]
        ,NULL               AS [Assessment Count]
    FROM Claims
)

--Finalised date
,Finalised_01 AS (
    SELECT
         [CountryKey]       AS [CountryKey]
        ,[PolicyKey]        AS [PolicyKey]
        ,a.[ClaimKey]       AS [ClaimKey]
        ,NULL               AS [OfficerName]
        ,[FinalisedDate]    AS [Date]
        ,'Finalised'        AS [Action]
        ,NULL               AS [Status]
        ,NULL               AS [Assessment]
        ,[Assessment Count] AS [Assessment Count]
    FROM Claims a
    LEFT JOIN (SELECT [ClaimKey],COUNT(*) AS [Assessment Count] FROM Assessments GROUP BY [ClaimKey]) b ON a.[ClaimKey] = b.[ClaimKey]
    WHERE [FinalisedDate] IS NOT NULL
)

--Finalise claim if finalised date is null, assessment status is complete and older than 7 days
,Finalised_02 AS (
    SELECT
         a.[CountryKey]             AS [CountryKey]
        ,a.[PolicyKey]              AS [PolicyKey]
        ,a.[ClaimKey]               AS [ClaimKey]
        ,NULL                       AS [OfficerName]
        ,DATEADD(day,7,a.[Date])    AS [Date]
        ,'Completed'                AS [Action]
        ,NULL                       AS [Status]
        ,NULL                       AS [Assessment]
        ,b.[Assessment Count] AS [Assessment Count]
    FROM (SELECT *, ROW_NUMBER() over (PARTITION by [ClaimKey] ORDER BY [Date] DESC) AS [Latest] FROM Assessments)  a                                   --Get last assessment
    LEFT JOIN (SELECT [ClaimKey],COUNT(*) AS [Assessment Count] FROM Assessments GROUP BY [ClaimKey])               b ON a.[ClaimKey] = b.[ClaimKey]    --Count assessments
    LEFT JOIN Finalised_01                                                                                          c ON a.[ClaimKey] = c.[ClaimKey]    --Get finalised date
    WHERE 
        c.[Date] IS NULL        AND         --Not finalised
        a.[Latest] = 1          AND 
        a.[Status] = 'Complete' AND         --Last assessment status is complete
        DATEADD(day,7,a.[Date]) < GETDATE() --Last assessment is older than 7 days
)

--Finalise claim if finalised date is null, assessment status is not complete and older than 30 days
,Finalised_03 AS (
    SELECT
         a.[CountryKey]             AS [CountryKey]
        ,a.[PolicyKey]              AS [PolicyKey]
        ,a.[ClaimKey]               AS [ClaimKey]
        ,NULL                       AS [OfficerName]
        ,DATEADD(day,60,a.[Date])   AS [Date]
        ,'Inactive'                 AS [Action]
        ,NULL                       AS [Status]
        ,NULL                       AS [Assessment]
        ,b.[Assessment Count] AS [Assessment Count]
    FROM (SELECT *, ROW_NUMBER() over (PARTITION by [ClaimKey] ORDER BY [Date] DESC) AS [Latest] FROM Assessments)  a                                   --Get last assessment
    LEFT JOIN (SELECT [ClaimKey],COUNT(*) AS [Assessment Count] FROM Assessments GROUP BY [ClaimKey])               b ON a.[ClaimKey] = b.[ClaimKey]    --Count assessments
    LEFT JOIN Finalised_01                                                                                          c ON a.[ClaimKey] = c.[ClaimKey]    --Get finalised date
    WHERE 
        c.[Date] IS NULL         AND            --Not finalised
        a.[Latest] = 1           AND 
        a.[Status] <> 'Complete' AND            --Last assessment status is complete
        DATEADD(day,60,a.[Date]) < GETDATE()    --Last assessment is older than 30 days
)

--Combined tables
,Combined_01 AS (
    SELECT * FROM Received
    UNION ALL
    SELECT * FROM Created
    UNION ALL
    SELECT * FROM Finalised_01
    UNION ALL
    SELECT * FROM Finalised_02
    UNION ALL
    SELECT * FROM Finalised_03
    UNION ALL
    SELECT * FROM Assessments
)

--Day Count from received date
,Combined AS (
    SELECT 
         a.*
        ,DATEDIFF(day, b.[Date], a.[Date]) AS [Day Count]
    FROM Combined_01 a
    JOIN Received    b ON a.[ClaimKey] = b.[ClaimKey]
)

--Summarise
,Summary AS (
    SELECT
         [CountryKey]
        --,EOMONTH([Date])                                                            AS [Month]
        ,DATEADD(DAY,-DATEPART(WEEKDAY,CAST([Date] as date))+1,CAST([Date] as date))    AS [Month]
        ,SUM(IIF([Action]='Received'    ,1.00,0.00))                                    AS [Received Claim Count]
        ,SUM(IIF([Action]='Created'     ,1.00,0.00))                                    AS [Created Claim Count]
        ,SUM(IIF([Action]='Assessment'  ,1.00,0.00))                                    AS [Assessments Count]
        ,SUM(IIF([Action]='Finalised'   ,1.00,0.00))                                    AS [ClaimsNet Finalised Count]
        ,SUM(IIF([Action]='Completed'   ,1.00,0.00))                                    AS [e5 Completed Count]
        ,SUM(IIF([Action]='Inactive'    ,1.00,0.00))                                    AS [e5 Inactive Count]
        ,SUM(IIF([Action] IN ('Finalised','Completed','Inactive'),1.00,0.00))                               AS [Finalised Claim Count]
        ,AVG(IIF([Action] IN ('Finalised','Completed','Inactive'),CAST([Assessment Count] as float),null))  AS [Assessments Per Claim]
        ,AVG(IIF([Action] IN ('Finalised','Completed','Inactive'),CAST([Day Count]        as float),null))  AS [Days To Finalised]
        ,COUNT(DISTINCT [OfficerName])                                                  AS [Claim Officers]
        ,COUNT(DISTINCT [OfficerName]+CAST(CAST([Date] as date) as nchar))              AS [Claim Officer Days]
        ,SUM(IIF([Action]='Assessment'  ,1.00,0.00))/
         NULLIF(COUNT(DISTINCT [OfficerName]+CAST(CAST([Date] as date) as nchar)),0)   AS [Assessment Per Claim Officer Day] -- [Assessments Count]/[Claim Officers Days]
    FROM Combined
    WHERE CAST([Date] as date) >= '2016-01-02'
    GROUP BY
         [CountryKey]
        ,DATEADD(DAY,-DATEPART(WEEKDAY,CAST([Date] as date))+1,CAST([Date] as date))
)

SELECT 
     *
    ,SUM([Received Claim Count]) OVER (ORDER BY [Month]) - SUM([Finalised Claim Count]) OVER (ORDER BY [Month]) AS [Outstanding Claims]
FROM Summary

;

--SELECT *
--FROM Combined
--ORDER BY
--     [CountryKey]
--    ,[ClaimKey]
--    ,[Date]
--;

GO
