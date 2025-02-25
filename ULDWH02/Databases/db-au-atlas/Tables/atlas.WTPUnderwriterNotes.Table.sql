USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[WTPUnderwriterNotes]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[WTPUnderwriterNotes](
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
	[Case_c] [varchar](25) NULL,
	[Categories_c] [nvarchar](50) NULL,
	[CommunicationDate_c] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[Notes_c] [varchar](8000) NULL,
	[RecordTypeId] [varchar](25) NULL,
	[ShowOnTimeline_c] [bit] NULL,
	[Subject_c] [varchar](255) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_WTPUnderwriterNotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[WTPUnderwriterNotes_Hist])
)
GO
ALTER TABLE [atlas].[WTPUnderwriterNotes]  WITH NOCHECK ADD  CONSTRAINT [FK_WTPUnderwriterNotes] FOREIGN KEY([Case_c])
REFERENCES [atlas].[Case] ([Id])
GO
ALTER TABLE [atlas].[WTPUnderwriterNotes] NOCHECK CONSTRAINT [FK_WTPUnderwriterNotes]
GO
