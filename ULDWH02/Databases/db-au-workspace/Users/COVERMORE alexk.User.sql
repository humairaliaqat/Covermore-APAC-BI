USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\alexk]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\alexk] FOR LOGIN [COVERMORE\alexk] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\alexk]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\alexk]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\alexk]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\alexk]
GO
