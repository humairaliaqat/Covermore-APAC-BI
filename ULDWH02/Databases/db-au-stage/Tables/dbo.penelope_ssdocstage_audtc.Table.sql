USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_ssdocstage_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_ssdocstage_audtc](
	[kdocstageid] [int] NOT NULL,
	[docstage] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
