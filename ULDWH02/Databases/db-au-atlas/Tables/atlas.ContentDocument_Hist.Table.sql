USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[ContentDocument_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[ContentDocument_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[ArchivedById] [varchar](25) NULL,
	[ArchivedDate] [date] NULL,
	[ContentModifiedDate] [datetime] NULL,
	[ContentSize] [int] NULL,
	[Description] [varchar](255) NULL,
	[FileExtension] [varchar](255) NULL,
	[FileType] [varchar](255) NULL,
	[LatestPublishedVersionId] [varchar](25) NULL,
	[Title] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_ContentDocument_Hist]    Script Date: 21/02/2025 11:28:23 AM ******/
CREATE CLUSTERED INDEX [ix_ContentDocument_Hist] ON [atlas].[ContentDocument_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
