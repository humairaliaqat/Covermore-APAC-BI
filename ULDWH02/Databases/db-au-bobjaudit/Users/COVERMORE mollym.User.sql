USE [db-au-bobjaudit]
GO
/****** Object:  User [COVERMORE\mollym]    Script Date: 21/02/2025 11:29:58 AM ******/
CREATE USER [COVERMORE\mollym] FOR LOGIN [COVERMORE\mollym] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\mollym]
GO
