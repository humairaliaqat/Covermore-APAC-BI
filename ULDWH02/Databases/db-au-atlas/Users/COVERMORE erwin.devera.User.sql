USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\erwin.devera]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\erwin.devera] FOR LOGIN [COVERMORE\erwin.devera] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\erwin.devera]
GO
