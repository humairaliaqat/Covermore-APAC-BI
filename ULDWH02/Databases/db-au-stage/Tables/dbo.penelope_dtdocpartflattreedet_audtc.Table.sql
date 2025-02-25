USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_dtdocpartflattreedet_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_dtdocpartflattreedet_audtc](
	[kdocpartflattreeid] [int] NOT NULL,
	[seq] [int] NOT NULL,
	[partnumbering] [nvarchar](50) NOT NULL,
	[kpartidbody] [int] NOT NULL,
	[kpartidpage] [int] NULL,
	[kpartid] [int] NOT NULL,
	[dispinitstage] [varchar](5) NOT NULL,
	[lvl] [int] NOT NULL,
	[isregularanswer] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
