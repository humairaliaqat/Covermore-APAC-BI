USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\adm_dane]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\adm_dane] FOR LOGIN [COVERMORE\adm_dane] WITH DEFAULT_SCHEMA=[covermore\adm_dane]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\adm_dane]
GO
