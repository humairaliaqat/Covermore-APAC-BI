USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_AUDIT_KLREG_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_AUDIT_KLREG_au](
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_ACTION] [varchar](10) NULL,
	[KLCLAIM] [int] NULL,
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
	[KLGROUPID] [int] NULL,
	[KLGroupCode] [varchar](20) NULL,
	[CultureCode] [nvarchar](10) NULL,
	[KLDOMAINID] [int] NULL,
	[KLPolicyOffline] [bit] NULL,
	[KLMASTERPOLICYNUMBER] [varchar](20) NULL,
	[KLGroupName] [nvarchar](200) NULL,
	[KLAgencyName] [nvarchar](200) NULL,
	[KLSalesForceCaseID] [varchar](25) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
