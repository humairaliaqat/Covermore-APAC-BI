USE [db-au-bobj]
GO
/****** Object:  User [COVERMORE\siddhesh.shinde]    Script Date: 21/02/2025 11:29:10 AM ******/
CREATE USER [COVERMORE\siddhesh.shinde] FOR LOGIN [COVERMORE\siddhesh.shinde] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\siddhesh.shinde]
GO
