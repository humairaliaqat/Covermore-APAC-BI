USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_Headcount_Nov]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_Headcount_Nov](
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
	[AdjServDate] [datetime] NULL,
	[EmploymentTypeDesc] [nvarchar](255) NULL,
	[PersonnelTypeDesc] [nvarchar](255) NULL,
	[WorkPatternDescription] [nvarchar](255) NULL,
	[BaseHoursAmount] [float] NULL,
	[FTE] [float] NULL,
	[Gender] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL
) ON [PRIMARY]
GO
