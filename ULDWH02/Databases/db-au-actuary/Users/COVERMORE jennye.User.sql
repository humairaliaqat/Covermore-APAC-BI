USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\jennye]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\jennye] FOR LOGIN [COVERMORE\jennye] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\jennye]
GO
