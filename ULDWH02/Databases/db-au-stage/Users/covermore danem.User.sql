USE [db-au-stage]
GO
/****** Object:  User [covermore\danem]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [covermore\danem] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [covermore\danem]
GO
