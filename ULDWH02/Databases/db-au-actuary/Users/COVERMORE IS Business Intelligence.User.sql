USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\IS Business Intelligence]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\IS Business Intelligence] FOR LOGIN [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
