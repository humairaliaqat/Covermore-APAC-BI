USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[recon_ods]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[recon_ods](
	[SUNPeriod] [int] NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[JVCode] [nvarchar](50) NULL,
	[JVDescription] [nvarchar](200) NULL,
	[FinanceProductCode] [nvarchar](12) NULL,
	[PolicyCount] [int] NULL,
	[Premium] [money] NULL,
	[Commission] [money] NULL
) ON [PRIMARY]
GO
