USE [db-au-star]
GO
/****** Object:  User [COVERMORE\brookl]    Script Date: 24/02/2025 5:10:00 PM ******/
CREATE USER [COVERMORE\brookl] FOR LOGIN [COVERMORE\brookl] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [COVERMORE\brookl]
GO
