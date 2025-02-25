USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[BENESTAR_Paid_201905]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BENESTAR_Paid_201905](
	[IDNumber] [float] NULL,
	[FullName] [nvarchar](255) NULL,
	[PositionTitle] [nvarchar](255) NULL,
	[DepartmentDescription] [nvarchar](255) NULL,
	[BaseHoursamount] [float] NULL,
	[WorkPatternCode] [float] NULL,
	[WorkPatternDescription] [nvarchar](255) NULL,
	[Hiredate] [datetime] NULL,
	[TermDate] [datetime] NULL
) ON [PRIMARY]
GO
