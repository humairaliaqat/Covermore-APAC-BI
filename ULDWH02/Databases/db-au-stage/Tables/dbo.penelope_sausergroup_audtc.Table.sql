USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sausergroup_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sausergroup_audtc](
	[kusergroupid] [int] NOT NULL,
	[ugpname] [nvarchar](50) NOT NULL,
	[ugpdescrip] [nvarchar](250) NOT NULL,
	[ugplevel] [int] NOT NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL
) ON [PRIMARY]
GO
