USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_backupPrecedaLeave20181205]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_backupPrecedaLeave20181205](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[IDNumber] [smallint] NULL,
	[LeaveType] [varchar](20) NULL,
	[LeaveStart] [datetime] NULL,
	[LeaveEnd] [datetime] NULL,
	[DatePaid] [datetime] NULL,
	[Hours] [real] NULL,
	[LeaveReason] [varchar](50) NULL
) ON [PRIMARY]
GO
