USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\mollym]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\mollym] FOR LOGIN [COVERMORE\mollym] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\mollym]
GO
