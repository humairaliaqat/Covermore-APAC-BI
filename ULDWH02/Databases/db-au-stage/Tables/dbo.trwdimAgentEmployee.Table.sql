USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimAgentEmployee]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimAgentEmployee](
	[AgentEmployeeSK] [int] IDENTITY(1,1) NOT NULL,
	[AgentEmployeeID] [int] NOT NULL,
	[AgentBranchID] [int] NULL,
	[UserName] [nvarchar](256) NULL,
	[SecurityAnswer] [nvarchar](50) NULL,
	[Name] [nvarchar](500) NULL,
	[PanDetailID] [int] NULL,
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
	[EntityID] [int] NULL,
	[Status] [nvarchar](50) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgentEmployee_AgentEmployeeSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimAgentEmployee_AgentEmployeeSK] ON [dbo].[trwdimAgentEmployee]
(
	[AgentEmployeeSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgentEmployee_AgentBranchID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgentEmployee_AgentBranchID] ON [dbo].[trwdimAgentEmployee]
(
	[AgentBranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgentEmployee_AgentEmployeeID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgentEmployee_AgentEmployeeID] ON [dbo].[trwdimAgentEmployee]
(
	[AgentEmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgentEmployee_EntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgentEmployee_EntityID] ON [dbo].[trwdimAgentEmployee]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimAgentEmployee_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgentEmployee_HashKey] ON [dbo].[trwdimAgentEmployee]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimAgentEmployee_PanDetailID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimAgentEmployee_PanDetailID] ON [dbo].[trwdimAgentEmployee]
(
	[PanDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
