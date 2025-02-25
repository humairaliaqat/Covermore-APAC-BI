USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_brtaxrate_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_brtaxrate_audtc](
	[ktaxrateid] [int] NOT NULL,
	[taxratename] [nvarchar](30) NOT NULL,
	[taxrateshort] [nvarchar](4) NOT NULL,
	[taxrate] [numeric](6, 5) NOT NULL,
	[taxrateactive] [varchar](5) NOT NULL,
	[taxratenotes] [ntext] NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NULL,
	[slogmodby] [nvarchar](10) NULL,
	[taxrateno] [nvarchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
