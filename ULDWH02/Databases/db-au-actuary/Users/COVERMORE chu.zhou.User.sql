USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\chu.zhou]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\chu.zhou] FOR LOGIN [COVERMORE\chu.zhou] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\chu.zhou]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\chu.zhou]
GO
