USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\IS Business Intelligence]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\IS Business Intelligence] FOR LOGIN [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\IS Business Intelligence]
GO
