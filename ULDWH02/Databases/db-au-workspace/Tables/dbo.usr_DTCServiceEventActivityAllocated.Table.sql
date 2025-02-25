USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCServiceEventActivityAllocated]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCServiceEventActivityAllocated](
	[ServiceEventActivitySK] [int] NOT NULL,
	[AllocatedUser] [int] NULL,
	[AttendeeReason] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_ServiceEventSK]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [IDX_ServiceEventSK] ON [dbo].[usr_DTCServiceEventActivityAllocated]
(
	[ServiceEventActivitySK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
