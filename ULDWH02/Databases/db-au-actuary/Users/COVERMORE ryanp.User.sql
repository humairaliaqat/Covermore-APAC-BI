USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\ryanp]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\ryanp] FOR LOGIN [COVERMORE\ryanp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\ryanp]
GO
