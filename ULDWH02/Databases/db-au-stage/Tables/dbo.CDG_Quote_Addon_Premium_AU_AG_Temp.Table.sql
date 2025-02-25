USE [db-au-stage]
GO
/****** Object:  Table [dbo].[CDG_Quote_Addon_Premium_AU_AG_Temp]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CDG_Quote_Addon_Premium_AU_AG_Temp](
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
	[Quote_Reference_ID] [nvarchar](500) NULL,
	[Quote_Transaction_ID] [nvarchar](500) NULL,
	[GCLID] [nvarchar](500) NULL,
	[GA_Client_ID] [nvarchar](500) NULL,
	[Link_ID] [nvarchar](500) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20241118-180608]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20241118-180608] ON [dbo].[CDG_Quote_Addon_Premium_AU_AG_Temp]
(
	[sessiontoken] ASC
)
INCLUDE([LineTitle],[LineCategoryCode],[LineGrossPrice]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
