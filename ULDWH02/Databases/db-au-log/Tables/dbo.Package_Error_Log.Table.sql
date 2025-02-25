USE [db-au-log]
GO
/****** Object:  Table [dbo].[Package_Error_Log]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Package_Error_Log](
	[Batch_ID] [int] NOT NULL,
	[Package_ID] [varchar](100) NOT NULL,
	[Source_Table] [varchar](100) NULL,
	[Record] [varchar](2000) NULL,
	[Target_Table] [varchar](100) NULL,
	[Target_Field] [varchar](50) NULL,
	[Error_Code] [varchar](50) NULL,
	[Error_Description] [varchar](2000) NULL,
	[Insert_Date] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [main]    Script Date: 24/02/2025 2:34:43 PM ******/
CREATE CLUSTERED INDEX [main] ON [dbo].[Package_Error_Log]
(
	[Batch_ID] ASC,
	[Insert_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
