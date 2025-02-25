USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_clstkprods_au]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_clstkprods_au](
	[ID] [int] NOT NULL,
	[CLALPHA] [varchar](7) NULL,
	[AGELOADINGID] [int] NULL,
	[COMM] [float] NULL,
	[LOADING] [float] NULL,
	[ADMINFEE] [money] NOT NULL,
	[MAXADMINFEE] [money] NOT NULL,
	[AVAILABLE] [bit] NOT NULL,
	[CommissionTierId] [varchar](25) NULL,
	[VolumePercentage] [float] NULL
) ON [PRIMARY]
GO
