USE [db-au-cmdwh]
GO
/****** Object:  User [AppPenguinUser]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [AppPenguinUser] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [AppPenguinUser]
GO
ALTER ROLE [db_datareader] ADD MEMBER [AppPenguinUser]
GO
