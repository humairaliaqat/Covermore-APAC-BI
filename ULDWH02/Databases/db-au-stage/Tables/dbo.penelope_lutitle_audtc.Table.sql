USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_lutitle_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_lutitle_audtc](
	[lutitleid] [int] NOT NULL,
	[title] [nvarchar](20) NOT NULL,
	[slogin] [datetime2](7) NULL,
	[slogmod] [datetime2](7) NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
