USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\linust]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\linust] FOR LOGIN [COVERMORE\linust] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\linust]
GO
