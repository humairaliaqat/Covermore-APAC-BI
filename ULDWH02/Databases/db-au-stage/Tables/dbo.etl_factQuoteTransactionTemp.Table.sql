USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factQuoteTransactionTemp]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factQuoteTransactionTemp](
	[CountryKey] [varchar](2) NOT NULL,
	[QuoteKey] [varchar](30) NULL,
	[PolicyKey] [varchar](41) NULL,
	[PromotionKey] [varchar](41) NULL,
	[OutletSK] [int] NOT NULL,
	[ProductKey] [nvarchar](243) NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[QuoteID] [int] NULL,
	[SessionID] [nvarchar](255) NULL,
	[ConsultantName] [nvarchar](101) NULL,
	[UserName] [nvarchar](100) NULL,
	[CreateDate] [datetime] NULL,
	[CreateTime] [datetime] NULL,
	[YAGOCreateDate] [datetime] NULL,
	[UpdateTime] [datetime] NULL,
	[Area] [nvarchar](50) NULL,
	[Age] [int] NOT NULL,
	[HasEMC] [bit] NOT NULL,
	[Destination] [nvarchar](max) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[isExpo] [bit] NULL,
	[isAgentSpecial] [bit] NULL,
	[PromoCode] [nvarchar](60) NULL,
	[CANXFlag] [bit] NULL,
	[PolicyNo] [varchar](50) NULL,
	[NumberOfChildren] [int] NULL,
	[NumberofAdults] [int] NULL,
	[NumberOfTravellers] [int] NULL,
	[Duration] [int] NULL,
	[isSaved] [bit] NULL,
	[SaveStep] [int] NULL,
	[AgentReference] [nvarchar](100) NULL,
	[QuoteSaveDate] [datetime] NULL,
	[StoreCode] [varchar](10) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[DomainID] [int] NULL,
	[CRMUserName] [nvarchar](100) NULL,
	[DerivedConsultantKey] [nvarchar](162) NULL,
	[AgencyCode] [nvarchar](60) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
