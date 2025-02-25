USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sapresentingiss_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sapresentingiss_audtc](
	[kpresissueid] [int] NOT NULL,
	[presissue] [nvarchar](55) NOT NULL,
	[kpresissuegroup] [int] NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[picode] [nvarchar](10) NULL,
	[valisactive] [varchar](5) NOT NULL,
	[picode10] [nvarchar](10) NULL,
	[presentingissuelabel] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
