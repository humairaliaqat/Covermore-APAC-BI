USE [db-au-star]
GO
/****** Object:  User [avi]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [avi] FOR LOGIN [avi] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [avi]
GO
