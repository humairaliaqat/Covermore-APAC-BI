USE [db-au-actuary]
GO
/****** Object:  View [cng].[vTable_Last_Date]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [cng].[vTable_Last_Date] AS
          SELECT 'out_ClaimDataSet'       AS [Table], MAX([IncurredTime]) AS [Last Posting Date], NULL              AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [uldwh02].[db-au-actuary].[dataout].[out_ClaimDataSet]    WITH(NOLOCK)
UNION ALL SELECT 'out_ClaimDataSetCBA'    AS [Table], MAX([IncurredTime]) AS [Last Posting Date], NULL              AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [azsyddwh02].[db-au-actuary].[dataout].[out_ClaimDataSet] WITH(NOLOCK)
UNION ALL SELECT 'DWHDataSet'             AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [uldwh02].[db-au-actuary].[ws].[DWHDataSet]               WITH(NOLOCK) WHERE [Product Code] <> 'CMC' AND EOMONTH([Issue Date])<=EOMONTH(GETDATE())
UNION ALL SELECT 'DWHDataSetSummary'      AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [uldwh02].[db-au-actuary].[ws].[DWHDataSetSummary]        WITH(NOLOCK) WHERE [Product Code] <> 'CMC' AND EOMONTH([Issue Date])<=EOMONTH(GETDATE())
UNION ALL SELECT 'DWHDataSetCBA'          AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [azsyddwh02].[db-au-actuary].[ws].[DWHDataSet]            WITH(NOLOCK) WHERE [Product Code] <> 'CMC' AND EOMONTH([Issue Date])<=EOMONTH(GETDATE())
UNION ALL SELECT 'DWHDataSetSummaryCBA'   AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [azsyddwh02].[db-au-actuary].[ws].[DWHDataSetSummary]     WITH(NOLOCK) WHERE [Product Code] <> 'CMC' AND EOMONTH([Issue Date])<=EOMONTH(GETDATE())
--          SELECT 'out_ClaimDataSet_Zurich'      AS [Table], MAX([IncurredTime]) AS [Last Posting Date], NULL AS [Last Issue Date]             , COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[out_ClaimDataSet_Zurich]      WITH(NOLOCK) 
--UNION ALL SELECT 'out_ClaimDataSetCBA_Zurich'   AS [Table], MAX([IncurredTime]) AS [Last Posting Date], NULL AS [Last Issue Date]             , COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[out_ClaimDataSetCBA_Zurich]   WITH(NOLOCK) 
--UNION ALL SELECT 'DWHDataSet_Zurich'            AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSet_Zurich]            WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
--UNION ALL SELECT 'DWHDataSetSummary_Zurich'     AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSetSummary_Zurich]     WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
--UNION ALL SELECT 'DWHDataSetCBA_Zurich'         AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSetCBA_Zurich]         WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
--UNION ALL SELECT 'DWHDataSetSummaryCBA_Zurich'  AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSetSummaryCBA_Zurich]  WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
--UNION ALL SELECT 'DWHDataSet_Finance'           AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSet_Finance]           WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
--UNION ALL SELECT 'DWHDataSetSummary_Finance'    AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSetSummary_Finance]    WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
--UNION ALL SELECT 'DWHDataSetCBA_Finance'        AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSetCBA_Finance]        WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
--UNION ALL SELECT 'DWHDataSetSummaryCBA_Finance' AS [Table], MAX([Posting Date]) AS [Last Posting Date], MAX([Issue Date]) AS [Last Issue Date], COUNT(*) AS [Row Count] FROM [db-au-actuary].[dbo].[DWHDataSetSummaryCBA_Finance] WITH(NOLOCK)  WHERE [Product Code] <> 'CMC'
;
GO
