USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_irindwork_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_irindwork_audtc](
	[kindid] [int] NOT NULL,
	[kfunderid] [int] NULL,
	[indworkidentno] [nvarchar](30) NULL,
	[indworkname] [nvarchar](60) NULL,
	[indworkcontact] [nvarchar](60) NULL,
	[indworkaddress1] [nvarchar](60) NULL,
	[indworkaddress2] [nvarchar](60) NULL,
	[indworkcity] [nvarchar](20) NULL,
	[luindworkprovstateid] [int] NULL,
	[luindworkcountryid] [int] NULL,
	[indworkpzip] [nvarchar](12) NULL,
	[indworkurl] [nvarchar](70) NULL,
	[indworkcomments] [nvarchar](50) NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
