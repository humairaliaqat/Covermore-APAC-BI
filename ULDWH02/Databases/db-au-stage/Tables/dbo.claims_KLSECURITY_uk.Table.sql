USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLSECURITY_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLSECURITY_uk](
	[KS_ID] [int] NOT NULL,
	[KSLIMITS] [money] NULL,
	[KSESTLIMITS] [money] NULL,
	[KSINITS] [varchar](3) NULL,
	[KSNAME] [varchar](30) NULL,
	[KSLOGIN] [varchar](15) NULL,
	[KSAUTH] [bit] NOT NULL,
	[KSSTART] [datetime] NULL,
	[KSEND] [datetime] NULL,
	[KSLEVEL] [smallint] NULL,
	[KSCLAIMALLOC] [varchar](26) NULL,
	[KSPASSWD] [varchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_klsecurity_uk_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klsecurity_uk_id] ON [dbo].[claims_KLSECURITY_uk]
(
	[KS_ID] ASC
)
INCLUDE([KSNAME]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
