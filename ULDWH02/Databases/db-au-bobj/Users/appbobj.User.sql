USE [db-au-bobj]
GO
/****** Object:  User [appbobj]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE USER [appbobj] FOR LOGIN [appbobj] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [appbobj]
GO
