USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\vikas.bari]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\vikas.bari] FOR LOGIN [COVERMORE\vikas.bari] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\vikas.bari]
GO
