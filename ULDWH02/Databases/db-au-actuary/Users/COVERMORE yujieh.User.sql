USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\yujieh]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\yujieh] FOR LOGIN [COVERMORE\yujieh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\yujieh]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\yujieh]
GO
