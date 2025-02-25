USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrAttrition]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrAttrition](
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
/****** Object:  Index [idx_usrAttrition_EmpID]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_usrAttrition_EmpID] ON [dbo].[usrAttrition]
(
	[EmpID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrAttrition_EmployeeName]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrAttrition_EmployeeName] ON [dbo].[usrAttrition]
(
	[EmployeeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20180914-123607]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180914-123607] ON [dbo].[usrAttrition]
(
	[DOB] ASC,
	[EmployeeName] ASC
)
INCLUDE([EmpID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
