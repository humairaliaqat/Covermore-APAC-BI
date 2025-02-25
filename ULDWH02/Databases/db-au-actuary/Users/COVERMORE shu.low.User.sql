USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\shu.low]    Script Date: 21/02/2025 11:15:49 AM ******/
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
