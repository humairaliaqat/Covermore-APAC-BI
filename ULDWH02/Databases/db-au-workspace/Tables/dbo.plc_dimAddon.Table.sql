USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[plc_dimAddon]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[plc_dimAddon](
	[AddonSK] [bigint] IDENTITY(1,1) NOT NULL,
	[AddonKey] [varchar](50) NOT NULL,
	[AddonName] [nvarchar](100) NULL,
	[AddonDescription] [nvarchar](200) NULL,
	[AddonGroup] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_plcdimAddon_AddonSK]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_plcdimAddon_AddonSK] ON [dbo].[plc_dimAddon]
(
	[AddonSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_plcdimAddon_AddonKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_plcdimAddon_AddonKey] ON [dbo].[plc_dimAddon]
(
	[AddonKey] ASC
)
INCLUDE([AddonName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
