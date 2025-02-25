USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[fxHistoryJSON_test]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fxHistoryJSON_test](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[LocalCode] [varchar](5) NULL,
	[FXStartDate] [date] NULL,
	[FXEndDate] [date] NULL,
	[FXJSON] [nvarchar](max) NULL,
	[FXSource] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
