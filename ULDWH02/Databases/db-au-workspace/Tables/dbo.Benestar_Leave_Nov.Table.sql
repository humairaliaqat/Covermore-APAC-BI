USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_Leave_Nov]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_Leave_Nov](
	[Status] [nvarchar](255) NULL,
	[IDNumber] [float] NULL,
	[FullName] [nvarchar](255) NULL,
	[FullTitle] [nvarchar](255) NULL,
	[Level1] [float] NULL,
	[OrganisationUnitId] [float] NULL,
	[LeaveType] [nvarchar](255) NULL,
	[LeaveTypeDescripion] [nvarchar](255) NULL,
	[LeaveStartDate] [datetime] NULL,
	[LeaveEndDate] [datetime] NULL,
	[HoursTaken] [float] NULL,
	[LeaveReason] [nvarchar](255) NULL,
	[LeaveReasonDescription] [nvarchar](255) NULL,
	[BaseHoursAmount] [float] NULL,
	[Department] [float] NULL,
	[DepartmentDescription] [nvarchar](255) NULL
) ON [PRIMARY]
GO
