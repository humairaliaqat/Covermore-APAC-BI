USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_ILLNESSESS_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_ILLNESSESS_AU](
	[CODE] [varchar](1) NULL,
	[DESCRIPT] [varchar](15) NULL,
	[Counter] [int] NOT NULL
) ON [PRIMARY]
GO
