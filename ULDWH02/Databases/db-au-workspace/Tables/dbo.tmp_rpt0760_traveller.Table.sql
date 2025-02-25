USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rpt0760_traveller]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rpt0760_traveller](
	[PolicyKey] [varchar](900) NULL,
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
	[PaymentType] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_rpt0760_PolicyKey]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_rpt0760_PolicyKey] ON [dbo].[tmp_rpt0760_traveller]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
