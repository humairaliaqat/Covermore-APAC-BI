USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkCaseNote_v3]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkCaseNote_v3](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [varchar](5) NULL,
	[Country] [varchar](5) NULL,
	[Work_Id] [varchar](50) NULL,
	[ID] [varchar](50) NULL,
	[Original_Work_Id] [uniqueidentifier] NOT NULL,
	[Original_Id] [bigint] NOT NULL,
	[CaseNoteDate] [datetime] NOT NULL,
	[CaseNoteUserID] [nvarchar](100) NOT NULL,
	[CaseNoteUser] [nvarchar](455) NULL,
	[CaseNote] [nvarchar](max) NULL,
	[PropertyId] [nvarchar](32) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[DeleteBatchID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_e5WorkCaseNote_v3_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_e5WorkCaseNote_v3_BIRowID] ON [dbo].[e5WorkCaseNote_v3]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkCaseNote_v3_ID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5WorkCaseNote_v3_ID] ON [dbo].[e5WorkCaseNote_v3]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_e5WorkCaseNote_v3_Work_ID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_e5WorkCaseNote_v3_Work_ID] ON [dbo].[e5WorkCaseNote_v3]
(
	[Work_Id] ASC,
	[Country] ASC
)
INCLUDE([CaseNoteDate],[CaseNoteUser],[CaseNote],[PropertyId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
