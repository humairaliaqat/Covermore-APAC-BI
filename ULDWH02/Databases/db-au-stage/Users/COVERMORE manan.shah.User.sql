USE [db-au-stage]
GO
/****** Object:  User [COVERMORE\manan.shah]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [COVERMORE\manan.shah] FOR LOGIN [COVERMORE\manan.shah] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\manan.shah]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\manan.shah]
GO
