USE [db-au-star]
GO
/****** Object:  User [COVERMORE\leony]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\leony] FOR LOGIN [COVERMORE\leony] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\leony]
GO
