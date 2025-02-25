USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLLOCHIST_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLLOCHIST_uk](
	[LH_ID] [int] NOT NULL,
	[LHCLAIM_ID] [int] NULL,
	[LHLOC_ID] [int] NULL,
	[LHCREATEDBY_ID] [int] NULL,
	[LHCREATED] [datetime] NULL,
	[LHNOTE] [varchar](20) NULL
) ON [PRIMARY]
GO
