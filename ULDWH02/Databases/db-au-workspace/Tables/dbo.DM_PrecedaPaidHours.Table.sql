USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DM_PrecedaPaidHours]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_PrecedaPaidHours](
	[Company] [float] NULL,
	[Status] [nvarchar](255) NULL,
	[EmpID] [float] NULL,
	[FullName] [nvarchar](255) NULL,
	[PositionTitle] [nvarchar](255) NULL,
	[OrgUnitTitle] [nvarchar](255) NULL,
	[Code] [float] NULL,
	[Description] [nvarchar](255) NULL,
	[HireDate] [datetime] NULL,
	[TermDate] [nvarchar](255) NULL,
	[PeriodEnd] [datetime] NULL,
	[Code1] [float] NULL,
	[Description1] [nvarchar](255) NULL,
	[Hours/Units] [float] NULL
) ON [PRIMARY]
GO
