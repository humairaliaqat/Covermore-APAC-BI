USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCWorkerHireTermination]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCWorkerHireTermination](
	[EmployeeID] [float] NULL,
	[CommencedDate] [datetime] NULL,
	[TerminatedDate] [datetime] NULL
) ON [PRIMARY]
GO
