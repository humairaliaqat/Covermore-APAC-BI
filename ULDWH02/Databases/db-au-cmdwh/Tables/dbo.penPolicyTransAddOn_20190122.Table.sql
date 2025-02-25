USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penPolicyTransAddOn_20190122]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penPolicyTransAddOn_20190122](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddOnText] [nvarchar](500) NULL,
	[CoverIncrease] [money] NULL,
	[GrossPremium] [money] NULL,
	[UnAdjGrossPremium] [money] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransAddOn_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penPolicyTransAddOn_PolicyTransactionKey] ON [dbo].[penPolicyTransAddOn_20190122]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransAddOn_AddOnPrice]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransAddOn_AddOnPrice] ON [dbo].[penPolicyTransAddOn_20190122]
(
	[PolicyTransactionKey] ASC
)
INCLUDE([AddOnGroup],[GrossPremium],[UnAdjGrossPremium]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penPolicyTransAddOn_Price]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penPolicyTransAddOn_Price] ON [dbo].[penPolicyTransAddOn_20190122]
(
	[PolicyTransactionKey] ASC,
	[AddOnGroup] ASC
)
INCLUDE([GrossPremium],[UnAdjGrossPremium]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
