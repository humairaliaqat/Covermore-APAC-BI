USE [db-au-bobj]
GO
/****** Object:  User [COVERMORE\mollym]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE USER [COVERMORE\mollym] FOR LOGIN [COVERMORE\mollym] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\mollym]
GO
