USE [db-au-star]
GO
/****** Object:  User [COVERMORE\erwin.devera]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\erwin.devera] FOR LOGIN [COVERMORE\erwin.devera] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\erwin.devera]
GO
