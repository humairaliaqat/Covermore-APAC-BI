USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwBranches]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwBranches](
	[Name] [varchar](50) NULL,
	[ManagerEmployeeID] [numeric](18, 0) NULL,
	[EntityID] [numeric](18, 0) NULL,
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[BranchID] [numeric](18, 0) NULL,
	[DOC] [datetime] NULL,
	[Address1] [varchar](500) NULL,
	[Address2] [varchar](500) NULL,
	[City] [varchar](50) NULL,
	[District] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[PinCode] [varchar](10) NULL,
	[Country] [varchar](100) NULL,
	[BillingName] [varchar](50) NULL,
	[Logo] [varchar](500) NULL,
	[MaxDiscount] [numeric](18, 2) NULL,
	[AreaID] [numeric](18, 0) NULL,
	[MasterNumber] [varchar](50) NULL,
	[InvoiceBankName] [varchar](500) NULL,
	[AccountNo] [varchar](200) NULL,
	[IFSCCode] [varchar](200) NULL,
	[AccountType] [varchar](200) NULL,
	[bankcity] [varchar](200) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
