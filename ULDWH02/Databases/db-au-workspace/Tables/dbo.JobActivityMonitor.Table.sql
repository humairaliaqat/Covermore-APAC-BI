USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[JobActivityMonitor]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobActivityMonitor](
	[job_name] [nvarchar](128) NULL,
	[instance_id] [int] NULL,
	[step_name] [nvarchar](128) NULL,
	[run_status] [nvarchar](50) NULL,
	[run_date] [date] NULL,
	[run_time] [time](7) NULL,
	[run_duration_sec] [int] NULL,
	[Ma12] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[JobActivityMonitor]
(
	[job_name] ASC,
	[run_date] DESC,
	[run_time] DESC
)
INCLUDE([run_status],[run_duration_sec],[instance_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idxd]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idxd] ON [dbo].[JobActivityMonitor]
(
	[run_date] ASC
)
INCLUDE([job_name],[run_status],[run_duration_sec],[instance_id],[step_name],[run_time],[Ma12]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
