USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_notes]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_notes](
	[Agent] [nvarchar](55) NULL,
	[displayname] [nvarchar](445) NULL,
	[Team] [varchar](7) NOT NULL,
	[Role] [varchar](16) NOT NULL,
	[NoteTime] [datetime] NULL,
	[NoteID] [int] NOT NULL,
	[CaseNo] [nvarchar](15) NULL,
	[NoteType] [nvarchar](20) NULL,
	[ClientCode] [nvarchar](2) NOT NULL,
	[IndonesiaFlag] [int] NULL
) ON [PRIMARY]
GO
