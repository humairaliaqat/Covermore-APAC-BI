USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimAddonGroups_test]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimAddonGroups_test](
	[AddonGroupsSK] [bigint] IDENTITY(1,1) NOT NULL,
	[AddonGroups] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
