USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\margarete]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\margarete] FOR LOGIN [COVERMORE\margarete] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\margarete]
GO
