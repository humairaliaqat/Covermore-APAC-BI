USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblFreeDays_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblFreeDays_au](
	[FreeDaysID] [int] NOT NULL,
	[TravellerID] [int] NULL,
	[FreeDays] [int] NULL,
	[FreeDaysLoad] [money] NULL,
	[IssueDate] [datetime] NULL
) ON [PRIMARY]
GO
