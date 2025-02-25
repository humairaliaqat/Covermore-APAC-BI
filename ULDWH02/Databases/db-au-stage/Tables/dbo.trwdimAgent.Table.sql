USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimAgent]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimAgent](
	[AgentSK] [int] IDENTITY(1,1) NOT NULL,
	[AgentID] [int] NOT NULL,
	[Name] [nvarchar](500) NULL,
	[CompanyName] [nvarchar](250) NULL,
	[PanDetailID] [int] NULL,
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
	[CentralisedInvoicing] [bit] NULL,
	[CommissionType] [nvarchar](50) NULL,
	[AgentTypeID] [int] NULL,
	[BankName] [nvarchar](500) NULL,
	[BankAddress] [nvarchar](1000) NULL,
	[BankAccountType] [nvarchar](50) NULL,
	[BankAccountNo] [nvarchar](50) NULL,
	[BankMICR] [nvarchar](50) NULL,
	[BankIFSCCode] [nvarchar](50) NULL,
	[DateofBirth] [datetime] NULL,
	[AnniversaryDate] [datetime] NULL,
	[MarketingExecutiveEmployeeID] [int] NULL,
	[DateofCreation] [datetime] NULL,
	[AgentEmployeeID] [int] NULL,
	[EntityID] [int] NULL,
	[MasterNumber] [nvarchar](50) NULL,
	[SpouseName] [nvarchar](50) NULL,
	[SpouseDOB] [datetime] NULL,
	[Kid1] [nvarchar](250) NULL,
	[Kid1DOB] [datetime] NULL,
	[Kid2] [nvarchar](500) NULL,
	[Kid2DOB] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
	[ExtraComments] [ntext] NULL,
	[NoPANAgent] [bit] NULL,
	[Reference] [nvarchar](1000) NULL,
	[TypeOfAgent] [nvarchar](100) NULL,
	[CreditAmount] [numeric](18, 2) NULL,
	[LogoPath] [nvarchar](2000) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgent_AgentSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimAgent_AgentSK] ON [dbo].[trwdimAgent]
(
	[AgentSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgent_AgentEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgent_AgentEmployeeID] ON [dbo].[trwdimAgent]
(
	[AgentEmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgent_AgentID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgent_AgentID] ON [dbo].[trwdimAgent]
(
	[AgentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgent_AgentTypeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgent_AgentTypeID] ON [dbo].[trwdimAgent]
(
	[AgentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimAgent_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgent_HashKey] ON [dbo].[trwdimAgent]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgent_MarketingExecutiveEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgent_MarketingExecutiveEmployeeID] ON [dbo].[trwdimAgent]
(
	[MarketingExecutiveEmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgent_PanDetailID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgent_PanDetailID] ON [dbo].[trwdimAgent]
(
	[PanDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
