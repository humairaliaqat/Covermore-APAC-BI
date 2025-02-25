USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ETL032_recon_starpolicy]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL032_recon_starpolicy](
	[Country] [nvarchar](10) NOT NULL,
	[Alpha] [nvarchar](20) NOT NULL,
	[JV] [nvarchar](20) NOT NULL,
	[Month] [datetime] NULL,
	[Premium] [float] NULL,
	[Sell Price] [float] NULL,
	[GST] [float] NULL,
	[Policy Count] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_alpha]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_alpha] ON [dbo].[ETL032_recon_starpolicy]
(
	[Country] ASC,
	[Alpha] ASC,
	[Month] ASC
)
INCLUDE([JV],[Premium],[Sell Price],[GST],[Policy Count]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_jv]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_jv] ON [dbo].[ETL032_recon_starpolicy]
(
	[JV] ASC,
	[Month] ASC
)
INCLUDE([Premium],[Sell Price],[GST],[Policy Count]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
