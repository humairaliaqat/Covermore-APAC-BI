USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[BenestarLeave_2018]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BenestarLeave_2018](
	[Status] [nvarchar](255) NULL,
	[IDNumber] [float] NULL,
	[FullName] [nvarchar](255) NULL,
	[Level1] [float] NULL,
	[LeaveType] [nvarchar](255) NULL,
	[LeaveTypeDescripion] [nvarchar](255) NULL,
	[LeaveStartDate] [datetime] NULL,
	[LeaveEndDate] [datetime] NULL,
	[DatePaid] [datetime] NULL,
	[UnitsTaken] [float] NULL,
	[LeaveReason] [nvarchar](255) NULL,
	[LeaveReasonDescription] [nvarchar](255) NULL
) ON [PRIMARY]
GO
