USE [db-au-log]
GO
/****** Object:  User [covermore\danem]    Script Date: 24/02/2025 2:34:43 PM ******/
CREATE USER [covermore\danem] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [covermore\danem]
GO
