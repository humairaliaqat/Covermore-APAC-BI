USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_agencysubgroup_nz]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_agencysubgroup_nz](
	[CLGROUP] [varchar](2) NOT NULL,
	[SUBGRCODE] [varchar](2) NOT NULL,
	[DESCRIPTION] [varchar](50) NULL,
	[ID] [int] NOT NULL
) ON [PRIMARY]
GO
