USE [db-au-workspace]
GO
/****** Object:  User [COVERMORE\IS Department]    Script Date: 24/02/2025 5:22:14 PM ******/
CREATE USER [COVERMORE\IS Department] FOR LOGIN [COVERMORE\IS Department]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\IS Department]
GO
