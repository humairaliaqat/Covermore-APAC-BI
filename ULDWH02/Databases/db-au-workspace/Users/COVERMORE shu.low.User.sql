USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\shu.low]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\shu.low] FOR LOGIN [COVERMORE\shu.low] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\shu.low]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\shu.low]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\shu.low]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [COVERMORE\shu.low]
GO
