USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblSubCompanies_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblSubCompanies_AU](
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
/****** Object:  Index [idx_emc_EMC_tblSubCompanies_AU_Compid]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblSubCompanies_AU_Compid] ON [dbo].[emc_EMC_tblSubCompanies_AU]
(
	[Compid] ASC
)
INCLUDE([SubCompid],[SubCompCode]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
