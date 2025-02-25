USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwEmployeeTemp]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwEmployeeTemp](
	[EmployeeID] [int] NULL,
	[EmployeeCode] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[ReportingManager] [nvarchar](500) NULL,
	[UserName] [nvarchar](256) NULL,
	[SecurityAnswer] [nvarchar](50) NULL,
	[DateofJoining] [datetime] NULL,
	[DateofBirth] [datetime] NULL,
	[AnniversaryDate] [datetime] NULL,
	[SalaryGrossSalary] [numeric](18, 0) NULL,
	[SalaryConveyance] [numeric](18, 0) NULL,
	[SalaryMobileExpenses] [numeric](18, 0) NULL,
	[SalaryPFContribution] [numeric](18, 0) NULL,
	[SalaryBonus] [numeric](18, 0) NULL,
	[EmailAddress] [nvarchar](100) NULL,
	[Status] [nvarchar](50) NULL,
	[DesignationID] [int] NULL,
	[Designation] [nvarchar](50) NULL,
	[SeqNo] [int] NULL,
	[EmployeeIncentiveStructureCPercent] [numeric](18, 2) NULL,
	[DepartmentID] [int] NULL,
	[Department] [nvarchar](50) NULL,
	[BranchID] [int] NULL,
	[Branch] [nvarchar](50) NULL,
	[DOC] [datetime] NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[City] [nvarchar](50) NULL,
	[District] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[PinCode] [nvarchar](10) NULL,
	[Country] [nvarchar](100) NULL,
	[BillingName] [nvarchar](50) NULL,
	[BranManager] [nvarchar](152) NULL,
	[MaxDiscount] [numeric](18, 2) NULL,
	[AreaID] [int] NULL,
	[Area] [nvarchar](50) NULL,
	[AreaManager] [nvarchar](255) NULL,
	[RegionID] [int] NULL,
	[Region] [nvarchar](50) NULL,
	[RegionManager] [nvarchar](255) NULL,
	[EntityID] [int] NULL,
	[Entity] [nvarchar](500) NULL,
	[EntityType] [nvarchar](50) NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwEmployeeTemp_EmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_trwEmployeeTemp_EmployeeID] ON [dbo].[trwEmployeeTemp]
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwEmployeeTemp_BranchID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwEmployeeTemp_BranchID] ON [dbo].[trwEmployeeTemp]
(
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwEmployeeTemp_DepartmentID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwEmployeeTemp_DepartmentID] ON [dbo].[trwEmployeeTemp]
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwEmployeeTemp_DesignationID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwEmployeeTemp_DesignationID] ON [dbo].[trwEmployeeTemp]
(
	[DesignationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwEmployeeTemp_EntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwEmployeeTemp_EntityID] ON [dbo].[trwEmployeeTemp]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_trwEmployeeTemp_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwEmployeeTemp_HashKey] ON [dbo].[trwEmployeeTemp]
(
	[hashkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwEmployeeTemp_RegionID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwEmployeeTemp_RegionID] ON [dbo].[trwEmployeeTemp]
(
	[RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
