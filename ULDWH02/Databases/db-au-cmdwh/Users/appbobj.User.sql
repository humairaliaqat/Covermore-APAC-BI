USE [db-au-cmdwh]
GO
/****** Object:  User [appbobj]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [appbobj] FOR LOGIN [appbobj] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [appbobj]
GO
ALTER ROLE [db_datareader] ADD MEMBER [appbobj]
GO
