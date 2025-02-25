USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblSubCompanies_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblSubCompanies_UK](
	[SubCompid] [int] NOT NULL,
	[Compid] [smallint] NOT NULL,
	[SubCompCode] [varchar](50) NULL,
	[SubCompDesc] [varchar](250) NULL,
	[active] [int] NULL,
	[isWeb] [bit] NOT NULL,
	[Premium] [numeric](10, 5) NULL,
	[GstPerc] [numeric](10, 5) NULL
) ON [PRIMARY]
GO
