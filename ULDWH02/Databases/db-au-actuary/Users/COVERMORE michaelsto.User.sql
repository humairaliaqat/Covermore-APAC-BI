USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\michaelsto]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\michaelsto] FOR LOGIN [COVERMORE\michaelsto] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\michaelsto]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\michaelsto]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\michaelsto]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\michaelsto]
GO
