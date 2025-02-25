USE [db-au-actuary]
GO
/****** Object:  View [cng].[vPolicy_Header_Check]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vPolicy_Header_Check] AS 

/****************************************************************************************************/
--  Name:           vPolicy_Header_Check
--  Author:         Calvin Ng
--  Date Created:   2024-06-01
--  Description:    
--
--  Change History: 2024-06-01 Initial code to run on uldwh02 instead of bhdwh02
--                  
/****************************************************************************************************/

WITH 
dwhdataset_old AS (SELECT * FROM [db-au-actuary].[cng].[Policy_Header_Old]),
dwhdataset_new AS (SELECT * FROM [db-au-actuary].[cng].[Policy_Header]),
Summary AS (
    SELECT 
        'Domain Country' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Domain Country] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Domain Country]) AS new
    FULL JOIN (SELECT [Domain Country] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Domain Country]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Company' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Company] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Company]) AS new
    FULL JOIN (SELECT [Company] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Company]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Issue Date' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT FORMAT(CAST([Issue Date] AS date),'yyyy-MM-dd') AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY CAST([Issue Date] AS date)) AS new
    FULL JOIN (SELECT FORMAT(CAST([Issue Date] AS date),'yyyy-MM-dd') AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY CAST([Issue Date] AS date)) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Destination' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Destination] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Destination]) AS new
    FULL JOIN (SELECT [Destination] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Destination]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Product Code' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Product Code] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Product Code]) AS new
    FULL JOIN (SELECT [Product Code] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Product Code]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Product Group' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Product Group] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Product Group]) AS new
    FULL JOIN (SELECT [Product Group] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Product Group]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Policy Type' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Policy Type] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Policy Type]) AS new
    FULL JOIN (SELECT [Policy Type] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Policy Type]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Plan Type' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Plan Type] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Plan Type]) AS new
    FULL JOIN (SELECT [Plan Type] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Plan Type]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Trip Type' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Trip Type] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Trip Type]) AS new
    FULL JOIN (SELECT [Trip Type] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Trip Type]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
UNION ALL
    SELECT 
        'Product Classification' AS [Column]
        ,COALESCE(new.[Value],old.[Value]) AS [Value]
        ,COALESCE([New],0) AS [New]
        ,COALESCE([Old],0) AS [Old]
        , COALESCE([New],0)-COALESCE([Old],0) AS [Diff]
        ,(COALESCE([New],0)-COALESCE([Old],0))*1.00/COALESCE([New],0.01) AS [Diff%]
    FROM      (SELECT [Product Classification] AS [Value],COUNT(*) AS [New] FROM dwhdataset_new GROUP BY [Product Classification]) AS new
    FULL JOIN (SELECT [Product Classification] AS [Value],COUNT(*) AS [Old] FROM dwhdataset_old GROUP BY [Product Classification]) AS old ON COALESCE(new.[Value],'--') = COALESCE(old.[Value],'--')
)

SELECT TOP 1000000 *
FROM Summary
WHERE [Diff%]>0.1 OR [Diff%]<0 OR [Value] IS NULL OR [Value] = '' OR [Value] = 'NULL'
ORDER BY [Column],[Value]
;
GO
