USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\dominicr]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\dominicr] FOR LOGIN [COVERMORE\dominicr] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\dominicr]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [COVERMORE\dominicr]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\dominicr]
GO
