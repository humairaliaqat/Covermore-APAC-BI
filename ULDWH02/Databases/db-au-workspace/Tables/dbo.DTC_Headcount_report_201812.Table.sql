USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DTC_Headcount_report_201812]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_Headcount_report_201812](
	[Level1] [float] NULL,
	[Status] [nvarchar](255) NULL,
	[OrgUnitDescription] [nvarchar](255) NULL,
	[PositionID] [nvarchar](255) NULL,
	[PositionTitle] [nvarchar](255) NULL,
	[ReportsToPositionTitle] [nvarchar](255) NULL,
	[IDNumber] [float] NULL,
	[FirstName] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[Level2Description] [nvarchar](255) NULL,
	[HireDate] [datetime] NULL,
	[EmploymentTypeDesc] [nvarchar](255) NULL,
	[PersonnelTypeDesc] [nvarchar](255) NULL,
	[WorkPatternDescription] [nvarchar](255) NULL,
	[BaseHoursAmount] [float] NULL,
	[State] [nvarchar](255) NULL
) ON [PRIMARY]
GO
