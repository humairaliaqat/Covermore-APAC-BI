USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[CaseComments]    Script Date: 21/02/2025 11:28:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[CaseComments](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[IsPublished] [bit] NULL,
	[ParentId] [varchar](25) NULL,
	[CommentBody] [varchar](4000) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[SystemModstamp] [datetime] NULL,
 CONSTRAINT [PK_STG_CaseComments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[CaseComments_Hist])
)
GO
ALTER TABLE [atlas].[CaseComments]  WITH CHECK ADD  CONSTRAINT [FK_CaseComments] FOREIGN KEY([ParentId])
REFERENCES [atlas].[Case] ([Id])
GO
ALTER TABLE [atlas].[CaseComments] CHECK CONSTRAINT [FK_CaseComments]
GO
