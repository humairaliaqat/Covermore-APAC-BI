USE [db-au-star]
GO
/****** Object:  User [COVERMORE\dominicr]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\dominicr] FOR LOGIN [COVERMORE\dominicr] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\dominicr]
GO
