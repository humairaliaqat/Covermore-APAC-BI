USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblMedicalExtraQuestionDetails_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblMedicalExtraQuestionDetails_UK](
	[ExtraQidDts] [int] NOT NULL,
	[ClientId] [int] NULL,
	[QId] [tinyint] NULL,
	[QVal] [bit] NULL,
	[RXTypeID] [tinyint] NULL
) ON [PRIMARY]
GO
