USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\humaira.liaqat]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\humaira.liaqat] FOR LOGIN [COVERMORE\humaira.liaqat] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\humaira.liaqat]
GO
