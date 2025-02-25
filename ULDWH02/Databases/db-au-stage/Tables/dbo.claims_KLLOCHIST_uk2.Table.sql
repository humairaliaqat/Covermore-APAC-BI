USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLLOCHIST_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLLOCHIST_uk2](
	[LH_ID] [int] NOT NULL,
	[LHCLAIM_ID] [int] NULL,
	[LHLOC_ID] [int] NULL,
	[LHCREATEDBY_ID] [int] NULL,
	[LHCREATED] [datetime] NULL,
	[LHNOTE] [nvarchar](50) NULL,
	[LHCorroRecdDt] [datetime] NULL
) ON [PRIMARY]
GO
