USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Age_Band]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Age_Band](
	[Age_Band_SK] [int] IDENTITY(0,1) NOT NULL,
	[Age_Band_Code] [varchar](50) NOT NULL,
	[Age_Band_Desc] [varchar](200) NULL,
	[Age] [int] NOT NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
 CONSTRAINT [Dim_Age_Band_PK] PRIMARY KEY CLUSTERED 
(
	[Age_Band_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
