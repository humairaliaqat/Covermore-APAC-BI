USE [db-au-cmdwh]
GO
/****** Object:  User [Penguin_LnkSvrUser]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [Penguin_LnkSvrUser] FOR LOGIN [Penguin_LnkSvrUser] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [Penguin_LnkSvrUser]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Penguin_LnkSvrUser]
GO
