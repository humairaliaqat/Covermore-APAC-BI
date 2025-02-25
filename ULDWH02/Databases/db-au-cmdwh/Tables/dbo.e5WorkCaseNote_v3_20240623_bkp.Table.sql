USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[e5WorkCaseNote_v3_20240623_bkp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5WorkCaseNote_v3_20240623_bkp](
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
