USE [db-au-cmdwh]
GO
/****** Object:  User [dbcopier]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [dbcopier] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [dbcopier]
GO
