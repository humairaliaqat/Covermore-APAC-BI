USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\maggieg]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\maggieg] FOR LOGIN [COVERMORE\maggieg] WITH DEFAULT_SCHEMA=[db_datareader]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\maggieg]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\maggieg]
GO
