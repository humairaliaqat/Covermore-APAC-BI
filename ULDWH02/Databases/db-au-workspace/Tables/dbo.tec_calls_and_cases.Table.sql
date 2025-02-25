USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tec_calls_and_cases]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tec_calls_and_cases](
	[Agent] [nvarchar](max) NULL,
	[Date] [date] NULL,
	[Team] [varchar](7) NOT NULL,
	[Role] [varchar](16) NOT NULL,
	[CallCount] [int] NULL,
	[CaseCount] [int] NULL,
	[NoteCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
