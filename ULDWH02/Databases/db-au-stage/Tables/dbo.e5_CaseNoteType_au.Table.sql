USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_CaseNoteType_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_CaseNoteType_au](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](128) NULL
) ON [PRIMARY]
GO
