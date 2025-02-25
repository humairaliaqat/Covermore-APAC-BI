USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_Quote_Addon_Premium_AU_AG_ALLJV]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_Quote_Addon_Premium_AU_AG_ALLJV](
	[sessiontoken] [uniqueidentifier] NOT NULL,
	[LineTitle] [varchar](255) NULL,
	[LineCategoryCode] [varchar](255) NULL,
	[LineGrossPrice] [varchar](255) NULL,
	[LineDiscountPercent] [varchar](255) NULL,
	[LineDiscountedGross] [varchar](255) NULL,
	[LineActualGross] [varchar](255) NULL,
	[LineFormattedActualGross] [varchar](255) NULL,
	[QuoteTransactionDateTime] [datetime] NULL,
	[SESSIONID] [int] NULL,
	[GCLID] [varchar](500) NULL,
	[GA_Client_ID] [varchar](500) NULL,
	[Link_ID] [varchar](500) NULL,
	[Quote_Reference_ID] [varchar](500) NULL,
	[Quote_Transaction_ID] [varchar](500) NULL
) ON [PRIMARY]
GO
