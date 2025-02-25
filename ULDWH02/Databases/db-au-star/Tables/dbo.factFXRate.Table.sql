USE [db-au-star]
GO
/****** Object:  Table [dbo].[factFXRate]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[factFXRate](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[DateSK] [int] NULL,
	[DomainSK] [int] NOT NULL,
	[ForeignCurrency] [nvarchar](3) NULL,
	[Rate] [float] NULL,
	[RateChange] [float] NULL,
	[InverseRate] [float] NULL,
	[InverseRateChange] [float] NULL,
	[MonthlyInverseRate] [float] NULL,
	[PreviousMonthInverseRate] [float] NULL,
	[MonthlyInverseRateChange] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE UNIQUE CLUSTERED INDEX [cidx] ON [dbo].[factFXRate]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[factFXRate]
(
	[ForeignCurrency] ASC,
	[DateSK] ASC
)
INCLUDE([DomainSK],[Rate],[RateChange],[InverseRate],[InverseRateChange]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
