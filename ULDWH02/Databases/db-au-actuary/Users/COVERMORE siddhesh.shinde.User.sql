USE [db-au-actuary]
GO
/****** Object:  User [COVERMORE\siddhesh.shinde]    Script Date: 21/02/2025 11:15:49 AM ******/
CREATE USER [COVERMORE\siddhesh.shinde] FOR LOGIN [COVERMORE\siddhesh.shinde] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\siddhesh.shinde]
GO
