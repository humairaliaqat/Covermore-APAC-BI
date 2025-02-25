USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sacontacttype_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sacontacttype_audtc](
	[kcontacttypeid] [int] NOT NULL,
	[contacttype] [nvarchar](50) NOT NULL,
	[kcontactclassid] [int] NOT NULL,
	[putonintakewizaddindiv] [varchar](5) NOT NULL,
	[intakewizpropagate] [varchar](5) NOT NULL,
	[usecontactdefault] [varchar](5) NOT NULL,
	[hassmscapability] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
