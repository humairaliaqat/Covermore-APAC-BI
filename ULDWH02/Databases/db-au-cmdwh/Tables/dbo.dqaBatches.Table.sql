USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[dqaBatches]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dqaBatches](
	[dqaBatchID] [int] IDENTITY(1,1) NOT NULL,
	[dqaTestName] [varchar](255) NULL,
	[dqaTestGroup] [varchar](50) NULL,
	[dqaTestDate] [date] NULL,
	[dqaStartDate] [date] NULL,
	[dqaEndDate] [date] NULL,
	[dqaTestEnabled] [bit] NOT NULL,
	[isProcessed] [bit] NULL,
	[Date_SK] [int] NULL
) ON [PRIMARY]
GO
