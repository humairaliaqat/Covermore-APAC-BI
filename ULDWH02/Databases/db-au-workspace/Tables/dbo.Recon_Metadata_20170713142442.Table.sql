USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Recon_Metadata_20170713142442]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recon_Metadata_20170713142442](
	[ID] [int] NOT NULL,
	[Active] [tinyint] NULL,
	[SubjectArea] [varchar](50) NULL,
	[ETLName] [varchar](50) NULL,
	[Group] [varchar](50) NULL,
	[Category] [varchar](50) NULL,
	[Target] [varchar](50) NULL,
	[Source1] [varchar](50) NULL,
	[Source2] [varchar](50) NULL,
	[Source3] [varchar](50) NULL,
	[AllZero] [bit] NULL,
	[Comment] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
