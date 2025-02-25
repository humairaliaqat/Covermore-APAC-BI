USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Calendar]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendar](
	[Date] [smalldatetime] NOT NULL,
	[Last7DaysStart] [smalldatetime] NULL,
	[Last7DaysEnd] [smalldatetime] NULL,
	[LastWeekNum] [int] NULL,
	[LastWeekStart] [smalldatetime] NULL,
	[LastWeekEnd] [smalldatetime] NULL,
	[Last14DaysStart] [smalldatetime] NULL,
	[Last14DaysEnd] [smalldatetime] NULL,
	[Last30DaysStart] [smalldatetime] NULL,
	[Last30DaysEnd] [smalldatetime] NULL,
	[LastMonthNum] [int] NULL,
	[LastFiscalMonthNum] [int] NULL,
	[LastMonthStart] [smalldatetime] NULL,
	[LastFiscalMonthStart] [smalldatetime] NULL,
	[LastMonthEnd] [smalldatetime] NULL,
	[LastFiscalMonthEnd] [smalldatetime] NULL,
	[LastQuarterNum] [int] NULL,
	[LastFiscalQuarterNum] [int] NULL,
	[LastQuarterStart] [smalldatetime] NULL,
	[LastFiscalQuarterStart] [smalldatetime] NULL,
	[LastQuarterEnd] [smalldatetime] NULL,
	[LastFiscalQuarterEnd] [smalldatetime] NULL,
	[LastYearNum] [int] NULL,
	[LastFiscalYearNum] [int] NULL,
	[LastYearStart] [smalldatetime] NULL,
	[LastFiscalStart] [smalldatetime] NULL,
	[LastYearEnd] [smalldatetime] NULL,
	[LastFiscalYearEnd] [smalldatetime] NULL,
	[Next7DaysStart] [smalldatetime] NULL,
	[Next7DaysEnd] [smalldatetime] NULL,
	[NextWeekNum] [int] NULL,
	[NextWeekStart] [smalldatetime] NULL,
	[NextWeekEnd] [smalldatetime] NULL,
	[Next14DaysStart] [smalldatetime] NULL,
	[Next14DaysEnd] [smalldatetime] NULL,
	[Next30DaysStart] [smalldatetime] NULL,
	[Next30DaysEnd] [smalldatetime] NULL,
	[NextMonthNum] [int] NULL,
	[NextFiscalMonthNumber] [int] NULL,
	[NextMonthStart] [smalldatetime] NULL,
	[NextFiscalMonthStart] [smalldatetime] NULL,
	[NextMonthEnd] [smalldatetime] NULL,
	[NextFiscalMonthEnd] [smalldatetime] NULL,
	[NextQuarterNum] [int] NULL,
	[NextFiscalQuarterNum] [int] NULL,
	[NextQuarterStart] [smalldatetime] NULL,
	[NextFiscalQuarterStart] [smalldatetime] NULL,
	[NextQuarterEnd] [smalldatetime] NULL,
	[NextFiscalQuarterEnd] [smalldatetime] NULL,
	[NextYearNum] [int] NULL,
	[NextFiscalYearNum] [int] NULL,
	[NextYearStart] [smalldatetime] NULL,
	[NextFiscalYearStart] [smalldatetime] NULL,
	[NextYearEnd] [smalldatetime] NULL,
	[NextFiscalYearEnd] [smalldatetime] NULL,
	[PreviousDay] [smalldatetime] NULL,
	[CurWeekNum] [int] NULL,
	[CurWeekStart] [smalldatetime] NULL,
	[CurWeekEnd] [smalldatetime] NULL,
	[CurMonthNum] [int] NULL,
	[CurFiscalMonthNum] [int] NULL,
	[CurMonthStart] [smalldatetime] NULL,
	[CurFiscalMonthStart] [smalldatetime] NULL,
	[CurMonthEnd] [smalldatetime] NULL,
	[CurFiscalMonthEnd] [smalldatetime] NULL,
	[CurQuarterNum] [int] NULL,
	[CurFiscalQuarterNum] [int] NULL,
	[CurQuarterStart] [smalldatetime] NULL,
	[CurFiscalQuarterStart] [smalldatetime] NULL,
	[CurQuarterEnd] [smalldatetime] NULL,
	[CurFiscalQuarterEnd] [smalldatetime] NULL,
	[CurYearNum] [int] NULL,
	[CurFiscalYearNum] [int] NULL,
	[CurYearStart] [smalldatetime] NULL,
	[CurFiscalYearStart] [smalldatetime] NULL,
	[CurYearEnd] [smalldatetime] NULL,
	[CurFiscalYear] [smalldatetime] NULL,
	[MTDNum] [int] NULL,
	[MTDFiscalNum] [int] NULL,
	[MTDStart] [smalldatetime] NULL,
	[MTDFiscalStart] [smalldatetime] NULL,
	[MTDEnd] [smalldatetime] NULL,
	[MTDFiscalEnd] [smalldatetime] NULL,
	[WTDNum] [int] NULL,
	[WTDStart] [smalldatetime] NULL,
	[WTDEnd] [smalldatetime] NULL,
	[QTDNum] [int] NULL,
	[QTDFiscalNumber] [int] NULL,
	[QTDStart] [smalldatetime] NULL,
	[QTDFiscalStart] [smalldatetime] NULL,
	[QTDEnd] [smalldatetime] NULL,
	[QTDFiscalEnd] [smalldatetime] NULL,
	[YTDNum] [int] NULL,
	[YTDFiscalNum] [int] NULL,
	[YTDStart] [smalldatetime] NULL,
	[YTDFiscalStart] [smalldatetime] NULL,
	[YTDEnd] [smalldatetime] NULL,
	[YTDFiscalEndDate] [smalldatetime] NULL,
	[LYCurMonthNum] [int] NULL,
	[LYCurFiscalMonthNum] [int] NULL,
	[LYCurMonthStart] [smalldatetime] NULL,
	[LYCurFiscalMonthStart] [smalldatetime] NULL,
	[LYCurMonthEnd] [smalldatetime] NULL,
	[LYCurFiscalMonthEnd] [smalldatetime] NULL,
	[LYYearNum] [int] NULL,
	[LYFiscalYearNum] [int] NULL,
	[LYYeartStart] [smalldatetime] NULL,
	[LYFiscalYearStart] [smalldatetime] NULL,
	[LYYearEnd] [smalldatetime] NULL,
	[LYFiscalYearEnd] [smalldatetime] NULL,
	[LYQuarterNum] [int] NULL,
	[LYFiscalQuarterNum] [int] NULL,
	[LYQuarterStart] [smalldatetime] NULL,
	[LYFiscalQuarterStart] [smalldatetime] NULL,
	[LYQuarterEnd] [smalldatetime] NULL,
	[LYFiscalQuarterEnd] [smalldatetime] NULL,
	[LYWeekNum] [int] NULL,
	[LYWeekStart] [smalldatetime] NULL,
	[LYWeekEnd] [smalldatetime] NULL,
	[LYMTDNum] [int] NULL,
	[LYFiscalMTDNum] [int] NULL,
	[LYMTDStart] [smalldatetime] NULL,
	[LYFiscalMTDStart] [smalldatetime] NULL,
	[LYMTDEnd] [smalldatetime] NULL,
	[LYFiscalMTDEnd] [smalldatetime] NULL,
	[LYQTDNum] [int] NULL,
	[LYFiscalQTDNum] [int] NULL,
	[LYQTDStart] [smalldatetime] NULL,
	[LYFiscalQTDStart] [smalldatetime] NULL,
	[LYQTDEnd] [smalldatetime] NULL,
	[LYFiscalQTDEnd] [smalldatetime] NULL,
	[LYYTDNum] [int] NULL,
	[LYFiscalYTDNum] [int] NULL,
	[LYYTDStart] [smalldatetime] NULL,
	[LYFiscalYTDStart] [smalldatetime] NULL,
	[LYYTDEnd] [smalldatetime] NULL,
	[LYFiscalYTDEnd] [smalldatetime] NULL,
	[isHoliday] [int] NULL,
	[isWeekDay] [int] NULL,
	[isWeekEnd] [int] NULL,
	[SUNPeriod] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_calendar_date]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_calendar_date] ON [dbo].[Calendar]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_calendar_month]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_calendar_month] ON [dbo].[Calendar]
(
	[CurMonthStart] ASC
)
INCLUDE([Date]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
