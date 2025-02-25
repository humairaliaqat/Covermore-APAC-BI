USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[KLSECTION]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KLSECTION](
	[KS_ID] [int] NOT NULL,
	[KSCLAIM_ID] [int] NULL,
	[KSEVENT_ID] [int] NULL,
	[KSSECTCODE] [varchar](25) NULL,
	[KSESTV] [money] NULL,
	[KSREDUND] [bit] NOT NULL,
	[KBSS_ID] [int] NULL,
	[KSSECTDESC] [nvarchar](200) NULL,
	[KSBENEFITLIMIT] [nvarchar](200) NULL,
	[KSRECOVEST] [money] NULL
) ON [PRIMARY]
GO
