USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\maxc]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\maxc] FOR LOGIN [COVERMORE\maxc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\maxc]
GO
