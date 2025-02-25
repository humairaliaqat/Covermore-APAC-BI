USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\calvinn]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\calvinn] FOR LOGIN [COVERMORE\calvinn] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\calvinn]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\calvinn]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\calvinn]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\calvinn]
GO
