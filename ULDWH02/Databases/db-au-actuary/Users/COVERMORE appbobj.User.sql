USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\appbobj]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\appbobj] FOR LOGIN [COVERMORE\appbobj] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\appbobj]
GO
