USE [db-au-stage]
GO
/****** Object:  Table [dbo].[CDG_Quote_Addon_Premium_AU_AG]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CDG_Quote_Addon_Premium_AU_AG](
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
/****** Object:  Index [NonClusteredIndex-20241208-145535]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20241208-145535] ON [dbo].[CDG_Quote_Addon_Premium_AU_AG]
(
	[sessiontoken] ASC,
	[SESSIONID] ASC
)
INCLUDE([GCLID],[GA_Client_ID],[Link_ID],[Quote_Reference_ID],[Quote_Transaction_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
