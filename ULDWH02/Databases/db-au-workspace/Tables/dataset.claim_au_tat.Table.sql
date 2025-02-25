USE [db-au-workspace]
GO
/****** Object:  Table [dataset].[claim_au_tat]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dataset].[claim_au_tat](
	[ClaimKey] [varchar](40) NULL,
	[Status] [nvarchar](100) NULL,
	[Age Bracket] [varchar](10) NOT NULL,
	[Age Sorter] [int] NOT NULL,
	[TAT] [int] NULL,
	[LastStatusName] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
