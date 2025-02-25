USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\alexk]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\alexk] FOR LOGIN [COVERMORE\alexk] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\alexk]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\alexk]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\alexk]
GO
