USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrTurnover]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrTurnover](
	[Division] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Month] [datetime] NULL,
	[TurnoverPct] [float] NULL
) ON [PRIMARY]
GO
