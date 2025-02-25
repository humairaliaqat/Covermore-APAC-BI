USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_Site_Info]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_Site_Info](
	[Site ID] [float] NULL,
	[Site Name] [nvarchar](255) NULL,
	[Effective Date] [datetime] NULL,
	[Weekly Cost] [money] NULL,
	[# of Rooms] [float] NULL,
	[Monday] [float] NULL,
	[Tuesday] [float] NULL,
	[Wednesday] [float] NULL,
	[Thursday] [float] NULL,
	[Friday] [float] NULL,
	[Saturday] [float] NULL,
	[Sunday] [float] NULL
) ON [PRIMARY]
GO
