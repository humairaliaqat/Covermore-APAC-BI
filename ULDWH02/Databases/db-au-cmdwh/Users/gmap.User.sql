USE [db-au-cmdwh]
GO
/****** Object:  User [gmap]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [gmap] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [gmap]
GO
ALTER ROLE [db_datareader] ADD MEMBER [gmap]
GO
