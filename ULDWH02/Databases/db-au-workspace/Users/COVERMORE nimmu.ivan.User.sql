USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\nimmu.ivan]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\nimmu.ivan] FOR LOGIN [COVERMORE\nimmu.ivan] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\nimmu.ivan]
GO
