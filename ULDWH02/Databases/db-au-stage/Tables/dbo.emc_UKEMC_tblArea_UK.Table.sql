USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblArea_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblArea_UK](
	[AreaId] [int] NOT NULL,
	[Area] [varchar](75) NOT NULL,
	[Compid] [int] NULL
) ON [PRIMARY]
GO
