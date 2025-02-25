USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_Absenteeism_201903]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_Absenteeism_201903](
	[Level1] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[IDNumber] [varchar](50) NULL,
	[FullName] [varchar](50) NULL,
	[LeaveType] [varchar](50) NULL,
	[LeaveTypeDescripion] [varchar](50) NULL,
	[LeaveStartDate] [varchar](50) NULL,
	[LeaveEndDate] [varchar](50) NULL,
	[HoursTaken] [varchar](50) NULL,
	[LeaveReason] [varchar](50) NULL,
	[LeaveReasonDescription] [varchar](50) NULL,
	[DatePaid] [varchar](50) NULL
) ON [PRIMARY]
GO
