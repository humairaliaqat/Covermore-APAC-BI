USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_btbatchinfo_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_btbatchinfo_audtc](
	[batchno] [int] NOT NULL,
	[batchname] [nvarchar](100) NOT NULL,
	[batchposted] [varchar](5) NOT NULL,
	[batchdate] [datetime2](7) NOT NULL,
	[batchpostdate] [datetime2](7) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[sloginby] [nvarchar](10) NOT NULL,
	[slogmodby] [nvarchar](10) NOT NULL,
	[ksiteidbatchedat] [int] NULL
) ON [PRIMARY]
GO
