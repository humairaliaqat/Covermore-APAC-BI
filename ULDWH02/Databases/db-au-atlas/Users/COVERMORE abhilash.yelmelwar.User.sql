USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\abhilash.yelmelwar]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\abhilash.yelmelwar] FOR LOGIN [COVERMORE\abhilash.yelmelwar] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\abhilash.yelmelwar]
GO
