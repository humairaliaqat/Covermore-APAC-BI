USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_UKEMC_tblOnlineAssessment_UK]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_UKEMC_tblOnlineAssessment_UK](
	[OA_ID] [int] NOT NULL,
	[ClientID] [int] NULL,
	[OnlineAssessment] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
