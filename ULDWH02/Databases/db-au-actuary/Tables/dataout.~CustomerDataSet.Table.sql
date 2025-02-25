USE [db-au-actuary]
GO
/****** Object:  Table [dataout].[~CustomerDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dataout].[~CustomerDataSet](
	[PolicyTravellerKey] [varchar](41) NULL,
	[PolicyKey] [varchar](41) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[Age] [int] NULL,
	[DOB] [datetime] NULL,
	[isPrimary] [bit] NULL,
	[isAdult] [bit] NULL,
	[AdultCharge] [numeric](18, 5) NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[Suburb] [nvarchar](50) NULL,
	[Postcode] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[HomePhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[OptFurtherContact] [bit] NULL,
	[MarketingConsent] [bit] NULL,
	[StateOfArrival] [varchar](100) NULL,
	[LoadDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_CustomerDataSet_PolicyTravellerKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_CustomerDataSet_PolicyTravellerKey] ON [dataout].[~CustomerDataSet]
(
	[PolicyTravellerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_CustomerDataSet_PolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_CustomerDataSet_PolicyKey] ON [dataout].[~CustomerDataSet]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
