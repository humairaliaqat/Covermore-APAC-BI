USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\adm_ratneshs]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\adm_ratneshs] FOR LOGIN [COVERMORE\adm_ratneshs] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\adm_ratneshs]
GO
