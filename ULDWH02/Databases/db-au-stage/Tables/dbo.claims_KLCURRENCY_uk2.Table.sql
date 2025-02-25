USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_KLCURRENCY_uk2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_KLCURRENCY_uk2](
	[ID] [int] NOT NULL,
	[Code] [varchar](3) NULL,
	[Country] [varchar](255) NULL,
	[Currency] [varchar](255) NULL,
	[Symbol] [varchar](255) NULL,
	[Subdivision] [varchar](255) NULL,
	[ISO4217Code] [varchar](255) NULL,
	[Regime] [varchar](255) NULL,
	[Active] [bit] NULL,
	[Name] [varchar](100) NULL
) ON [PRIMARY]
GO
