USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpExcessDiscRate]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpExcessDiscRate](
	[CountryKey] [varchar](2) NOT NULL,
	[ExcessDiscRateKey] [varchar](10) NULL,
	[ExcessDiscRateID] [int] NOT NULL,
	[ExcessAmount] [money] NULL,
	[DiscountRate] [real] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY]
GO
