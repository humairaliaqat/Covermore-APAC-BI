USE [db-au-log]
GO
/****** Object:  User [COVERMORE\ryanp]    Script Date: 24/02/2025 2:34:43 PM ******/
CREATE USER [COVERMORE\ryanp] FOR LOGIN [COVERMORE\ryanp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\ryanp]
GO
