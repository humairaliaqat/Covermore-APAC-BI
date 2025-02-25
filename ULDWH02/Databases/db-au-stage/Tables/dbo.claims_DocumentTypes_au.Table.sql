USE [db-au-stage]
GO
/****** Object:  Table [dbo].[claims_DocumentTypes_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[claims_DocumentTypes_au](
	[DocumentTypeId] [int] NOT NULL,
	[DocumentType] [nvarchar](128) NULL,
	[IsUnique] [bit] NOT NULL,
	[IsInternal] [bit] NOT NULL,
	[DOMAINID] [int] NOT NULL,
	[GroupCode] [nvarchar](50) NULL,
	[IsMandatory] [bit] NULL
) ON [PRIMARY]
GO
