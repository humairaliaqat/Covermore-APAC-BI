USE [db-au-star]
GO
/****** Object:  User [COVERMORE\deepu.meethal]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\deepu.meethal] FOR LOGIN [COVERMORE\deepu.meethal] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\deepu.meethal]
GO
