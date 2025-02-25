USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[ContentVersion]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[ContentVersion](
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
	[Checksum] [varchar](255) NULL,
	[ContentDocumentId] [varchar](25) NULL,
	[ContentLocation] [varchar](255) NULL,
	[ContentModifiedById] [varchar](25) NULL,
	[ContentModifiedDate] [datetime] NULL,
	[ContentSize] [int] NULL,
	[ContentUrl] [varchar](4000) NULL,
	[Description] [varchar](255) NULL,
	[FileExtension] [varchar](255) NULL,
	[FileRedaction_Created_By_File_Redactor_c] [varchar](4000) NULL,
	[FileType] [varchar](255) NULL,
	[IsLatest] [bit] NULL,
	[IsMajorVersion] [bit] NULL,
	[TagCsv] [varchar](255) NULL,
	[TextPreview] [varchar](255) NULL,
	[Title] [varchar](255) NULL,
	[VersionData] [varchar](max) NULL,
	[VersionNumber] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ContentVersion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[ContentVersion_Hist])
)
GO
ALTER TABLE [atlas].[ContentVersion]  WITH CHECK ADD  CONSTRAINT [FK_ContentVersion_ContentDocument] FOREIGN KEY([ContentDocumentId])
REFERENCES [atlas].[ContentDocument] ([Id])
GO
ALTER TABLE [atlas].[ContentVersion] CHECK CONSTRAINT [FK_ContentVersion_ContentDocument]
GO
