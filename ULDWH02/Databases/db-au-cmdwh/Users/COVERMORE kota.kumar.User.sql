USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\kota.kumar]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\kota.kumar] FOR LOGIN [COVERMORE\kota.kumar] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\kota.kumar]
GO
