USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\candyc]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\candyc] FOR LOGIN [COVERMORE\candyc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\candyc]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\candyc]
GO
