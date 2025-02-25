USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\leony]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\leony] FOR LOGIN [COVERMORE\leony] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\leony]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\leony]
GO
