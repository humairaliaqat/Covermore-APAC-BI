USE [db-au-stage]
GO
/****** Object:  User [COVERMORE\b.sumanth]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [COVERMORE\b.sumanth] FOR LOGIN [COVERMORE\b.sumanth] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\b.sumanth]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\b.sumanth]
GO
