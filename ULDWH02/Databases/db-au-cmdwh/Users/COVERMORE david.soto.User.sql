USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\david.soto]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\david.soto] FOR LOGIN [COVERMORE\david.soto] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\david.soto]
GO
