USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwAgentEmployeeTemp]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwAgentEmployeeTemp](
	[AgentEmployeeID] [int] NULL,
	[UserName] [nvarchar](256) NULL,
	[SecurityAnswer] [nvarchar](50) NULL,
	[AgentEmployee] [nvarchar](500) NULL,
	[BankName] [nvarchar](500) NULL,
	[BankAddress] [nvarchar](1000) NULL,
	[BankAccountType] [nvarchar](50) NULL,
	[BankAccountNo] [nvarchar](50) NULL,
	[BankMICR] [nvarchar](50) NULL,
	[BankIFSCCode] [nvarchar](50) NULL,
	[DateofBirth] [datetime] NULL,
	[AnniversaryDate] [datetime] NULL,
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
	[AgentEmployeeStatus] [nvarchar](50) NULL,
	[AgentBranchID] [int] NULL,
	[AgentBranch] [nvarchar](500) NULL,
	[AgentBranchDateofCreation] [datetime] NULL,
	[ContactPerson] [nvarchar](50) NULL,
	[AgentID] [int] NULL,
	[Agent] [nvarchar](500) NULL,
	[CompanyName] [nvarchar](250) NULL,
	[CentralisedInvoicing] [bit] NULL,
	[CommissionType] [nvarchar](50) NULL,
	[AgentType] [nvarchar](50) NULL,
	[AgentMarketingExecutiveEmployeeID] [int] NULL,
	[AgentMarketingExecutive] [nvarchar](500) NULL,
	[AgentBranchME] [nvarchar](500) NULL,
	[AgentBranchMECode] [nvarchar](50) NULL,
	[AgentDateofCreation] [datetime] NULL,
	[MasterNumber] [nvarchar](50) NULL,
	[SpouseName] [nvarchar](50) NULL,
	[SpouseDOB] [datetime] NULL,
	[Kid1] [nvarchar](250) NULL,
	[Kid1DOB] [datetime] NULL,
	[Kid2] [nvarchar](500) NULL,
	[Kid2DOB] [datetime] NULL,
	[AgentStatus] [nvarchar](50) NULL,
	[ExtraComments] [nvarchar](max) NULL,
	[NoPANAgent] [bit] NULL,
	[Reference] [nvarchar](1000) NULL,
	[TypeOfAgent] [nvarchar](100) NULL,
	[CreditAmount] [numeric](18, 2) NULL,
	[EntityID] [int] NULL,
	[Entity] [nvarchar](500) NULL,
	[EntityType] [nvarchar](50) NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_trwAgentEmployeeTemp_AgentEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_trwAgentEmployeeTemp_AgentEmployeeID] ON [dbo].[trwAgentEmployeeTemp]
(
	[AgentEmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwAgentEmployeeTemp_AgentBranchID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwAgentEmployeeTemp_AgentBranchID] ON [dbo].[trwAgentEmployeeTemp]
(
	[AgentBranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwAgentEmployeeTemp_AgentMarketingExecutiveEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwAgentEmployeeTemp_AgentMarketingExecutiveEmployeeID] ON [dbo].[trwAgentEmployeeTemp]
(
	[AgentMarketingExecutiveEmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwAgentEmployeeTemp_EntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwAgentEmployeeTemp_EntityID] ON [dbo].[trwAgentEmployeeTemp]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_trwAgentEmployeeTemp_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwAgentEmployeeTemp_HashKey] ON [dbo].[trwAgentEmployeeTemp]
(
	[hashkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
