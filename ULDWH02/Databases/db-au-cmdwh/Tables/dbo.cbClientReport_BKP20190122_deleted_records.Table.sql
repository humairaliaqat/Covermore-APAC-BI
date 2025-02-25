USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbClientReport_BKP20190122_deleted_records]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbClientReport_BKP20190122_deleted_records](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[ClientReportKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[ClientReportID] [int] NOT NULL,
	[CreatedByID] [nvarchar](30) NULL,
	[CreatedBy] [nvarchar](55) NULL,
	[CreateDate] [datetime] NULL,
	[CreateTimeUTC] [datetime] NULL,
	[NoteDate] [datetime] NULL,
	[NoteTime] [datetime] NULL,
	[NoteTimeUTC] [datetime] NULL,
	[NoteType] [nvarchar](15) NULL,
	[Notes] [nvarchar](max) NULL,
	[IsChaseCover] [bit] NULL,
	[IsHeader] [bit] NULL,
	[IsCancelled] [bit] NULL,
	[UrgencyID] [int] NULL,
	[Urgency] [nvarchar](100) NULL,
	[Reason] [nvarchar](2000) NULL,
	[EmailDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
	[EmailDetails] [nvarchar](max) NULL,
	[ApproximateDeleteDate] [datetime] NULL,
	[isInitialCR] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
