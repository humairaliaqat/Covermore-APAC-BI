USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penEmailAudit]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penEmailAudit](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[EmailAuditKey] [varchar](71) NULL,
	[EmailAuditID] [bigint] NOT NULL,
	[SentDate] [datetime] NULL,
	[Sender] [varchar](50) NOT NULL,
	[Status] [bit] NOT NULL,
	[Recipients] [varchar](200) NOT NULL,
	[AuditReference] [varchar](20) NOT NULL,
	[AuditReferenceTypeID] [int] NOT NULL,
	[Subject] [nvarchar](200) NOT NULL,
	[Body] [nvarchar](4000) NULL,
	[DomainKey] [varchar](41) NULL,
	[DomainID] [int] NOT NULL,
	[ExtraData] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
