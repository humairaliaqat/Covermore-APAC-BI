USE [db-au-log]
GO
/****** Object:  User [COVERMORE\venkatarao.tiriveedh]    Script Date: 24/02/2025 2:34:43 PM ******/
CREATE USER [COVERMORE\venkatarao.tiriveedh] FOR LOGIN [COVERMORE\venkatarao.tiriveedh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\venkatarao.tiriveedh]
GO
