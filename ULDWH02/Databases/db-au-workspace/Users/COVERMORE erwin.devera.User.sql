USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\erwin.devera]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\erwin.devera] FOR LOGIN [COVERMORE\erwin.devera] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\erwin.devera]
GO
