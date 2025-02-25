USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\dominicr]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\dominicr] FOR LOGIN [COVERMORE\dominicr] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_executor] ADD MEMBER [COVERMORE\dominicr]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\dominicr]
GO
