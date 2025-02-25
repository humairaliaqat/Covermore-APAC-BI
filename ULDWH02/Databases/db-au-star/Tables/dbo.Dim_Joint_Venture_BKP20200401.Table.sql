USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Joint_Venture_BKP20200401]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Joint_Venture_BKP20200401](
	[Joint_Venture_SK] [int] IDENTITY(0,1) NOT NULL,
	[Joint_Venture_Category_Code] [varchar](50) NOT NULL,
	[Joint_Venture_Category_Desc] [varchar](200) NULL,
	[Joint_Venture_Code] [varchar](50) NOT NULL,
	[Joint_Venture_Desc] [varchar](200) NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
	[Distribution_Type_Code] [varchar](50) NOT NULL,
	[Distribution_Type_Desc] [varchar](200) NULL,
	[Super_Group_Code] [varchar](50) NOT NULL,
	[Super_Group_Desc] [varchar](200) NULL
) ON [PRIMARY]
GO
