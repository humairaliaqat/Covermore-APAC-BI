USE [db-au-star]
GO
/****** Object:  User [COVERMORE\michaelsto]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\michaelsto] FOR LOGIN [COVERMORE\michaelsto] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\michaelsto]
GO
