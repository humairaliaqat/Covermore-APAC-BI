USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwSellingCostPlanTemp]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwSellingCostPlanTemp](
	[SellingPlanID] [int] NULL,
	[SellingPlan] [nvarchar](100) NULL,
	[SellingPlanShortName] [nvarchar](50) NULL,
	[SellingDayPlan] [bit] NULL,
	[TAPlanTypeID] [int] NULL,
	[PlanType] [nvarchar](50) NULL,
	[TrawellTagOption] [bit] NULL,
	[SellingAnnualPlan] [bit] NULL,
	[SellingPlanStatus] [nvarchar](50) NULL,
	[CostPlanID] [int] NULL,
	[CostPlan] [nvarchar](100) NULL,
	[CostPlanShortName] [nvarchar](50) NULL,
	[InsuranceProviderID] [int] NULL,
	[InsuranceProvider] [nvarchar](50) NULL,
	[CompanyName] [nvarchar](50) NULL,
	[ContactPerson] [nvarchar](50) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[City] [nvarchar](50) NULL,
	[District] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[PinCode] [nvarchar](10) NULL,
	[Country] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](50) NULL,
	[MobileNo] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[StudentPolicyText] [nvarchar](1000) NULL,
	[AnnualPolicyText] [nvarchar](1000) NULL,
	[NextPolicyNumber] [int] NULL,
	[InsuranceCategoryID] [int] NULL,
	[InsuranceCategory] [nvarchar](100) NULL,
	[MasterPolicyNumber] [nvarchar](50) NULL,
	[CostDayPlan] [bit] NULL,
	[TAProviderID] [int] NULL,
	[TAProvider] [nvarchar](50) NULL,
	[TAPlanID] [int] NULL,
	[PlanName] [nvarchar](50) NULL,
	[TANumber] [nvarchar](50) NULL,
	[VisitingCountryID] [int] NULL,
	[VisitingCountry] [nvarchar](500) NULL,
	[CostAnnualPlan] [bit] NULL,
	[CostPlanStatus] [nvarchar](50) NULL,
	[EntityID] [int] NULL,
	[Entity] [nvarchar](500) NULL,
	[EntityType] [nvarchar](50) NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_SellingCostPlanID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_trwSellingCostPlanTemp_SellingCostPlanID] ON [dbo].[trwSellingCostPlanTemp]
(
	[SellingPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_EntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlanTemp_EntityID] ON [dbo].[trwSellingCostPlanTemp]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlanTemp_HashKey] ON [dbo].[trwSellingCostPlanTemp]
(
	[hashkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_InsuranceCategoryID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlanTemp_InsuranceCategoryID] ON [dbo].[trwSellingCostPlanTemp]
(
	[InsuranceCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_InsuranceProviderID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlanTemp_InsuranceProviderID] ON [dbo].[trwSellingCostPlanTemp]
(
	[InsuranceProviderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_TAPlanTypeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlanTemp_TAPlanTypeID] ON [dbo].[trwSellingCostPlanTemp]
(
	[TAPlanTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_TAProviderID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlanTemp_TAProviderID] ON [dbo].[trwSellingCostPlanTemp]
(
	[TAProviderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwSellingCostPlanTemp_VisitingCountryID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwSellingCostPlanTemp_VisitingCountryID] ON [dbo].[trwSellingCostPlanTemp]
(
	[VisitingCountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
