USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_factQuoteTransaction]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_factQuoteTransaction](
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[OutletSK] [int] NOT NULL,
	[PolicySK] [int] NOT NULL,
	[ConsultantSK] [int] NOT NULL,
	[AreaSK] [int] NOT NULL,
	[DestinationSK] [int] NOT NULL,
	[DurationSK] [int] NOT NULL,
	[AgeBandSK] [int] NOT NULL,
	[PromotionSK] [int] NOT NULL,
	[ProductSK] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[SessionID] [nvarchar](255) NULL,
	[CreateDate] [datetime] NULL,
	[CreateTime] [datetime] NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[isExpo] [varchar](1) NOT NULL,
	[isAgentSpecial] [varchar](1) NOT NULL,
	[isCancellation] [varchar](1) NOT NULL,
	[isSaved] [varchar](1) NOT NULL,
	[SaveStep] [int] NULL,
	[hasEMC] [varchar](1) NOT NULL,
	[AgentReference] [nvarchar](100) NULL,
	[QuoteSaveDate] [datetime] NULL,
	[QuoteCount] [int] NULL,
	[SavedQuoteCount] [int] NULL,
	[SessionQuoteCount] [int] NULL,
	[ChildrenCount] [int] NULL,
	[AdultsCount] [int] NULL,
	[TravellersCount] [int] NULL
) ON [PRIMARY]
GO
