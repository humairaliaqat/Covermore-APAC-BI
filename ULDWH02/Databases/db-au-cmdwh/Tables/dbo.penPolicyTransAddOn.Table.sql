USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransAddOn]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransAddOn](
	[BIrowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddOnText] [nvarchar](500) NULL,
	[CoverIncrease] [money] NULL,
	[GrossPremium] [money] NULL,
	[UnAdjGrossPremium] [money] NULL,
	[AddonCount] [int] NULL,
	[PolicyKey] [varchar](41) NULL,
	[Commission] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penPolicyTransAddOn_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTransAddOn_BIRowID] ON [dbo].[penPolicyTransAddOn]
(
	[BIrowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransAddOn_AddOnPrice]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransAddOn_AddOnPrice] ON [dbo].[penPolicyTransAddOn]
(
	[PolicyTransactionKey] ASC,
	[AddOnGroup] ASC
)
INCLUDE([GrossPremium],[UnAdjGrossPremium],[AddonCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransAddOn_PolicyKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransAddOn_PolicyKey] ON [dbo].[penPolicyTransAddOn]
(
	[PolicyKey] ASC,
	[AddOnGroup] ASC
)
INCLUDE([PolicyTransactionKey],[GrossPremium],[UnAdjGrossPremium],[AddonCount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
