USE [db-au-star]
GO
/****** Object:  User [COVERMORE\gordonc]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\gordonc] FOR LOGIN [COVERMORE\gordonc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\gordonc]
GO
