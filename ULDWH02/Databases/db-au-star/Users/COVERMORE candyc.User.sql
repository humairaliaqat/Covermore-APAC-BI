USE [db-au-star]
GO
/****** Object:  User [COVERMORE\candyc]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\candyc] FOR LOGIN [COVERMORE\candyc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\candyc]
GO
