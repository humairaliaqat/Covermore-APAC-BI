USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_Products_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_Products_UK](
	[CompID] [smallint] NOT NULL,
	[ProdCode] [varchar](1) NOT NULL,
	[Product] [varchar](25) NULL
) ON [PRIMARY]
GO
