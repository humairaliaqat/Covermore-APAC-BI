USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\adm_dane]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\adm_dane] FOR LOGIN [COVERMORE\adm_dane] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\adm_dane]
GO
