USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\maxc]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\maxc] FOR LOGIN [COVERMORE\maxc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\maxc]
GO
