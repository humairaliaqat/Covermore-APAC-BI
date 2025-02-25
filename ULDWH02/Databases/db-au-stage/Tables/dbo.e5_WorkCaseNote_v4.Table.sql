USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkCaseNote_v4]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkCaseNote_v4](
	[Work_Id] [uniqueidentifier] NOT NULL,
	[Id] [bigint] NOT NULL,
	[CaseNoteDate] [datetime] NOT NULL,
	[CaseNoteUser] [nvarchar](100) NOT NULL,
	[CaseNote] [nvarchar](max) NULL,
	[PropertyId] [nvarchar](32) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
