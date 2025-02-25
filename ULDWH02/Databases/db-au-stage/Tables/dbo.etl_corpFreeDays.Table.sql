USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpFreeDays]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpFreeDays](
	[CountryKey] [varchar](2) NOT NULL,
	[FreeDaysKey] [varchar](33) NULL,
	[TravellerKey] [varchar](33) NULL,
	[FreeDaysID] [int] NOT NULL,
	[TravellerID] [int] NULL,
	[FreeDays] [int] NULL,
	[FreeDaysLoad] [money] NULL,
	[IssueDate] [datetime] NULL
) ON [PRIMARY]
GO
