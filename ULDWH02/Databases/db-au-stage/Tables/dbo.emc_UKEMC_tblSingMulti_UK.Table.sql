USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblSingMulti_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblSingMulti_UK](
	[SingMultiID] [tinyint] NOT NULL,
	[SingMulti] [varchar](20) NULL,
	[SortOrder] [int] NULL
) ON [PRIMARY]
GO
