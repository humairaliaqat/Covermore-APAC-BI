USE [db-au-workspace]
GO
/****** Object:  View [dbo].[QuotesAnalyticsLowerThresholdView]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[QuotesAnalyticsLowerThresholdView] AS
SELECT Date as [date], Partner as [Partner], LowerThreshold as [Lowerthreshold], UpperThreshold as [Upperthreshold], IncomingDataCount as [IncomingDataCount]
FROM [db-au-workspace].dbo.tbl_recon_analytics_quote 
WHERE [date] = CAST(GETDATE() - 3 AS DATE) 
AND IncomingDataCount > LowerThreshold;
GO
