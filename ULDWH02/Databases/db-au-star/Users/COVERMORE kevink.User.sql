USE [db-au-star]
GO
/****** Object:  User [COVERMORE\kevink]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\kevink] FOR LOGIN [COVERMORE\kevink] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\kevink]
GO
