USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\leonarduss]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\leonarduss] FOR LOGIN [COVERMORE\leonarduss] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\leonarduss]
GO
