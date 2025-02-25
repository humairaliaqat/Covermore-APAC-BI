USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\calvinn]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\calvinn] FOR LOGIN [COVERMORE\calvinn] WITH DEFAULT_SCHEMA=[cng]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\calvinn]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\calvinn]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\calvinn]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\calvinn]
GO
