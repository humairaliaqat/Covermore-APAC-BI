USE [db-au-log]
GO
/****** Object:  Table [dbo].[TBLDATAMANAGMENT]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBLDATAMANAGMENT](
	[DATECREATED] [date] NOT NULL,
	[OWNER] [varchar](50) NOT NULL,
	[DBNAME] [varchar](50) NOT NULL,
	[TABLENAME] [varchar](50) NOT NULL,
	[EXPIRYDATE] [varchar](50) NOT NULL,
	[COMMENTS] [varchar](250) NOT NULL
) ON [PRIMARY]
GO
