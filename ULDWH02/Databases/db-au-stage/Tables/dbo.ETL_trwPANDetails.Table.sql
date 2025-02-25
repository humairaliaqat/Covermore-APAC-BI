USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwPANDetails]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwPANDetails](
	[PANDetailID] [numeric](18, 0) NULL,
	[PANNo] [varchar](50) NULL,
	[PANType] [varchar](50) NULL,
	[DeducteeName] [varchar](500) NULL,
	[AddressName] [varchar](500) NULL,
	[AddressFlat] [varchar](500) NULL,
	[AddressBuilding] [varchar](500) NULL,
	[AddressStreet] [varchar](500) NULL,
	[AddressArea] [varchar](500) NULL,
	[City] [varchar](50) NULL,
	[District] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[PinCode] [varchar](10) NULL,
	[Country] [varchar](100) NULL,
	[PhoneNo] [varchar](50) NULL,
	[MobileNo] [varchar](50) NULL,
	[EmailAddress] [varchar](50) NULL,
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
