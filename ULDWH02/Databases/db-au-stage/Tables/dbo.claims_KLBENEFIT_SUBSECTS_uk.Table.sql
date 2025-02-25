USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLBENEFIT_SUBSECTS_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLBENEFIT_SUBSECTS_uk](
	[KBSS_ID] [int] NOT NULL,
	[KBSECT_ID] [int] NULL,
	[KBSS_DESC] [varchar](50) NULL,
	[Limit] [money] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL,
	[comments] [varchar](255) NULL
) ON [PRIMARY]
GO
