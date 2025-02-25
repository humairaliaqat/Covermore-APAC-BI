USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usrServiceEventActivityAllocated]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrServiceEventActivityAllocated](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServiceEventActivitySK] [bigint] NULL,
	[AllocatedUser] [bigint] NULL,
	[AttendeeReason] [varchar](250) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrServiceEventActivityAllocated_ServiceEventActivitySK]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrServiceEventActivityAllocated_ServiceEventActivitySK] ON [dbo].[usrServiceEventActivityAllocated]
(
	[ServiceEventActivitySK] ASC
)
INCLUDE([AllocatedUser],[AttendeeReason]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
