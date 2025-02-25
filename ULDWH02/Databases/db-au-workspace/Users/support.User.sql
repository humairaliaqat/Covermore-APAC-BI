USE [db-au-workspace]
GO
/****** Object:  User [support]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [support] FOR LOGIN [support] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [support]
GO
ALTER ROLE [db_datareader] ADD MEMBER [support]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [support]
GO
