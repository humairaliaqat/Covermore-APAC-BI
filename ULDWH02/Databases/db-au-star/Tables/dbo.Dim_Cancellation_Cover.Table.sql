USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Cancellation_Cover]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Cancellation_Cover](
	[Cancellation_Cover_SK] [int] IDENTITY(0,1) NOT NULL,
	[Cancellation_Cover_Included] [char](1) NOT NULL,
	[Create_Date] [datetime] NOT NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL,
 CONSTRAINT [Dim_Cancellation_Cover_PK] PRIMARY KEY CLUSTERED 
(
	[Cancellation_Cover_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
