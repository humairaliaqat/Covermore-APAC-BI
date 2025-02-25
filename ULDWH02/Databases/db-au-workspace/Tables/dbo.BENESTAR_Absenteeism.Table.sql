USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[BENESTAR_Absenteeism]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BENESTAR_Absenteeism](
	[IDNumber] [float] NULL,
	[Fullname] [nvarchar](255) NULL,
	[LeaveType] [nvarchar](255) NULL,
	[LeaveTypeDescription] [nvarchar](255) NULL,
	[LeaveStartDate] [datetime] NULL,
	[LeaveEndDate] [datetime] NULL,
	[hoursTaken] [float] NULL,
	[LeaveReasonDescription] [nvarchar](255) NULL,
	[DatePaid] [datetime] NULL
) ON [PRIMARY]
GO
