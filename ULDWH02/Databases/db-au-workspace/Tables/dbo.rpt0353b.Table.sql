USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[rpt0353b]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rpt0353b](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](3) NULL,
	[JobErrorID] [int] NULL,
	[JobErrorDescription] [varchar](max) NULL,
	[CreateDateTime] [datetime] NULL,
	[ErrorSource] [varchar](15) NULL,
	[SourceData] [varchar](max) NULL,
	[JobCode] [varchar](50) NULL,
	[JobType] [varchar](50) NULL,
	[JobDesc] [varchar](500) NULL,
	[PolicyImportStatus] [varchar](15) NULL,
	[BusinessUnit] [nvarchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[SellPrice] [money] NULL,
	[PaymentReference] [nvarchar](max) NULL,
	[PaymentMethod] [varchar](8000) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[AlphaCode] [nvarchar](max) NULL,
	[Comment] [nvarchar](1000) NULL,
	[Fixable] [varchar](3) NOT NULL,
	[YesterdayDate] [varchar](10) NULL,
	[CreateDateOnly] [varchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
