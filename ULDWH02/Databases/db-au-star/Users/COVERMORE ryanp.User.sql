USE [db-au-star]
GO
/****** Object:  User [COVERMORE\ryanp]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\ryanp] FOR LOGIN [COVERMORE\ryanp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\ryanp]
GO
