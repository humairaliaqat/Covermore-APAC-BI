USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrAUDFXRate]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrAUDFXRate](
	[FXDate] [date] NULL,
	[CurrencyCode] [varchar](3) NULL,
	[minRate] [float] NULL,
	[maxRate] [float] NULL,
	[AvgRate] [float] NULL,
	[RecordCount] [int] NULL
) ON [PRIMARY]
GO
