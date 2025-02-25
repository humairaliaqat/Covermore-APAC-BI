USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_irindcontact_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_irindcontact_audtc](
	[kindid] [int] NOT NULL,
	[kcontacttypeid] [int] NOT NULL,
	[contact] [ntext] NULL,
	[contactext] [ntext] NULL,
	[usecontact] [varchar](5) NOT NULL,
	[comminstructions] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
