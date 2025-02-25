USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ETL032_recon_policycube]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL032_recon_policycube](
	[Country] [varchar](30) NULL,
	[JV] [varchar](30) NULL,
	[Alpha] [varchar](30) NULL,
	[Month] [date] NULL,
	[Sell Price] [money] NULL,
	[Premium] [money] NULL,
	[GST] [money] NULL,
	[Policy Count] [int] NULL,
	[Quote Count] [int] NULL
) ON [PRIMARY]
GO
