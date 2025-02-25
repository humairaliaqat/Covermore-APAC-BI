USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblEmailAudit_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblEmailAudit_aucm](
	[ID] [bigint] NOT NULL,
	[SentDate] [datetime] NOT NULL,
	[Sender] [varchar](50) NOT NULL,
	[Status] [bit] NOT NULL,
	[Recipients] [varchar](200) NOT NULL,
	[AuditReference] [varchar](20) NOT NULL,
	[AuditReferenceTypeID] [int] NOT NULL,
	[Subject] [nvarchar](200) NOT NULL,
	[Body] [nvarchar](4000) NULL,
	[ExtraData] [nvarchar](max) NULL,
	[DomainID] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
