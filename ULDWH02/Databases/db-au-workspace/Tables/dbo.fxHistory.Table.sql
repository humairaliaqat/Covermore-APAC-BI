USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[fxHistory]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fxHistory](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[LocalCode] [varchar](5) NULL,
	[ForeignCode] [varchar](5) NULL,
	[FXDate] [date] NULL,
	[FXRate] [decimal](25, 10) NULL,
	[FXSource] [varchar](50) NULL
) ON [PRIMARY]
GO
