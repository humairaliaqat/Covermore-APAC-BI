USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\IS Business Intelligence]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\IS Business Intelligence] FOR LOGIN [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
