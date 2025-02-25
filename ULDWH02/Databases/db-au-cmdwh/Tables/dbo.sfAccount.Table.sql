USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[sfAccount]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sfAccount](
	[AccountID] [nvarchar](18) NULL,
	[AccountName] [nvarchar](255) NULL,
	[GroupCode] [nvarchar](10) NULL,
	[GroupName] [nvarchar](255) NULL,
	[SubGroupCode] [nvarchar](10) NULL,
	[SubGroupName] [nvarchar](255) NULL,
	[AlphaCode] [nvarchar](10) NULL,
	[OutletName] [nvarchar](255) NULL,
	[AgencyID] [nvarchar](30) NULL,
	[OutletType] [nvarchar](255) NULL,
	[TradingStatus] [nvarchar](40) NULL,
	[AgencyManager] [nvarchar](1300) NULL,
	[ContactTitle] [nvarchar](20) NULL,
	[ContactFirstName] [nvarchar](80) NULL,
	[ContactLastName] [nvarchar](80) NULL,
	[ContactAddress] [nvarchar](255) NULL,
	[ContactCity] [nvarchar](40) NULL,
	[ContactState] [nvarchar](80) NULL,
	[ContactPostcode] [nvarchar](20) NULL,
	[ContactCountry] [nvarchar](80) NULL,
	[ContactEmail] [nvarchar](80) NULL,
	[AccountsEmail] [nvarchar](80) NULL,
	[CompanyCode] [nvarchar](255) NULL,
	[DomainCode] [nvarchar](255) NULL,
	[BDMName] [nvarchar](255) NULL,
	[BDMCallFrequency] [nvarchar](3) NULL,
	[AccountManager] [nvarchar](255) NULL,
	[AMCallFrequency] [nvarchar](3) NULL,
	[Email] [nvarchar](80) NULL,
	[Phone] [nvarchar](40) NULL,
	[Fax] [nvarchar](40) NULL,
	[FCNation] [nvarchar](255) NULL,
	[FCArea] [nvarchar](255) NULL,
	[Industry] [nvarchar](40) NULL,
	[IsDeleted] [bit] NULL,
	[LastVisited] [datetime] NULL,
	[LastActivityDate] [date] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedBy] [nvarchar](121) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[PreviousAlpha] [bit] NULL,
	[Owner] [nvarchar](121) NULL,
	[PaymentType] [nvarchar](255) NULL,
	[QuadrantPotential] [nvarchar](255) NULL,
	[RecordType] [nvarchar](80) NULL,
	[SalesQuadrant] [nvarchar](255) NULL,
	[SalesSegement] [nvarchar](255) NULL,
	[SalesTier] [nvarchar](255) NULL,
	[VisitDueDate] [date] NULL,
	[VisitStatus] [nvarchar](1300) NULL,
	[LastAccountActivityDate] [datetime] NULL,
	[LastAccountActivityUser] [nvarchar](121) NULL,
	[Quadrant] [nvarchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_AccountID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_sfAccount_AccountID] ON [dbo].[sfAccount]
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_AccountName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_AccountName] ON [dbo].[sfAccount]
(
	[AccountName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_AgencyID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_AgencyID] ON [dbo].[sfAccount]
(
	[AgencyID] ASC
)
INCLUDE([QuadrantPotential],[SalesQuadrant],[SalesSegement],[SalesTier],[Quadrant],[AccountID],[AlphaCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_AlphaCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_AlphaCode] ON [dbo].[sfAccount]
(
	[AlphaCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_BDMName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_BDMName] ON [dbo].[sfAccount]
(
	[BDMName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_CompanyCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_CompanyCode] ON [dbo].[sfAccount]
(
	[CompanyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_DomainCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_DomainCode] ON [dbo].[sfAccount]
(
	[DomainCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_GroupName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_GroupName] ON [dbo].[sfAccount]
(
	[GroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_OutletType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_OutletType] ON [dbo].[sfAccount]
(
	[OutletType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_Owner]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_Owner] ON [dbo].[sfAccount]
(
	[Owner] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_RecordType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_RecordType] ON [dbo].[sfAccount]
(
	[RecordType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_sfAccount_SubGroupName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_sfAccount_SubGroupName] ON [dbo].[sfAccount]
(
	[SubGroupName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
