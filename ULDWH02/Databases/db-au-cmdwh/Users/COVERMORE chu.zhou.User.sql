USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\chu.zhou]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\chu.zhou] FOR LOGIN [COVERMORE\chu.zhou] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\chu.zhou]
GO
