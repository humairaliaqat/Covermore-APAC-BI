USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_bdmexternal_my]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_bdmexternal_my](
	[BDMId] [int] NOT NULL,
	[BDMName] [varchar](40) NULL,
	[CRMUserId] [int] NULL,
	[InUseFlag] [int] NULL,
	[State] [varchar](10) NULL
) ON [PRIMARY]
GO
