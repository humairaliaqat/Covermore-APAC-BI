USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penOutletSalesTarget]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penOutletSalesTarget](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[OutletSalesTargetKey] [varchar](71) NULL,
	[OutletKey] [varchar](71) NULL,
	[OutletAlphaKey] [nvarchar](61) NULL,
	[OutletSalesTargetID] [int] NOT NULL,
	[Month] [int] NULL,
	[GrossSellPriceTarget] [money] NULL
) ON [PRIMARY]
GO
