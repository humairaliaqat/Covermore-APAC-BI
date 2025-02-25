USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[trwSellingCostPlan]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwSellingCostPlan](
	[SellingPlanSK] [int] IDENTITY(1,1) NOT NULL,
	[SellingPlanID] [int] NOT NULL,
	[SellingPlan] [nvarchar](500) NULL,
	[SellingPlanShortName] [nvarchar](500) NULL,
	[SellingDayPlan] [bit] NULL,
	[TAPlanTypeID] [int] NULL,
	[PlanType] [nvarchar](100) NULL,
	[TrawellTagOption] [bit] NULL,
	[SellingAnnualPlan] [bit] NULL,
	[SellingPlanStatus] [nvarchar](100) NULL,
	[CostPlanID] [int] NULL,
	[CostPlan] [nvarchar](200) NULL,
	[CostPlanShortName] [nvarchar](200) NULL,
	[InsuranceProviderID] [int] NULL,
	[InsuranceProvider] [nvarchar](100) NULL,
	[CompanyName] [nvarchar](100) NULL,
	[ContactPerson] [nvarchar](100) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[City] [nvarchar](50) NULL,
	[District] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[PinCode] [nvarchar](10) NULL,
	[Country] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[MobileNo] [nvarchar](100) NULL,
	[EmailAddress] [nvarchar](100) NULL,
	[StudentPolicyText] [nvarchar](2000) NULL,
	[AnnualPolicyText] [nvarchar](2000) NULL,
	[NextPolicyNumber] [int] NULL,
	[InsuranceCategoryID] [int] NULL,
	[InsuranceCategory] [nvarchar](200) NULL,
	[MasterPolicyNumber] [nvarchar](100) NULL,
	[CostDayPlan] [bit] NULL,
	[TAProviderID] [int] NULL,
	[TAProvider] [nvarchar](100) NULL,
	[TAPlanID] [int] NULL,
	[PlanName] [nvarchar](100) NULL,
	[TANumber] [nvarchar](100) NULL,
	[VisitingCountryID] [int] NULL,
	[VisitingCountry] [nvarchar](1000) NULL,
	[CostAnnualPlan] [bit] NULL,
	[CostPlanStatus] [nvarchar](100) NULL,
	[EntityID] [int] NULL,
	[Entity] [nvarchar](1000) NULL,
	[EntityType] [nvarchar](100) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_SellingCostPlanSK]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_trwSellingCostPlan_SellingCostPlanSK] ON [dbo].[trwSellingCostPlan]
(
	[SellingPlanSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_EntityID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_EntityID] ON [dbo].[trwSellingCostPlan]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_trwSellingCostPlan_HashKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_HashKey] ON [dbo].[trwSellingCostPlan]
(
	[hashkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_InsuranceCategoryID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_InsuranceCategoryID] ON [dbo].[trwSellingCostPlan]
(
	[InsuranceCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_InsuranceProviderID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_InsuranceProviderID] ON [dbo].[trwSellingCostPlan]
(
	[InsuranceProviderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_SellingCostPlanID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_SellingCostPlanID] ON [dbo].[trwSellingCostPlan]
(
	[SellingPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_TAPlanID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_TAPlanID] ON [dbo].[trwSellingCostPlan]
(
	[TAPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_TAPlanTypeID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_TAPlanTypeID] ON [dbo].[trwSellingCostPlan]
(
	[TAPlanTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_TAProviderID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_TAProviderID] ON [dbo].[trwSellingCostPlan]
(
	[TAProviderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlan_VisitingCountryID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlan_VisitingCountryID] ON [dbo].[trwSellingCostPlan]
(
	[VisitingCountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
