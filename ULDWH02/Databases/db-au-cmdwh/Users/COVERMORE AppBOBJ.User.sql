USE [db-au-cmdwh]
GO
/****** Object:  User [COVERMORE\AppBOBJ]    Script Date: 24/02/2025 12:39:31 PM ******/
CREATE USER [COVERMORE\AppBOBJ] FOR LOGIN [COVERMORE\appbobj] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [COVERMORE\AppBOBJ]
GO
