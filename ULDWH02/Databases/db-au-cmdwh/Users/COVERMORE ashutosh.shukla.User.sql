USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\ashutosh.shukla]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\ashutosh.shukla] FOR LOGIN [COVERMORE\ashutosh.shukla] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\ashutosh.shukla]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\ashutosh.shukla]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\ashutosh.shukla]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\ashutosh.shukla]
GO
