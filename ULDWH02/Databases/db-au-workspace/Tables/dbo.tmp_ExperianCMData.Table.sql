USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_ExperianCMData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_ExperianCMData](
	[PolicyKey] [varchar](900) NULL,
	[SuperGroup] [varchar](250) NULL,
	[IssueDate] [varchar](50) NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PrimaryDestination] [varchar](250) NULL,
	[DepartureDate] [varchar](50) NULL,
	[ReturnDate] [varchar](50) NULL,
	[isPrimary] [varchar](50) NULL,
	[Title] [varchar](250) NULL,
	[FirstName] [varchar](250) NULL,
	[LastName] [varchar](250) NULL,
	[DOB] [varchar](50) NULL,
	[AddressLine1] [varchar](250) NULL,
	[AddressLine2] [varchar](250) NULL,
	[Postcode] [varchar](50) NULL,
	[Suburb] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [varchar](250) NULL,
	[PlanType] [varchar](250) NULL,
	[ProductClassification] [varchar](250) NULL,
	[PrimaryTravellerCount] [varchar](50) NULL,
	[NonPrimaryTravellerCount] [varchar](50) NULL,
	[PaymentType] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ExperianData_PolicyKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_ExperianData_PolicyKey] ON [dbo].[tmp_ExperianCMData]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
