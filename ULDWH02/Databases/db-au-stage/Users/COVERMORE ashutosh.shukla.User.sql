USE [db-au-stage]
GO
/****** Object:  User [COVERMORE\ashutosh.shukla]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE USER [COVERMORE\ashutosh.shukla] FOR LOGIN [COVERMORE\ashutosh.shukla] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\ashutosh.shukla]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\ashutosh.shukla]
GO
