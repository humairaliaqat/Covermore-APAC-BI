USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\anjali.singh]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\anjali.singh] FOR LOGIN [COVERMORE\anjali.singh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\anjali.singh]
GO
