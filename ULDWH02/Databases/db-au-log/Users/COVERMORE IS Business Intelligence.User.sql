USE [db-au-log]
GO
/****** Object:  User [COVERMORE\IS Business Intelligence]    Script Date: 24/02/2025 2:34:43 PM ******/
CREATE USER [COVERMORE\IS Business Intelligence] FOR LOGIN [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
