USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\appbobj]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\appbobj] FOR LOGIN [COVERMORE\appbobj] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\appbobj]
GO
