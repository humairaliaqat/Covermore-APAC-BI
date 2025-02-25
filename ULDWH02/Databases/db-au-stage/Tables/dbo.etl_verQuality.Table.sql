USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_verQuality]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_verQuality](
	[QualityKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[SupervisorEmployeeKey] [int] NOT NULL,
	[OrganisationKey] [int] NOT NULL,
	[QualityStartTime] [datetime] NULL,
	[QualityEndTime] [datetime] NULL,
	[QualityStartTimeGMT] [datetime] NOT NULL,
	[QualityEndTimeGMT] [datetime] NULL,
	[QualityScore] [int] NOT NULL
) ON [PRIMARY]
GO
