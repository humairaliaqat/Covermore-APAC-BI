USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sasite_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sasite_audtc](
	[ksiteid] [int] NOT NULL,
	[sitename] [nvarchar](30) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[siteaddr1] [nvarchar](60) NULL,
	[siteaddr2] [nvarchar](60) NULL,
	[sitecity] [nvarchar](20) NULL,
	[lusiteprovstateid] [int] NULL,
	[lusitecountryid] [int] NULL,
	[sitepczip] [nvarchar](12) NULL,
	[sitephone] [nvarchar](13) NULL,
	[sitefax] [nvarchar](13) NULL,
	[siteplaceofservice] [nchar](4) NULL,
	[sitesendclaimtoaddr] [varchar](5) NULL,
	[sitesendpaymenttoaddr] [varchar](5) NULL,
	[siteactive] [varchar](5) NOT NULL,
	[kparentsiteid] [int] NULL,
	[sitefahcsiaoutlet] [ntext] NULL,
	[banknumber] [ntext] NULL,
	[lusiteud1id] [int] NULL,
	[lusiteud2id] [int] NULL,
	[siteud3] [ntext] NULL,
	[siteud4] [ntext] NULL,
	[siteud5] [nvarchar](100) NULL,
	[siteud6] [nvarchar](100) NULL,
	[lusiteregionid] [int] NULL,
	[sitecounty] [nvarchar](50) NULL,
	[siteglcode] [nvarchar](50) NULL,
	[sitelocsameasagency] [varchar](5) NOT NULL,
	[lusiteud7id] [int] NULL,
	[lusiteud8id] [int] NULL,
	[lusiteud9id] [int] NULL,
	[lusiteud10id] [int] NULL,
	[lusiteud11id] [int] NULL,
	[lusiteud12id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
