USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimAddonGroup_test]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimAddonGroup_test](
	[AddonGroupSK] [bigint] IDENTITY(1,1) NOT NULL,
	[AddonGroup] [varchar](100) NULL
) ON [PRIMARY]
GO
