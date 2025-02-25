USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpExcessDiscRate]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpExcessDiscRate](
	[CountryKey] [varchar](2) NOT NULL,
	[ExcessDiscRateKey] [varchar](10) NULL,
	[ExcessDiscRateID] [int] NOT NULL,
	[ExcessAmount] [money] NULL,
	[DiscountRate] [real] NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpExcessDiscRate_CountryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpExcessDiscRate_CountryKey] ON [dbo].[corpExcessDiscRate]
(
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
