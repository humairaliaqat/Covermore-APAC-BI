USE [db-au-atlas]
GO
/****** Object:  User [COVERMORE\thomassp]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE USER [COVERMORE\thomassp] FOR LOGIN [COVERMORE\thomassp] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\thomassp]
GO
