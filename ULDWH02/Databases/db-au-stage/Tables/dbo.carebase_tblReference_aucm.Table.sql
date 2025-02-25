USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblReference_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblReference_aucm](
	[id] [int] NOT NULL,
	[Entity] [varchar](50) NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Description] [nvarchar](250) NOT NULL,
	[isActive] [bit] NOT NULL,
	[SortOrder] [numeric](2, 0) NULL
) ON [PRIMARY]
GO
