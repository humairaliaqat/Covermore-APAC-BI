USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\kota.kumar]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\kota.kumar] FOR LOGIN [COVERMORE\kota.kumar] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\kota.kumar]
GO
