USE [db-au-stage]
GO
/****** Object:  User [cmadmin]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [cmadmin] FOR LOGIN [cmadmin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [cmadmin]
GO
