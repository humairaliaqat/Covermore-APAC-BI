USE [db-au-cmdwh]
GO
/****** Object:  User [support]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [support] FOR LOGIN [support] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [support]
GO
