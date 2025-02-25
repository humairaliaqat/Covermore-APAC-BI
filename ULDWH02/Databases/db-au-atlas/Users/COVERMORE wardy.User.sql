USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\wardy]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\wardy] FOR LOGIN [COVERMORE\wardy] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\wardy]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [COVERMORE\wardy]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [COVERMORE\wardy]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [COVERMORE\wardy]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\wardy]
GO
