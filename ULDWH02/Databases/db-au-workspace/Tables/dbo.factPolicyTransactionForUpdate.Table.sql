USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[factPolicyTransactionForUpdate]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factPolicyTransactionForUpdate](
	[BIRowID] [bigint] NOT NULL,
	[PolicyCount] [int] NULL,
	[DestinationSK] [int] NOT NULL,
	[PostingDate] [datetime] NULL,
	[Country] [nvarchar](10) NOT NULL,
	[SuperGroupName] [nvarchar](255) NULL,
	[GroupName] [nvarchar](50) NULL,
	[GroupCode] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[Channel] [nvarchar](100) NULL,
	[PolicyKey] [nvarchar](50) NOT NULL,
	[PolicyNumber] [varchar](50) NOT NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[TripType] [nvarchar](50) NULL,
	[IssueDateNoTime] [datetime] NOT NULL,
	[PrimaryCountryGroup] [varchar](14) NOT NULL,
	[PurchasePath] [nvarchar](50) NULL,
	[PurchasePathGroup] [varchar](12) NOT NULL,
	[newDestinationSK] [int] NULL,
	[newDestination] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
