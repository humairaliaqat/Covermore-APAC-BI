USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblTaxRegion_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblTaxRegion_uscm](
	[TaxId] [int] NULL,
	[RegionId] [int] NULL,
	[Rate] [numeric](18, 5) NULL
) ON [PRIMARY]
GO
