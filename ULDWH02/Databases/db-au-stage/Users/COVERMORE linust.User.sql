USE [db-au-stage]
GO
/****** Object:  User [COVERMORE\linust]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [COVERMORE\linust] FOR LOGIN [COVERMORE\linust] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\linust]
GO
