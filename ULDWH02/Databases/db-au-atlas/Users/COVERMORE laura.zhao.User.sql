USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\laura.zhao]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\laura.zhao] FOR LOGIN [COVERMORE\laura.zhao] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\laura.zhao]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\laura.zhao]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\laura.zhao]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\laura.zhao]
GO
