USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[EmployeeData]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeData](
	[Status] [nvarchar](50) NULL,
	[EmpID] [int] NULL,
	[Gender] [nvarchar](5) NULL,
	[Age] [int] NULL,
	[Tenure_Years] [int] NULL,
	[EmploymentType] [nvarchar](100) NULL,
	[PersonnelType] [nvarchar](100) NULL,
	[WeeklyHours] [float] NULL,
	[Country] [nvarchar](100) NULL,
	[Division] [nvarchar](200) NULL,
	[Department] [nvarchar](200) NULL,
	[TerminationType] [nvarchar](100) NULL
) ON [PRIMARY]
GO
