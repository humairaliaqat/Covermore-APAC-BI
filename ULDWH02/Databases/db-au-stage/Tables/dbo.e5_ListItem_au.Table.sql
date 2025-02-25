USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_ListItem_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_ListItem_au](
	[List_Id] [int] NOT NULL,
	[Id] [int] NOT NULL,
	[Parent_Id] [int] NULL,
	[Code] [nvarchar](32) NOT NULL,
	[Name] [nvarchar](400) NOT NULL,
	[SortOrder] [int] NOT NULL
) ON [PRIMARY]
GO
