USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\srisaileshp]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\srisaileshp] FOR LOGIN [COVERMORE\srisaileshp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\srisaileshp]
GO
