USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbNote_BKP20190122_deleted_records]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbNote_BKP20190122_deleted_records](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[UserKey] [nvarchar](35) NULL,
	[NoteKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NULL,
	[UserID] [nvarchar](30) NULL,
	[NoteID] [int] NOT NULL,
	[UserName] [nvarchar](55) NULL,
	[CreateDate] [datetime] NULL,
	[CreateTime] [datetime] NULL,
	[CreateTimeUTC] [datetime] NULL,
	[NoteType] [nvarchar](20) NULL,
	[IsIncluded] [bit] NULL,
	[IsMBFSent] [bit] NULL,
	[Notes] [nvarchar](max) NULL,
	[NoteCode] [nvarchar](5) NULL,
	[IsDeleted] [bit] NULL,
	[NoteTime] [datetime] NULL,
	[NoteTimeUTC] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
