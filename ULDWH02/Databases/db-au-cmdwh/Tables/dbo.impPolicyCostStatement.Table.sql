USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impPolicyCostStatement]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impPolicyCostStatement](
	[BIRowID] [bigint] IDENTITY(0,1) NOT NULL,
	[PolicyIDKey] [nvarchar](50) NULL,
	[ordinal] [int] NULL,
	[lineTitle] [nvarchar](100) NULL,
	[lineGrossPrice] [money] NULL,
	[lineActualGross] [money] NULL,
	[lineCategoryCode] [nvarchar](100) NULL,
	[lineDiscountPercent] [money] NULL,
	[lineDiscountedGross] [money] NULL,
	[lineFormattedActualGross] [nvarchar](100) NULL,
	[batchID] [int] NULL,
 CONSTRAINT [pk_impPolicyCostStatement] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_impPolicyCostStatement_PolicyIDKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_impPolicyCostStatement_PolicyIDKey] ON [dbo].[impPolicyCostStatement]
(
	[PolicyIDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
