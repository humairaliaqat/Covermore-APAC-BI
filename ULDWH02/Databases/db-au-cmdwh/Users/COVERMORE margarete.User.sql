USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\margarete]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\margarete] FOR LOGIN [COVERMORE\margarete] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\margarete]
GO
