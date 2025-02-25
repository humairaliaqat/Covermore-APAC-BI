USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimAddonGroups]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimAddonGroups](
	[AddonGroupsSK] [bigint] IDENTITY(1,1) NOT NULL,
	[AddonGroups] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx_dimAddonGroups]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_dimAddonGroups] ON [dbo].[dimAddonGroups]
(
	[AddonGroupsSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
