USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\yujieh]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\yujieh] FOR LOGIN [COVERMORE\yujieh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\yujieh]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\yujieh]
GO
