USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[recon_actuary]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[recon_actuary](
	[SUNPeriod] [int] NULL,
	[CountryKey] [varchar](2) NULL,
	[JVCode] [nvarchar](20) NULL,
	[JVDescription] [nvarchar](100) NULL,
	[FinanceProductCode] [nvarchar](50) NULL,
	[PolicyCount] [int] NULL,
	[Premium] [float] NULL,
	[Commission] [money] NULL
) ON [PRIMARY]
GO
