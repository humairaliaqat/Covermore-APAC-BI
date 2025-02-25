USE [db-au-stage]
GO
/****** Object:  User [COVERMORE\mollym]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [COVERMORE\mollym] FOR LOGIN [COVERMORE\mollym] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_ddlview] ADD MEMBER [COVERMORE\mollym]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\mollym]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\mollym]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\mollym]
GO
