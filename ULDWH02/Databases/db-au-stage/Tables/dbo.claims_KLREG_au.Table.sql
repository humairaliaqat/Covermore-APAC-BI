USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLREG_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLREG_au](
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
	[KLPOLICY] [varchar](25) NULL,
	[KLPRODUCT] [varchar](4) NULL,
	[KLALPHA] [varchar](7) NULL,
	[KLPLAN] [varchar](50) NULL,
	[KLINTDOM] [varchar](3) NULL,
	[KLEXCESS] [money] NULL,
	[KLSF] [varchar](1) NULL,
	[KLDISS] [date] NULL,
	[KLACT] [date] NULL,
	[KLDEP] [date] NULL,
	[KLRET] [date] NULL,
	[KLDAYS] [int] NULL,
	[KLITCPREM] [float] NULL,
	[KLEMCAPPROV] [int] NULL,
	[KLGROUPPOL] [tinyint] NULL,
	[KLLUGG] [tinyint] NULL,
	[KLHRISK] [tinyint] NULL,
	[KLCASE] [varchar](14) NULL,
	[KLCOMMENT] [ntext] NULL,
	[KLPROD_ID] [int] NULL,
	[KLPLAN_ID] [int] NULL,
	[KLRECOVERY] [tinyint] NULL,
	[KLREC_OUTCOMEID] [int] NULL,
	[KLONLINE] [bit] NULL,
	[KLGroupCode] [varchar](20) NULL,
	[CultureCode] [nvarchar](10) NOT NULL,
	[KLDOMAINID] [int] NOT NULL,
	[KLPolicyOffline] [bit] NULL,
	[KLMASTERPOLICYNUMBER] [varchar](20) NULL,
	[KLGroupName] [nvarchar](200) NULL,
	[KLAgencyName] [nvarchar](200) NULL,
	[KLSalesForceCaseID] [varchar](25) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_claims_klreg_au_id]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_claims_klreg_au_id] ON [dbo].[claims_KLREG_au]
(
	[KLCLAIM] ASC
)
INCLUDE([KLPRODUCT],[KLDISS],[KLDOMAINID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
