USE [db-au-stage]
GO
/****** Object:  User [COVERMORE\vitri.sumantri]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [COVERMORE\vitri.sumantri] FOR LOGIN [COVERMORE\vitri.sumantri] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\vitri.sumantri]
GO
