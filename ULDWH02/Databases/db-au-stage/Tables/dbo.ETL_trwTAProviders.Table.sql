USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwTAProviders]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwTAProviders](
	[TAProviderID] [numeric](18, 0) NULL,
	[Name] [varchar](50) NULL,
	[CompanyName] [varchar](50) NULL,
	[PanDetailID] [numeric](18, 0) NULL,
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
	[EntityID] [numeric](18, 0) NULL,
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
