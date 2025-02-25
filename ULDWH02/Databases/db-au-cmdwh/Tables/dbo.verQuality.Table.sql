USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[verQuality]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[verQuality](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[QualityKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[SupervisorEmployeeKey] [int] NOT NULL,
	[OrganisationKey] [int] NOT NULL,
	[QualityStartTime] [datetime] NOT NULL,
	[QualityEndTime] [datetime] NULL,
	[QualityStartTimeGMT] [datetime] NOT NULL,
	[QualityEndTimeGMT] [datetime] NULL,
	[QualityScore] [int] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_verQuality_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_verQuality_BIRowID] ON [dbo].[verQuality]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_verQuality_Datetime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_verQuality_Datetime] ON [dbo].[verQuality]
(
	[QualityStartTime] ASC,
	[QualityEndTime] ASC
)
INCLUDE([EmployeeKey],[OrganisationKey],[QualityStartTimeGMT],[QualityEndTimeGMT],[QualityScore]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
