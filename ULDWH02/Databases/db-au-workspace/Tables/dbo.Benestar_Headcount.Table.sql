USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Benestar_Headcount]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Benestar_Headcount](
	[Status] [nvarchar](255) NULL,
	[ID_Number] [float] NULL,
	[Position_ID] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[Full_Title] [nvarchar](255) NULL,
	[Base_Hours_Amount] [float] NULL,
	[FTE] [float] NULL,
	[Level_1] [float] NULL,
	[Level_1_Description] [nvarchar](255) NULL,
	[Level_2] [nvarchar](255) NULL,
	[Level_2_Description] [nvarchar](255) NULL,
	[Level_3] [nvarchar](255) NULL,
	[Level_3_Description] [nvarchar](255) NULL,
	[Level_4] [float] NULL,
	[Level_4_Description] [nvarchar](255) NULL,
	[Level_5] [nvarchar](255) NULL,
	[Level_5_Description] [nvarchar](255) NULL,
	[Epicor_Segment_2] [float] NULL,
	[Account_Description] [nvarchar](255) NULL,
	[Department] [float] NULL,
	[Epicor_Segment_3] [nvarchar](255) NULL,
	[Department_Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
