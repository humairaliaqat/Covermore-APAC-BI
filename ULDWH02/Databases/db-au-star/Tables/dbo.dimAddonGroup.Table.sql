USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimAddonGroup]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimAddonGroup](
	[AddonGroupSK] [bigint] IDENTITY(1,1) NOT NULL,
	[AddonGroup] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_dimAddonGroup]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_dimAddonGroup] ON [dbo].[dimAddonGroup]
(
	[AddonGroupSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimAddonGroup_AddonGroup]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_dimAddonGroup_AddonGroup] ON [dbo].[dimAddonGroup]
(
	[AddonGroup] ASC
)
INCLUDE([AddonGroupSK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
