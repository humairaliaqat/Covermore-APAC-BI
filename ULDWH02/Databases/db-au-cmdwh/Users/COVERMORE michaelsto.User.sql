USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\michaelsto]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\michaelsto] FOR LOGIN [COVERMORE\michaelsto] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\michaelsto]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\michaelsto]
GO
