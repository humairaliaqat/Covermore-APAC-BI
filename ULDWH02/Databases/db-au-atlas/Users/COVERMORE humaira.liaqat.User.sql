USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\humaira.liaqat]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\humaira.liaqat] FOR LOGIN [COVERMORE\humaira.liaqat] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\humaira.liaqat]
GO
