USE [db-au-bobj]
GO
/****** Object:  User [cmadmin]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE USER [cmadmin] FOR LOGIN [cmadmin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [cmadmin]
GO
