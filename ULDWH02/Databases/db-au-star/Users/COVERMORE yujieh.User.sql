USE [db-au-star]
GO
/****** Object:  User [COVERMORE\yujieh]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\yujieh] FOR LOGIN [COVERMORE\yujieh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\yujieh]
GO
