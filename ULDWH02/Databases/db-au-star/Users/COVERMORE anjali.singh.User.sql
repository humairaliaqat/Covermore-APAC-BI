USE [db-au-star]
GO
/****** Object:  User [COVERMORE\anjali.singh]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\anjali.singh] FOR LOGIN [COVERMORE\anjali.singh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\anjali.singh]
GO
