USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwAgentBranches]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwAgentBranches](
	[AgentBranchID] [numeric](18, 0) NULL,
	[AgentID] [numeric](18, 0) NULL,
	[Name] [varchar](500) NULL,
	[DateofCreation] [datetime] NULL,
	[ContactPerson] [varchar](50) NULL,
	[Address1] [varchar](500) NULL,
	[Address2] [varchar](500) NULL,
	[City] [varchar](50) NULL,
	[District] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[PinCode] [varchar](10) NULL,
	[Country] [varchar](100) NULL,
	[PhoneNo] [varchar](50) NULL,
	[MobileNo] [varchar](50) NULL,
	[EmailAddress] [varchar](50) NULL,
	[BranchID] [numeric](18, 0) NULL,
	[ImplantEmployeeID] [numeric](18, 0) NULL,
	[AgentEmployeeID] [numeric](18, 0) NULL,
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[BankName] [varchar](500) NULL,
	[BankAddress] [varchar](1000) NULL,
	[BankAccountType] [varchar](50) NULL,
	[BankAccountNo] [varchar](50) NULL,
	[BankMICR] [varchar](50) NULL,
	[BankIFSCCode] [varchar](50) NULL,
	[MarketingExecutiveEmployeeID] [numeric](18, 0) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
