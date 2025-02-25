USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[rpt0760_traveller]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rpt0760_traveller](
	[SuperGroup] [nvarchar](255) NULL,
	[IssueDate] [varchar](10) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PrimaryDestination] [nvarchar](max) NULL,
	[DepartureDate] [varchar](10) NULL,
	[ReturnDate] [varchar](10) NULL,
	[isPrimary] [varchar](30) NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [varchar](10) NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[Postcode] [nvarchar](50) NULL,
	[Suburb] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[PlanType] [nvarchar](50) NULL,
	[ProductClassification] [nvarchar](100) NULL,
	[PrimaryTravellerCount] [varchar](30) NULL,
	[NonPrimaryTravellerCount] [varchar](30) NULL,
	[PaymentType] [varchar](50) NULL,
	[PlanningPeriod] [varchar](12) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
