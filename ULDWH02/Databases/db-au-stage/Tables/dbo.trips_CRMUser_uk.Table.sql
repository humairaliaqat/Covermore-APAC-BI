USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_CRMUser_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_CRMUser_uk](
	[CRMUSERID] [numeric](18, 0) NOT NULL,
	[NAME] [varchar](50) NULL,
	[INITIAL] [varchar](10) NULL,
	[USERNAME] [varchar](50) NOT NULL,
	[PASSWORD] [varchar](50) NULL,
	[REPTYPE] [varchar](15) NULL,
	[ACCESSLEVEL] [int] NULL,
	[LASTLOGIN] [datetime] NULL,
	[ACTIVE] [bit] NOT NULL,
	[PPPENGUIN] [int] NULL
) ON [PRIMARY]
GO
