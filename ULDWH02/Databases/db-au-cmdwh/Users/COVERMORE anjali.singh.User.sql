USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\anjali.singh]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\anjali.singh] FOR LOGIN [COVERMORE\anjali.singh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\anjali.singh]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\anjali.singh]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\anjali.singh]
GO
