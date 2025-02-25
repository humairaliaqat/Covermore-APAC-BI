USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgCampaign]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgCampaign](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CampaignID] [int] NOT NULL,
	[Campaign] [nvarchar](255) NULL,
	[BusinessUnitID] [int] NULL,
	[PathType] [nchar](1) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgCampaign_main]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgCampaign_main] ON [dbo].[cdgCampaign]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgCampaign_id]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgCampaign_id] ON [dbo].[cdgCampaign]
(
	[CampaignID] ASC
)
INCLUDE([Campaign]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
