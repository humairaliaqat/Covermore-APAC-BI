USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssitemtype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssitemtype_audtc](
	[kitemtypeid] [int] NOT NULL,
	[itemtype] [nvarchar](20) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
