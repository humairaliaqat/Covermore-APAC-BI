USE [db-au-bobjaudit]
GO
/****** Object:  User [COVERMORE\adm_ratneshs]    Script Date: 21/02/2025 11:29:58 AM ******/
CREATE USER [COVERMORE\adm_ratneshs] FOR LOGIN [COVERMORE\adm_ratneshs] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\adm_ratneshs]
GO
