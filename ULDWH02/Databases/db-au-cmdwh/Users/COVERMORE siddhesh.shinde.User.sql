USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\siddhesh.shinde]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\siddhesh.shinde] FOR LOGIN [COVERMORE\siddhesh.shinde] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\siddhesh.shinde]
GO
