USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblTaxType_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblTaxType_ukcm](
	[TaxTypeId] [int] NOT NULL,
	[DomainId] [int] NULL,
	[TaxType] [nvarchar](50) NULL,
	[IncludedInNet] [bit] NOT NULL,
	[ApplicationOrder] [int] NOT NULL
) ON [PRIMARY]
GO
