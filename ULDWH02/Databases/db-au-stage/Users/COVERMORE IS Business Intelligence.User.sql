USE [db-au-stage]
GO
/****** Object:  User [COVERMORE\IS Business Intelligence]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [COVERMORE\IS Business Intelligence] FOR LOGIN [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_ddlview] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
