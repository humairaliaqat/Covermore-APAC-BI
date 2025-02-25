USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[fxHistoryAverage]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fxHistoryAverage](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[LocalCode] [varchar](5) NULL,
	[ForeignCode] [varchar](5) NULL,
	[FXStartDate] [date] NULL,
	[FXEndDate] [date] NULL,
	[FXRate] [decimal](25, 10) NULL,
	[FXSource] [varchar](50) NULL,
	[FXPeriod] [date] NULL,
	[isHyperinflationPeriod] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx_fxHistory]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx_fxHistory] ON [dbo].[fxHistoryAverage]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_fxHistory_FX]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_fxHistory_FX] ON [dbo].[fxHistoryAverage]
(
	[LocalCode] ASC,
	[ForeignCode] ASC,
	[FXStartDate] ASC
)
INCLUDE([FXEndDate],[FXRate],[FXSource],[isHyperinflationPeriod]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
