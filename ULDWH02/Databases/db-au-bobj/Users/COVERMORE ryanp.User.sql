USE [db-au-bobj]
GO
/****** Object:  User [COVERMORE\ryanp]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE USER [COVERMORE\ryanp] FOR LOGIN [COVERMORE\ryanp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\ryanp]
GO
