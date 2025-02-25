USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[COMMENTARY_MASTER]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMMENTARY_MASTER](
	[CommentID] [int] IDENTITY(1,1) NOT NULL,
	[DocId] [varchar](250) NOT NULL,
	[CommentText] [varchar](4000) NOT NULL,
	[UserCuid] [varchar](100) NOT NULL,
	[UserName] [varchar](255) NULL,
	[LastModifiedUserCuid] [varchar](100) NULL,
	[LastModifiedUserName] [varchar](255) NULL,
	[CreationTimeStamp] [bigint] NOT NULL,
	[LastModifiedTimestamp] [bigint] NOT NULL,
	[LogicalReportId] [varchar](100) NULL,
	[ContextCommon] [varchar](2000) NULL,
	[AppName] [varchar](100) NULL,
	[AppContext] [varchar](2000) NULL,
	[AppDatapath] [varchar](4000) NULL,
	[OptionKey1] [varchar](2000) NULL,
	[OptionKey2] [varchar](2000) NULL,
	[OptionKey3] [varchar](2000) NULL,
	[OptionKey4] [varchar](2000) NULL,
	[Hidden] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
