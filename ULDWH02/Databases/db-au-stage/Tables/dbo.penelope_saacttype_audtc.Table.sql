USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_saacttype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_saacttype_audtc](
	[kactivitytypeid] [int] NOT NULL,
	[activitytypename] [nvarchar](25) NOT NULL,
	[shortdesc] [nvarchar](14) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
