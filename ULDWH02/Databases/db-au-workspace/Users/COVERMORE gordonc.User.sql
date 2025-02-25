USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\gordonc]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\gordonc] FOR LOGIN [COVERMORE\gordonc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\gordonc]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\gordonc]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\gordonc]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\gordonc]
GO
