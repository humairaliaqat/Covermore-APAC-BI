USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\anjali.singh]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\anjali.singh] FOR LOGIN [COVERMORE\anjali.singh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\anjali.singh]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\anjali.singh]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\anjali.singh]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\anjali.singh]
GO
