USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_Groups_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_Groups_au](
	[SiteId] [uniqueidentifier] NOT NULL,
	[ID] [int] NOT NULL,
	[Title] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](512) NULL,
	[Owner] [int] NOT NULL,
	[OwnerIsUser] [bit] NOT NULL,
	[DLAlias] [nvarchar](128) NULL,
	[DLErrorMessage] [nvarchar](512) NULL,
	[DLFlags] [int] NULL,
	[DLJobId] [int] NULL,
	[DLArchives] [varchar](4000) NULL,
	[RequestEmail] [nvarchar](255) NULL,
	[Flags] [int] NOT NULL
) ON [PRIMARY]
GO
