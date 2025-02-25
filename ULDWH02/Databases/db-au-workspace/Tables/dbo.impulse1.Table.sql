USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[impulse1]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impulse1](
	[BusinessUnitID] [int] NULL,
	[transactiontime] [datetime] NULL,
	[ImpressionID] [bigint] NULL,
	[CampaignSessionID] [bigint] NULL
) ON [PRIMARY]
GO
