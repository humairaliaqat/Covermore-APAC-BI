USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\david.soto]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\david.soto] FOR LOGIN [COVERMORE\david.soto] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\david.soto]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\david.soto]
GO
