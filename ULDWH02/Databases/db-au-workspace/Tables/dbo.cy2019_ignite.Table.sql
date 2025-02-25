USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cy2019_ignite]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cy2019_ignite](
	[OutletAlphaKey] [varchar](50) NULL,
	[Month] [date] NULL,
	[Target] [decimal](18, 8) NULL,
	[Budget] [decimal](18, 8) NULL
) ON [PRIMARY]
GO
