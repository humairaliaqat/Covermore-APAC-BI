USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\manan.shah]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\manan.shah] FOR LOGIN [COVERMORE\manan.shah] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\manan.shah]
GO
