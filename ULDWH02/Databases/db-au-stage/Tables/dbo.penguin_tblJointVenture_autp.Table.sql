USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblJointVenture_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblJointVenture_autp](
	[JointVentureId] [int] NOT NULL,
	[Name] [varchar](55) NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[SortOrder] [int] NULL
) ON [PRIMARY]
GO
