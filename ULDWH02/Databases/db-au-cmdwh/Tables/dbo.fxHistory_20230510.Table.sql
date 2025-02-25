USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[fxHistory_20230510]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fxHistory_20230510](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[LocalCode] [varchar](5) NULL,
	[ForeignCode] [varchar](5) NULL,
	[FXDate] [date] NULL,
	[FXRate] [decimal](25, 10) NULL,
	[FXSource] [varchar](50) NULL
) ON [PRIMARY]
GO
