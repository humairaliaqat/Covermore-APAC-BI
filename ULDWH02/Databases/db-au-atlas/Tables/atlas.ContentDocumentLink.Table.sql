USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[ContentDocumentLink]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[ContentDocumentLink](
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
	[ContentDocumentId] [varchar](25) NULL,
	[LinkedEntityId] [varchar](25) NULL,
	[ShareType] [varchar](25) NULL,
	[Visibility] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ContentDocumentLink] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[ContentDocumentLink_Hist])
)
GO
ALTER TABLE [atlas].[ContentDocumentLink]  WITH CHECK ADD  CONSTRAINT [FK_ContentDocumentLink_ContentDocument] FOREIGN KEY([ContentDocumentId])
REFERENCES [atlas].[ContentDocument] ([Id])
GO
ALTER TABLE [atlas].[ContentDocumentLink] CHECK CONSTRAINT [FK_ContentDocumentLink_ContentDocument]
GO
