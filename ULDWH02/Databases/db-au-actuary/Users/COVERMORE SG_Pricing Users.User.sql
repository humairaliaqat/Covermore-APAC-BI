USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\SG_Pricing Users]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\SG_Pricing Users] FOR LOGIN [COVERMORE\SG_Pricing Users]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\SG_Pricing Users]
GO
