USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\leony]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\leony] FOR LOGIN [COVERMORE\leony] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\leony]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\leony]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\leony]
GO
