USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_product_uk]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_product_uk](
	[ProductID] [int] NOT NULL,
	[ProductCode] [nvarchar](10) NULL,
	[ProductYear] [nvarchar](6) NULL,
	[Renewable] [bit] NULL,
	[DisplayFlag] [bit] NULL,
	[PeriodStart] [datetime] NULL,
	[PeriodEnd] [datetime] NULL,
	[DefaultComm] [real] NULL,
	[ProductDescription] [varchar](150) NULL
) ON [PRIMARY]
GO
