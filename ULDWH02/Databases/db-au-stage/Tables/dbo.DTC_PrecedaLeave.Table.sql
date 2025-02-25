USE [db-au-stage]
GO
/****** Object:  Table [dbo].[DTC_PrecedaLeave]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTC_PrecedaLeave](
	[Status] [varchar](50) NULL,
	[ID_Number] [varchar](50) NULL,
	[Full_Name] [varchar](50) NULL,
	[Full_Title] [varchar](100) NULL,
	[Level_1] [varchar](50) NULL,
	[Organisation_Unit_Id] [varchar](50) NULL,
	[Leave_Type_Descripion] [varchar](50) NULL,
	[Leave_Start_Date] [datetime] NULL,
	[Leave_End_Date] [datetime] NULL,
	[Hours_Taken] [varchar](50) NULL,
	[Leave_Reason_Description] [varchar](50) NULL,
	[Base_Hours_Amount] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Department_Description] [varchar](50) NULL
) ON [PRIMARY]
GO
