USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\abhilash.yelmelwar]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\abhilash.yelmelwar] FOR LOGIN [COVERMORE\abhilash.yelmelwar] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\abhilash.yelmelwar]
GO
