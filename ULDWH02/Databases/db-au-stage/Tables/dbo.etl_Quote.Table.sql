USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_Quote]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_Quote](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[QuoteKey] [varchar](30) NULL,
	[QuoteCountryKey] [varchar](30) NULL,
	[PolicyKey] [varchar](41) NULL,
	[AgencySKey] [bigint] NULL,
	[AgencyKey] [varchar](10) NULL,
	[QuoteID] [int] NULL,
	[SessionID] [varchar](255) NOT NULL,
	[AgencyCode] [varchar](7) NULL,
	[StoreCode] [varchar](10) NULL,
	[ConsultantName] [varchar](50) NULL,
	[UserName] [varchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[CreateTime] [datetime] NULL,
	[Area] [varchar](50) NULL,
	[Destination] [varchar](100) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[IsExpo] [bit] NULL,
	[IsAgentSpecial] [bit] NULL,
	[PromoCode] [varchar](60) NULL,
	[CanxFlag] [bit] NULL,
	[PolicyNo] [int] NULL,
	[NumberOfChildren] [int] NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfPersons] [int] NULL,
	[Duration] [int] NULL,
	[IsSaved] [bit] NULL,
	[SaveStep] [int] NULL,
	[AgentReference] [varchar](100) NULL,
	[UpdateTime] [datetime] NULL,
	[QuotedPrice] [numeric](10, 4) NULL
) ON [PRIMARY]
GO
