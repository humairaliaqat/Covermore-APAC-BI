USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_freemium]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_freemium](
	[QuoteID] [varchar](8000) NULL,
	[CustomerID] [varchar](8000) NULL,
	[isPrimary] [varchar](1) NOT NULL,
	[Age] [varchar](8000) NULL,
	[isAdult] [int] NOT NULL,
	[hasEMC] [int] NOT NULL,
	[Title] [varchar](8000) NULL,
	[FirstName] [varchar](8000) NULL,
	[LastName] [varchar](8000) NULL,
	[DOB] [varchar](8000) NULL,
	[Street] [varchar](8000) NULL,
	[Suburb] [varchar](8000) NULL,
	[State] [varchar](8000) NULL,
	[Postcode] [varchar](8000) NULL,
	[Country] [varchar](8000) NULL,
	[Phone1] [varchar](8000) NULL,
	[Phone2] [varchar](8000) NULL,
	[EmailAddress] [varchar](8000) NULL,
	[OptFurtherContact] [int] NOT NULL,
	[MemberNumber] [varchar](8000) NULL,
	[SessionID] [varchar](8000) NULL,
	[AgencyCode] [varchar](8000) NULL,
	[StoreCode] [varchar](1) NOT NULL,
	[ConsultantName] [varchar](8000) NULL,
	[UserName] [varchar](8000) NULL,
	[CreatDate] [varchar](8000) NULL,
	[Area] [varchar](8000) NULL,
	[Destination] [varchar](8000) NULL,
	[DepartureDate] [varchar](8000) NULL,
	[ReturnDate] [varchar](8000) NULL,
	[Duration] [varchar](8000) NULL,
	[isExpo] [varchar](1) NOT NULL,
	[isAgentSpecial] [varchar](1) NOT NULL,
	[PromoCode] [nvarchar](4000) NULL,
	[isCANX] [int] NOT NULL,
	[PolicyNumber] [varchar](8000) NULL,
	[ChildrenCount] [int] NULL,
	[AdultsCount] [int] NULL,
	[TravellersCount] [int] NULL,
	[isSaved] [int] NOT NULL,
	[SaveStep] [varchar](1) NOT NULL,
	[QuoteSavedDate] [varchar](8000) NULL,
	[ProductCode] [varchar](8000) NULL,
	[QuotedPrice] [varchar](8000) NULL
) ON [PRIMARY]
GO
