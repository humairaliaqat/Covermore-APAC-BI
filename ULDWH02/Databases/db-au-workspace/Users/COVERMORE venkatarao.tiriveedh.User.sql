USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\venkatarao.tiriveedh]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\venkatarao.tiriveedh] FOR LOGIN [COVERMORE\venkatarao.tiriveedh] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\venkatarao.tiriveedh]
GO
