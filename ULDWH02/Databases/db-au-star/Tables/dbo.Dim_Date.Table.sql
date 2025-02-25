USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Date]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Date](
	[Date_SK] [int] NOT NULL,
	[Month_SK] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Day_Of_Week] [int] NOT NULL,
	[Day_Name_Of_Week] [nvarchar](50) NOT NULL,
	[Day_Of_Month] [int] NOT NULL,
	[Day_Of_Year] [int] NOT NULL,
	[Weekday_Weekend] [nvarchar](50) NOT NULL,
	[Week_Of_Year] [int] NOT NULL,
	[Month_of_Year] [int] NOT NULL,
	[Month_Name] [nvarchar](50) NOT NULL,
	[Calendar_Qtr] [nvarchar](50) NOT NULL,
	[Calendar_Year] [int] NOT NULL,
	[Calendar_Year_Month] [nvarchar](50) NOT NULL,
	[Calendar_Month_Year] [nvarchar](50) NOT NULL,
	[Calendar_Year_Qtr] [nvarchar](50) NOT NULL,
	[Fiscal_Day_Of_Year] [int] NOT NULL,
	[Fiscal_Month_Of_Year] [int] NOT NULL,
	[Fiscal_Quarter] [nvarchar](50) NOT NULL,
	[Fiscal_Year] [int] NOT NULL,
	[Fiscal_Year_Month] [nvarchar](50) NOT NULL,
	[Fiscal_Year_Qtr] [nvarchar](50) NOT NULL,
	[isHoliday] [int] NULL,
	[isWeekday] [int] NULL,
	[isWeekend] [int] NULL,
	[isWorkDay] [int] NULL,
	[Total_Work_Days] [int] NULL,
	[Remaining_Work_Days] [int] NULL,
	[Create_Date] [datetime] NOT NULL,
	[Last7DaysStart] [datetime] NULL,
	[Last7DaysEnd] [datetime] NULL,
	[LastWeekNum] [int] NULL,
	[LastWeekStart] [datetime] NULL,
	[LastWeekEnd] [datetime] NULL,
	[Last14DaysStart] [datetime] NULL,
	[Last14DaysEnd] [datetime] NULL,
	[Last30DaysStart] [datetime] NULL,
	[Last30DaysEnd] [datetime] NULL,
	[LastMonthNum] [int] NULL,
	[LastFiscalMonthNum] [int] NULL,
	[LastMonthStart] [datetime] NULL,
	[LastFiscalMonthStart] [datetime] NULL,
	[LastMonthEnd] [datetime] NULL,
	[LastFiscalMonthEnd] [datetime] NULL,
	[LastQuarterNum] [int] NULL,
	[LastFiscalQuarterNum] [int] NULL,
	[LastQuarterStart] [datetime] NULL,
	[LastFiscalQuarterStart] [datetime] NULL,
	[LastQuarterEnd] [datetime] NULL,
	[LastFiscalQuarterEnd] [datetime] NULL,
	[LastYearNum] [int] NULL,
	[LastFiscalYearNum] [int] NULL,
	[LastYearStart] [datetime] NULL,
	[LastFiscalStart] [datetime] NULL,
	[LastYearEnd] [datetime] NULL,
	[LastFiscalYearEnd] [datetime] NULL,
	[Next7DaysStart] [datetime] NULL,
	[Next7DaysEnd] [datetime] NULL,
	[NextWeekNum] [int] NULL,
	[NextWeekStart] [datetime] NULL,
	[NextWeekEnd] [datetime] NULL,
	[Next14DaysStart] [datetime] NULL,
	[Next14DaysEnd] [datetime] NULL,
	[Next30DaysStart] [datetime] NULL,
	[Next30DaysEnd] [datetime] NULL,
	[NextMonthNum] [int] NULL,
	[NextFiscalMonthNumber] [int] NULL,
	[NextMonthStart] [datetime] NULL,
	[NextFiscalMonthStart] [datetime] NULL,
	[NextMonthEnd] [datetime] NULL,
	[NextFiscalMonthEnd] [datetime] NULL,
	[NextQuarterNum] [int] NULL,
	[NextFiscalQuarterNum] [int] NULL,
	[NextQuarterStart] [datetime] NULL,
	[NextFiscalQuarterStart] [datetime] NULL,
	[NextQuarterEnd] [datetime] NULL,
	[NextFiscalQuarterEnd] [datetime] NULL,
	[NextYearNum] [int] NULL,
	[NextFiscalYearNum] [int] NULL,
	[NextYearStart] [datetime] NULL,
	[NextFiscalYearStart] [datetime] NULL,
	[NextYearEnd] [datetime] NULL,
	[NextFiscalYearEnd] [datetime] NULL,
	[PreviousDay] [datetime] NULL,
	[CurWeekNum] [int] NULL,
	[CurWeekStart] [datetime] NULL,
	[CurWeekEnd] [datetime] NULL,
	[CurMonthNum] [int] NULL,
	[CurFiscalMonthNum] [int] NULL,
	[CurMonthStart] [datetime] NULL,
	[CurFiscalMonthStart] [datetime] NULL,
	[CurMonthEnd] [datetime] NULL,
	[CurFiscalMonthEnd] [datetime] NULL,
	[CurQuarterNum] [int] NULL,
	[CurFiscalQuarterNum] [int] NULL,
	[CurQuarterStart] [datetime] NULL,
	[CurFiscalQuarterStart] [datetime] NULL,
	[CurQuarterEnd] [datetime] NULL,
	[CurFiscalQuarterEnd] [datetime] NULL,
	[CurYearNum] [int] NULL,
	[CurFiscalYearNum] [int] NULL,
	[CurYearStart] [datetime] NULL,
	[CurFiscalYearStart] [datetime] NULL,
	[CurYearEnd] [datetime] NULL,
	[CurFiscalYear] [datetime] NULL,
	[MTDNum] [int] NULL,
	[MTDFiscalNum] [int] NULL,
	[MTDStart] [datetime] NULL,
	[MTDFiscalStart] [datetime] NULL,
	[MTDEnd] [datetime] NULL,
	[MTDFiscalEnd] [datetime] NULL,
	[WTDNum] [int] NULL,
	[WTDStart] [datetime] NULL,
	[WTDEnd] [datetime] NULL,
	[QTDNum] [int] NULL,
	[QTDFiscalNumber] [int] NULL,
	[QTDStart] [datetime] NULL,
	[QTDFiscalStart] [datetime] NULL,
	[QTDEnd] [datetime] NULL,
	[QTDFiscalEnd] [datetime] NULL,
	[YTDNum] [int] NULL,
	[YTDFiscalNum] [int] NULL,
	[YTDStart] [datetime] NULL,
	[YTDFiscalStart] [datetime] NULL,
	[YTDEnd] [datetime] NULL,
	[YTDFiscalEndDate] [datetime] NULL,
	[LYCurMonthNum] [int] NULL,
	[LYCurFiscalMonthNum] [int] NULL,
	[LYCurMonthStart] [datetime] NULL,
	[LYCurFiscalMonthStart] [datetime] NULL,
	[LYCurMonthEnd] [datetime] NULL,
	[LYCurFiscalMonthEnd] [datetime] NULL,
	[LYYearNum] [int] NULL,
	[LYFiscalYearNum] [int] NULL,
	[LYYeartStart] [datetime] NULL,
	[LYFiscalYearStart] [datetime] NULL,
	[LYYearEnd] [datetime] NULL,
	[LYFiscalYearEnd] [datetime] NULL,
	[LYQuarterNum] [int] NULL,
	[LYFiscalQuarterNum] [int] NULL,
	[LYQuarterStart] [datetime] NULL,
	[LYFiscalQuarterStart] [datetime] NULL,
	[LYQuarterEnd] [datetime] NULL,
	[LYFiscalQuarterEnd] [datetime] NULL,
	[LYWeekNum] [int] NULL,
	[LYWeekStart] [datetime] NULL,
	[LYWeekEnd] [datetime] NULL,
	[LYMTDNum] [int] NULL,
	[LYFiscalMTDNum] [int] NULL,
	[LYMTDStart] [datetime] NULL,
	[LYFiscalMTDStart] [datetime] NULL,
	[LYMTDEnd] [datetime] NULL,
	[LYFiscalMTDEnd] [datetime] NULL,
	[LYQTDNum] [int] NULL,
	[LYFiscalQTDNum] [int] NULL,
	[LYQTDStart] [datetime] NULL,
	[LYFiscalQTDStart] [datetime] NULL,
	[LYQTDEnd] [datetime] NULL,
	[LYFiscalQTDEnd] [datetime] NULL,
	[LYYTDNum] [int] NULL,
	[LYFiscalYTDNum] [int] NULL,
	[LYYTDStart] [datetime] NULL,
	[LYFiscalYTDStart] [datetime] NULL,
	[LYYTDEnd] [datetime] NULL,
	[LYFiscalYTDEnd] [datetime] NULL,
 CONSTRAINT [Dim_Date_PK] PRIMARY KEY CLUSTERED 
(
	[Date_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[Dim_Date]
(
	[Fiscal_Day_Of_Year] ASC,
	[Fiscal_Year] ASC
)
INCLUDE([Date]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_date]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_date] ON [dbo].[Dim_Date]
(
	[Date] ASC
)
INCLUDE([Date_SK],[Fiscal_Year_Month],[Fiscal_Year],[Total_Work_Days],[Remaining_Work_Days],[LastMonthStart],[LastMonthEnd],[LastFiscalStart],[CurMonthStart],[CurMonthEnd],[CurQuarterStart],[CurQuarterEnd],[CurFiscalYearStart],[CurFiscalYear],[LYCurMonthStart],[LYCurFiscalMonthStart],[Calendar_Qtr],[Calendar_Year],[Calendar_Year_Month],[Month_Name],[Calendar_Year_Qtr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_month]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_month] ON [dbo].[Dim_Date]
(
	[CurMonthStart] ASC,
	[Date] ASC
)
INCLUDE([Date_SK]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_SUNPeriod]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_SUNPeriod] ON [dbo].[Dim_Date]
(
	[Fiscal_Month_Of_Year] ASC
)
INCLUDE([Date_SK],[Date]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
