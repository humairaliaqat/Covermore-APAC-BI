USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\adm_dane]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\adm_dane] FOR LOGIN [COVERMORE\adm_dane] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\adm_dane]
GO
