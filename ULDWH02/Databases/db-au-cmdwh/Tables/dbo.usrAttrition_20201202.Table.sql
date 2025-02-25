USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrAttrition_20201202]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrAttrition_20201202](
	[Status] [nvarchar](50) NULL,
	[EmpID] [int] NULL,
	[Level1] [nvarchar](50) NULL,
	[EmployeeName] [nvarchar](200) NULL,
	[Gender] [nvarchar](5) NULL,
	[DOB] [datetime] NULL,
	[JobTitle] [nvarchar](255) NULL,
	[SeniorityLevel] [nvarchar](100) NULL,
	[EmploymentType] [nvarchar](100) NULL,
	[PersonnelType] [nvarchar](100) NULL,
	[WeeklyHours] [float] NULL,
	[FTE] [float] NULL,
	[HireDate] [datetime] NULL,
	[TerminationDate] [datetime] NULL,
	[Country] [nvarchar](100) NULL,
	[Division] [nvarchar](200) NULL,
	[DepartmentName] [nvarchar](200) NULL,
	[LeaveType] [nvarchar](100) NULL,
	[HashKey] [binary](30) NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[State] [nvarchar](200) NULL
) ON [PRIMARY]
GO
