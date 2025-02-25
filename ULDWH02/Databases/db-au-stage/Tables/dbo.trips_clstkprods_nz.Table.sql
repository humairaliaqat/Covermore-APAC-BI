USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_clstkprods_nz]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_clstkprods_nz](
	[ID] [int] NOT NULL,
	[CLALPHA] [varchar](7) NULL,
	[AGELOADINGID] [int] NULL,
	[COMM] [float] NULL,
	[LOADING] [float] NULL,
	[EMCLOADING] [float] NULL,
	[EMCCOMM] [float] NULL,
	[ADDONLOADING] [float] NULL,
	[ADDONCOMM] [float] NULL
) ON [PRIMARY]
GO
