USE [db-au-cba-healix]
GO
/****** Object:  User [COVERMORE\humaira.liaqat]    Script Date: 20/02/2025 3:54:01 PM ******/
CREATE USER [COVERMORE\humaira.liaqat] FOR LOGIN [COVERMORE\humaira.liaqat] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\humaira.liaqat]
GO
