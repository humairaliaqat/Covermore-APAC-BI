USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Trip_Duration]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Trip_Duration](
	[Trip_Duration_SK] [int] IDENTITY(0,1) NOT NULL,
	[Trip_Duration_Days] [int] NOT NULL,
	[Trip_Duration_Band_Desc] [varchar](200) NOT NULL,
	[Trip_Duration_Band_Min] [int] NULL,
	[Trip_Duration_Band_Max] [int] NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
 CONSTRAINT [Dim_Trip_Duration_PK] PRIMARY KEY CLUSTERED 
(
	[Trip_Duration_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
