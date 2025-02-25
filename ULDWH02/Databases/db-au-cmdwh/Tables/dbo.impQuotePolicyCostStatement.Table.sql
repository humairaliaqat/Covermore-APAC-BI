USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impQuotePolicyCostStatement]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impQuotePolicyCostStatement](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[QuoteIDKey] [nvarchar](50) NULL,
	[ordinal] [int] NULL,
	[lineTitle] [nvarchar](50) NULL,
	[lineGrossPrice] [money] NULL,
	[lineActualGross] [money] NULL,
	[lineCategoryCode] [nvarchar](50) NULL,
	[lineDiscountPercent] [numeric](10, 5) NULL,
	[lineDiscountedGross] [money] NULL,
	[lineFormattedActualGross] [nvarchar](50) NULL,
	[CreateBatchID] [int] NULL,
 CONSTRAINT [pk_impQuotePolicyCostStatement] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impQuotePolicyCostStatement_QuoteIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impQuotePolicyCostStatement_QuoteIDKey] ON [dbo].[impQuotePolicyCostStatement]
(
	[QuoteIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
