USE [db-au-star]
GO
/****** Object:  User [COVERMORE\surbhi.gupta]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\surbhi.gupta] FOR LOGIN [COVERMORE\surbhi.gupta] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\surbhi.gupta]
GO
