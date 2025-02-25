USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impQuoteTravellerPrice]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impQuoteTravellerPrice](
	[BIRowID] [bigint] IDENTITY(0,1) NOT NULL,
	[QuoteIDKey] [nvarchar](50) NULL,
	[Identifier] [nvarchar](50) NULL,
	[priceGross] [money] NULL,
	[priceBaseNet] [numeric](10, 5) NULL,
	[priceIsDiscount] [bit] NULL,
	[priceDisplayPrice] [money] NULL,
	[priceUnroundedGross] [numeric](10, 5) NULL,
	[CreateBatchID] [int] NULL,
 CONSTRAINT [pk_impQuoteTravellerPrice] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
