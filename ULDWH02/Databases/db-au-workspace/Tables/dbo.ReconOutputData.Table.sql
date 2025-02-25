USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ReconOutputData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReconOutputData](
	[Metric] [nvarchar](50) NULL,
	[Penguin_Count] [int] NULL,
	[Dwh_Count] [int] NULL,
	[ReportStartDate] [datetime] NULL,
	[ReportRunDate] [datetime] NULL,
	[Rundate] [datetime] NULL
) ON [PRIMARY]
GO
