USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[scrmAccount_UAT]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scrmAccount_UAT](
	[UniqueIdentifier] [varchar](50) NOT NULL,
	[DomainCode] [varchar](2) NOT NULL,
	[CompanyCode] [varchar](3) NOT NULL,
	[GroupCode] [nvarchar](50) NOT NULL,
	[SubGroupCode] [nvarchar](50) NOT NULL,
	[GroupName] [nvarchar](200) NOT NULL,
	[SubGroupName] [nvarchar](200) NOT NULL,
	[AgentName] [nvarchar](200) NOT NULL,
	[AgencyCode] [nvarchar](20) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Branch] [nvarchar](100) NULL,
	[ShippingStreet] [nvarchar](100) NULL,
	[ShippingSuburb] [nvarchar](100) NULL,
	[ShippingState] [nvarchar](100) NULL,
	[ShippingPostCode] [nvarchar](50) NULL,
	[ShippingCountry] [varchar](50) NOT NULL,
	[OfficePhone] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[BillingStreet] [nvarchar](100) NULL,
	[BillingSuburb] [nvarchar](100) NULL,
	[BillingState] [nvarchar](100) NULL,
	[BillingPostCode] [nvarchar](50) NULL,
	[BillingCountry] [varchar](50) NOT NULL,
	[BDM] [nvarchar](100) NULL,
	[AccountManager] [nvarchar](100) NULL,
	[BDMCallFrequency] [nvarchar](50) NULL,
	[AccountCallFrequency] [nvarchar](50) NULL,
	[SalesTier] [nvarchar](100) NULL,
	[OutletType] [varchar](3) NOT NULL,
	[FCArea] [nvarchar](100) NULL,
	[FCNation] [nvarchar](100) NULL,
	[EGMNation] [nvarchar](100) NULL,
	[AgencyGrading] [nvarchar](100) NULL,
	[Title] [nvarchar](100) NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[ManagerEmail] [nvarchar](255) NULL,
	[CCSaleOnly] [nvarchar](50) NULL,
	[PaymentType] [nvarchar](50) NULL,
	[AccountEmail] [nvarchar](255) NULL,
	[SalesSegment] [nvarchar](50) NULL,
	[CommencementDate] [datetime] NULL,
	[CloseDate] [datetime] NULL,
	[PreviousUniqueIdentifier] [nvarchar](50) NULL,
	[AccountType] [varchar](50) NOT NULL,
	[HashKey] [binary](30) NULL,
	[LoadDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[isSynced] [nvarchar](1) NULL,
	[SyncedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
