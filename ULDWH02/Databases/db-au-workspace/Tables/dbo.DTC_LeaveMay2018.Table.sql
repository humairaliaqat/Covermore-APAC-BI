USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTC_LeaveMay2018]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_LeaveMay2018](
	[Level1] [float] NULL,
	[Status] [nvarchar](255) NULL,
	[IDNumber] [float] NOT NULL,
	[FullName] [nvarchar](255) NULL,
	[LeaveType] [nvarchar](255) NULL,
	[LeaveTypeDescripion] [nvarchar](255) NULL,
	[LeaveStartDate] [datetime] NULL,
	[LeaveEndDate] [datetime] NULL,
	[HoursTaken] [float] NULL,
	[LeaveReasonDescription] [nvarchar](255) NULL
) ON [PRIMARY]
GO
