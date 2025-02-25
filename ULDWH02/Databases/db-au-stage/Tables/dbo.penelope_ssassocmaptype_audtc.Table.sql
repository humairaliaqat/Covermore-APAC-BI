USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssassocmaptype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssassocmaptype_audtc](
	[kmaptypeid] [int] NOT NULL,
	[maptypedesc] [nvarchar](100) NOT NULL,
	[kentitytableidprim] [int] NOT NULL,
	[kentitytableidassoc] [int] NOT NULL,
	[isdelrestrict] [varchar](5) NOT NULL,
	[isdelsetnull] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
