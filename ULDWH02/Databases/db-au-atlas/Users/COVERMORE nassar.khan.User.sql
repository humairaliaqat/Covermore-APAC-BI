USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\nassar.khan]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\nassar.khan] FOR LOGIN [COVERMORE\nassar.khan] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\nassar.khan]
GO
