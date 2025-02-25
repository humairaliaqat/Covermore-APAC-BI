USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\gordonc]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\gordonc] FOR LOGIN [COVERMORE\gordonc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\gordonc]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\gordonc]
GO
