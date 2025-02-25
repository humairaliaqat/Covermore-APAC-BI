USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\gordonc]    Script Date: 21/02/2025 11:15:49 AM ******/
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
