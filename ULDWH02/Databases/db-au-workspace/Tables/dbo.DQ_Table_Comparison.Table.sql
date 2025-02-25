USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[DQ_Table_Comparison]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DQ_Table_Comparison](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[srcDate] [date] NULL,
	[Variance] [bigint] NULL,
	[srcObject] [nvarchar](255) NULL,
	[tarObject] [nvarchar](255) NULL,
	[compItem] [nvarchar](255) NULL,
	[compDesc] [nvarchar](255) NULL,
	[createDate] [datetime] NULL,
	[batchID] [int] NOT NULL,
 CONSTRAINT [PK_DQ_Table_Comparison] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
