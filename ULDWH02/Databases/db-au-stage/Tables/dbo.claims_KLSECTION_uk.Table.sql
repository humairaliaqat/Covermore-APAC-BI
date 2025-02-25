USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLSECTION_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLSECTION_uk](
	[KS_ID] [int] NOT NULL,
	[KSCLAIM_ID] [int] NULL,
	[KSEVENT_ID] [int] NULL,
	[KSSECTCODE] [varchar](5) NULL,
	[KSESTV] [money] NULL,
	[KSREDUND] [bit] NOT NULL,
	[KBSECT_ID] [int] NULL,
	[KBSS_ID] [int] NULL
) ON [PRIMARY]
GO
