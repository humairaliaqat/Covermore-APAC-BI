USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblStandardTerms_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblStandardTerms_UK](
	[ST_ID] [smallint] NOT NULL,
	[NoteTypeID] [smallint] NULL,
	[StandardTerm] [varchar](255) NULL
) ON [PRIMARY]
GO
