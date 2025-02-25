USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTC_PrecedaHeadcount]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_PrecedaHeadcount](
	[Level_1] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[Org_Unit_Description] [varchar](50) NULL,
	[Position_ID] [varchar](50) NULL,
	[Position_Title] [varchar](50) NULL,
	[Reports_To_Position_Title] [varchar](50) NULL,
	[ID_Number] [varchar](50) NULL,
	[First_Name] [varchar](50) NULL,
	[Surname] [varchar](50) NULL,
	[Level_2_Description] [varchar](50) NULL,
	[Hire_Date] [datetime] NULL,
	[Employment_Type_Desc] [varchar](50) NULL,
	[Personnel_Type_Desc] [varchar](50) NULL,
	[Work_Pattern_Description] [varchar](50) NULL,
	[Base_Hours_Amount] [numeric](18, 0) NULL,
	[Monday] [float] NULL,
	[Tuesday] [float] NULL,
	[Wednesday] [float] NULL,
	[Thursday] [float] NULL,
	[Friday] [float] NULL,
	[Saturday] [float] NULL,
	[Sunday] [float] NULL,
	[WorkPatternBreakdown] [varchar](max) NULL,
	[CalcHours]  AS ((((((isnull([Monday],(0))+isnull([Tuesday],(0)))+isnull([Wednesday],(0)))+isnull([Thursday],(0)))+isnull([Friday],(0)))+isnull([Saturday],(0)))+isnull([Sunday],(0)))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
