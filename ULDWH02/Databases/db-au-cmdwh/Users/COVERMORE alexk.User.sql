USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\alexk]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\alexk] FOR LOGIN [COVERMORE\alexk] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\alexk]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\alexk]
GO
