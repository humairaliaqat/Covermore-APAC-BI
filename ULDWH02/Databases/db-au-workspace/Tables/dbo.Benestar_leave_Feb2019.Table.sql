USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_leave_Feb2019]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_leave_Feb2019](
	[Level1] [float] NULL,
	[Status] [nvarchar](255) NULL,
	[IDNumber] [float] NULL,
	[FullName] [nvarchar](255) NULL,
	[LeaveType] [nvarchar](255) NULL,
	[LeaveTypeDescripion] [nvarchar](255) NULL,
	[LeaveStartDate] [datetime] NULL,
	[LeaveEndDate] [datetime] NULL,
	[HoursTaken] [float] NULL,
	[LeaveReason] [nvarchar](255) NULL,
	[LeaveReasonDescription] [nvarchar](255) NULL,
	[DatePaid] [datetime] NULL
) ON [PRIMARY]
GO
