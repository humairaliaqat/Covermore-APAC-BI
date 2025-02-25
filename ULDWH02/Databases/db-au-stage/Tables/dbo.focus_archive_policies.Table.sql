USE [db-au-stage]
GO
/****** Object:  Table [dbo].[focus_archive_policies]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[focus_archive_policies](
	[sessiontoken] [uniqueidentifier] NULL,
	[policynumber] [nvarchar](25) NULL,
	[policydata] [nvarchar](4000) NULL,
	[lastupdatetime] [datetime2](7) NULL
) ON [PRIMARY]
GO
