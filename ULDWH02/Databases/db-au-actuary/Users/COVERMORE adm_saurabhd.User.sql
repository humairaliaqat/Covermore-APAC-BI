USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\adm_saurabhd]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\adm_saurabhd] FOR LOGIN [COVERMORE\adm_saurabhd] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\adm_saurabhd]
GO
