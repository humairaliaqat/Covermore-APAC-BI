USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[TMP_DTC_Journal]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMP_DTC_Journal](
	[Account Number] [nvarchar](255) NULL,
	[Debt] [float] NULL,
	[Credit] [float] NULL,
	[Reference] [nvarchar](255) NULL,
	[Document] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[sequence_id] [float] NULL,
	[Journal_Ctrl_num] [nvarchar](255) NULL
) ON [PRIMARY]
GO
