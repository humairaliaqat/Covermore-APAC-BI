USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblQuoteAddon_aucm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblQuoteAddon_aucm](
	[ID] [int] NOT NULL,
	[QuoteCustomerID] [int] NOT NULL,
	[AddOnID] [int] NULL,
	[AddOnValueID] [int] NULL,
	[AddOnName] [nvarchar](50) NOT NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[Description] [nvarchar](500) NOT NULL,
	[ValueDescription] [nvarchar](200) NOT NULL,
	[ValueText] [nvarchar](500) NULL,
	[PremiumIncrease] [numeric](18, 5) NOT NULL,
	[CoverIncrease] [money] NOT NULL,
	[IsPercentage] [bit] NOT NULL,
	[IsRateCardBased] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[IsNotSelected] [bit] NOT NULL,
	[QuotePlanID] [int] NOT NULL
) ON [PRIMARY]
GO
