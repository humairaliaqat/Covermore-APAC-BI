USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\candyc]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\candyc] FOR LOGIN [COVERMORE\candyc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\candyc]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\candyc]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\candyc]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\candyc]
GO
