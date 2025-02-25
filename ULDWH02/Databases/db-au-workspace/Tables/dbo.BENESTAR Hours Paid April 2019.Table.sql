USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[BENESTAR Hours Paid April 2019]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BENESTAR Hours Paid April 2019](
	[Level1Code] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[IDNumber] [varchar](50) NULL,
	[FullName] [varchar](50) NULL,
	[PositionTitle] [varchar](50) NULL,
	[BaseHoursAmount] [varchar](50) NULL,
	[WorkPatternCode] [varchar](50) NULL,
	[WorkPatternDescription] [varchar](50) NULL,
	[DepartmentDescription] [varchar](50) NULL,
	[HireDate] [varchar](50) NULL,
	[TermDate] [datetime] NULL,
	[PeriodEndingDate] [datetime] NULL,
	[PayDate] [datetime] NULL,
	[HoursorA DCode] [varchar](50) NULL,
	[HoursorA DCodeDesc] [varchar](50) NULL,
	[NumberofUnits] [varchar](50) NULL
) ON [PRIMARY]
GO
