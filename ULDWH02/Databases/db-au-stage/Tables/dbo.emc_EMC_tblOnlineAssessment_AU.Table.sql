USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblOnlineAssessment_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblOnlineAssessment_AU](
	[OA_ID] [int] NOT NULL,
	[ClientID] [int] NULL,
	[OnlineAssessment] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
