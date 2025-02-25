USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_product_au]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_product_au](
	[ProductID] [int] NULL,
	[ProductCode] [varchar](10) NULL,
	[ProductYear] [varchar](6) NULL,
	[Renewable] [bit] NOT NULL,
	[DisplayFlag] [bit] NOT NULL,
	[PeriodStart] [datetime] NULL,
	[PeriodEnd] [datetime] NULL,
	[DefaultComm] [real] NULL
) ON [PRIMARY]
GO
