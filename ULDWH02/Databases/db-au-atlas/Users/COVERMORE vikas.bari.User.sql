USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\vikas.bari]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\vikas.bari] FOR LOGIN [COVERMORE\vikas.bari] WITH DEFAULT_SCHEMA=[atlas]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\vikas.bari]
GO
