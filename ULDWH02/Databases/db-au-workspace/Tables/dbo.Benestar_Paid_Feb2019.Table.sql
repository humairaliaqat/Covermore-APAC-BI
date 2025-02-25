USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_Paid_Feb2019]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_Paid_Feb2019](
	[Company] [float] NULL,
	[Status] [nvarchar](255) NULL,
	[IDNumber] [float] NULL,
	[FullName] [nvarchar](255) NULL,
	[PositionTitle] [nvarchar](255) NULL,
	[DepartmentDescription] [nvarchar](255) NULL,
	[HireDate] [datetime] NULL,
	[TermDate] [nvarchar](255) NULL,
	[PeriodEndingDate] [datetime] NULL,
	[PayDate] [datetime] NULL,
	[HoursorA/DCode] [float] NULL,
	[HoursorA/DCodeDesc] [nvarchar](255) NULL,
	[NumberofUnits] [float] NULL
) ON [PRIMARY]
GO
