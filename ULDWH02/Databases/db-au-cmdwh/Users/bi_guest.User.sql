USE [db-au-cmdwh]
GO
/****** Object:  User [bi_guest]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [bi_guest] FOR LOGIN [bi_guest] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [bi_guest]
GO
