USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyTraveller_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyTraveller_ukcm](
	[ID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[QuoteCustomerID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[IsAdult] [bit] NULL,
	[AdultCharge] [numeric](18, 5) NULL,
	[IsPrimary] [bit] NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[PostCode] [varchar](50) NULL,
	[Suburb] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[HomePhone] [varchar](50) NULL,
	[WorkPhone] [varchar](50) NULL,
	[MobilePhone] [varchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[OptFurtherContact] [bit] NULL,
	[MemberNumber] [nvarchar](25) NULL,
	[EmcCoverLimit] [numeric](18, 2) NULL,
	[MarketingConsent] [bit] NULL,
	[Gender] [nchar](1) NULL,
	[PersonalIdentifierID] [int] NULL,
	[PersonalIdentifierValue] [nvarchar](500) NULL,
	[StateOfArrival] [varchar](100) NULL,
	[MemberTypeId] [int] NULL,
	[TicketType] [nvarchar](50) NULL,
	[VelocityNumber] [nvarchar](50) NULL,
	[TaxNumber] [nvarchar](100) NULL,
	[City] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyTraveller_ukcm_PolicyID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicyTraveller_ukcm_PolicyID] ON [dbo].[penguin_tblPolicyTraveller_ukcm]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyTraveller_ukcm_ID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblPolicyTraveller_ukcm_ID] ON [dbo].[penguin_tblPolicyTraveller_ukcm]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
