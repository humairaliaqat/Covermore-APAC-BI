USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\b.sumanth]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\b.sumanth] FOR LOGIN [COVERMORE\b.sumanth] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\b.sumanth]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\b.sumanth]
GO
