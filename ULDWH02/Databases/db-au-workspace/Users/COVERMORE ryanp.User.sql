USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\ryanp]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\ryanp] FOR LOGIN [COVERMORE\ryanp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\ryanp]
GO
