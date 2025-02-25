USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_gtbluebookaddr_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_gtbluebookaddr_audtc](
	[kbluebookid] [int] NOT NULL,
	[bbaddress1] [nvarchar](60) NOT NULL,
	[bbaddress2] [nvarchar](60) NULL,
	[bbcity] [nvarchar](20) NULL,
	[luprovstateid] [int] NOT NULL,
	[lucountryid] [int] NOT NULL,
	[bbpczip] [nvarchar](12) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[lubbhoursid] [int] NULL,
	[afterhours] [ntext] NULL,
	[bbcounty] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
