USE [db-au-actuary]
GO
/****** Object:  View [dbo].[fxHistory]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[fxHistory] AS
SELECT * 
FROM [db-au-cmdwh]..[fxHistory]
GO
