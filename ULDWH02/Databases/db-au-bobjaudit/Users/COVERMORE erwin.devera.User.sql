USE [db-au-bobjaudit]
GO
/****** Object:  User [COVERMORE\erwin.devera]    Script Date: 21/02/2025 11:29:58 AM ******/
CREATE USER [COVERMORE\erwin.devera] FOR LOGIN [COVERMORE\erwin.devera] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\erwin.devera]
GO
