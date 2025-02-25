USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Quote_Data_BreakDown_PlanDrop]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Quote_Data_BreakDown_PlanDrop](
	[Lead_Number] [int] NULL,
	[GCLID] [nvarchar](500) NULL,
	[GA_Client_ID] [nvarchar](500) NULL,
	[Link_ID] [nvarchar](500) NULL,
	[Session_ID] [int] NULL,
	[Age] [nvarchar](500) NULL,
	[Destination] [nvarchar](500) NULL,
	[Region_List] [nvarchar](500) NULL,
	[Quote_Date] [datetime2](7) NULL,
	[Trip_Start] [datetime2](7) NULL,
	[Trip_end] [datetime2](7) NULL,
	[Promotional_Factor] [nvarchar](500) NULL,
	[Excess] [nvarchar](500) NULL,
	[Plan_Type] [nvarchar](500) NULL,
	[Trip_Type] [nvarchar](500) NULL,
	[Premium] [nvarchar](500) NULL,
	[Agency_Code] [nvarchar](500) NULL,
	[Agency_Name] [nvarchar](500) NULL,
	[Brand] [nvarchar](500) NULL,
	[Channel_Type] [nvarchar](500) NULL,
	[Session_Token] [nvarchar](500) NULL
) ON [PRIMARY]
GO
