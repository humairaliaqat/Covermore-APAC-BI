USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_Groups_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_Groups_AU](
	[Code] [varchar](2) NOT NULL,
	[Descript] [varchar](25) NULL,
	[Compid] [smallint] NULL
) ON [PRIMARY]
GO
