USE [db-au-star]
GO
/****** Object:  User [COVERMORE\laura.zhao]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\laura.zhao] FOR LOGIN [COVERMORE\laura.zhao] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\laura.zhao]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\laura.zhao]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\laura.zhao]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\laura.zhao]
GO
