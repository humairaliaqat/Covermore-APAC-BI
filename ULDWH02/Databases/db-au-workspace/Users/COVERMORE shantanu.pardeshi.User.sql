USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\shantanu.pardeshi]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\shantanu.pardeshi] FOR LOGIN [COVERMORE\shantanu.pardeshi] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_CG_datareader] ADD MEMBER [COVERMORE\shantanu.pardeshi]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\shantanu.pardeshi]
GO
