USE [db-au-star]
GO
/****** Object:  User [COVERMORE\alexk]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\alexk] FOR LOGIN [COVERMORE\alexk] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\alexk]
GO
