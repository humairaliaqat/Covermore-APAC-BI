USE [db-au-workspace]
GO
/****** Object:  User [appbobj]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [appbobj] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [appbobj]
GO
