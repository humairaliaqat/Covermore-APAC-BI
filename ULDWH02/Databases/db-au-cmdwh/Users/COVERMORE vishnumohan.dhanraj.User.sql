USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\vishnumohan.dhanraj]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\vishnumohan.dhanraj] FOR LOGIN [COVERMORE\vishnumohan.dhanraj] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\vishnumohan.dhanraj]
GO
