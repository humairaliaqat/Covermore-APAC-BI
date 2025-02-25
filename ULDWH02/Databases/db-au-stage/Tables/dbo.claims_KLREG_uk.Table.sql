USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLREG_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLREG_uk](
	[KLCLAIM] [int] NOT NULL,
	[KLCREATEDBY_ID] [int] NULL,
	[KLCREATED] [datetime] NULL,
	[KLOFFICER_ID] [int] NULL,
	[KLSTATUS_ID] [int] NULL,
	[KLRECEIVED] [datetime] NULL,
	[KLAUTH] [varchar](1) NULL,
	[KLACTIONDATE] [datetime] NULL,
	[KLACTION] [int] NULL,
	[KLFINALDATE] [datetime] NULL,
	[KLARCBOX] [varchar](20) NULL,
	[KLPOL_ID] [int] NULL,
	[KLPOLICY] [int] NULL,
	[KLPRODUCT] [varchar](4) NULL,
	[KLALPHA] [varchar](7) NULL,
	[KLPLAN] [varchar](4) NULL,
	[KLINTDOM] [varchar](3) NULL,
	[KLEXCESS] [money] NULL,
	[KLSF] [varchar](1) NULL,
	[KLDISS] [datetime] NULL,
	[KLACT] [datetime] NULL,
	[KLDEP] [datetime] NULL,
	[KLRET] [datetime] NULL,
	[KLDAYS] [int] NULL,
	[KLITCPREM] [float] NULL,
	[KLEMCAPPROV] [varchar](15) NULL,
	[KLGROUPPOL] [tinyint] NULL,
	[KLLUGG] [tinyint] NULL,
	[KLHRISK] [tinyint] NULL,
	[KLCASE] [varchar](14) NULL,
	[KLCOMMENT] [text] NULL,
	[KLPROD_ID] [int] NULL,
	[KLPLAN_ID] [int] NULL,
	[KLRECOVERY] [tinyint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_klreg_uk_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klreg_uk_id] ON [dbo].[claims_KLREG_uk]
(
	[KLCLAIM] ASC
)
INCLUDE([KLPRODUCT],[KLDISS]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
