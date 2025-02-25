USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penEmailAudit]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penEmailAudit](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[EmailAuditKey] [varchar](41) NOT NULL,
	[EmailAuditID] [bigint] NOT NULL,
	[SentDate] [datetime] NULL,
	[Sender] [varchar](50) NULL,
	[Status] [bit] NULL,
	[Recipients] [varchar](200) NULL,
	[AuditReference] [varchar](50) NULL,
	[AuditReferenceTypeID] [int] NULL,
	[Subject] [nvarchar](200) NULL,
	[Body] [nvarchar](max) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NULL,
	[ExtraData] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penEmailAudit_AuditReference]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penEmailAudit_AuditReference] ON [dbo].[penEmailAudit]
(
	[AuditReference] ASC,
	[CountryKey] ASC
)
INCLUDE([CompanyKey],[SentDate],[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penEmailAudit_EmailAuditKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penEmailAudit_EmailAuditKey] ON [dbo].[penEmailAudit]
(
	[EmailAuditKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
