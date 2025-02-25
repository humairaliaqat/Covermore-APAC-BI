USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_ADM_USER_aucm]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_ADM_USER_aucm](
	[USERID] [varchar](30) NOT NULL,
	[SURNAME] [varchar](30) NULL,
	[PREF_NAME] [varchar](20) NULL,
	[SEC_GROUP] [varchar](10) NULL,
	[PASSWD] [varchar](30) NULL,
	[Display] [int] NULL
) ON [PRIMARY]
GO
