USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssentitytype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssentitytype_audtc](
	[kentitytypeid] [int] NOT NULL,
	[entityname] [nvarchar](35) NOT NULL,
	[valisactive] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
