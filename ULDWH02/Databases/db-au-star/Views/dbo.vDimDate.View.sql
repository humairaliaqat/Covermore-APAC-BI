USE [db-au-star]
GO
/****** Object:  View [dbo].[vDimDate]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vDimDate] 
as
select      
    Date_SK, 
    convert(varchar(10), [Date], 120) [Date], 
    Day_Of_Week, 
    Day_Name_Of_Week, 
    Day_Of_Month, 
    Day_Of_Year, 
    Weekday_Weekend, 
    Week_Of_Year, 
    Month_of_Year, 
    Month_Name, 
    Calendar_Qtr, 
    Calendar_Year, 
    Calendar_Year_Month, 
    Calendar_Month_Year, 
    Calendar_Year_Qtr, 
    Fiscal_Day_Of_Year, 
    Fiscal_Month_Of_Year, 
    Fiscal_Quarter, 
    Fiscal_Year, 
    Fiscal_Year_Month, 
    Fiscal_Year_Qtr, 
    isHoliday, 
    isWeekday, 
    isWeekend, 
    isWorkDay, 
    Total_Work_Days, 
    Remaining_Work_Days, 
    Create_Date, 
    CurWeekNum, 
    CurWeekStart, 
    CurWeekEnd, 
    CurMonthNum, 
    CurFiscalMonthNum, 
    CurMonthStart, 
    CurFiscalMonthStart, 
    CurMonthEnd, 
    CurFiscalMonthEnd, 
    CurQuarterNum, 
    CurFiscalQuarterNum, 
    CurQuarterStart, 
    CurFiscalQuarterStart, 
    CurQuarterEnd, 
    CurFiscalQuarterEnd, 
    CurYearNum, 
    CurFiscalYearNum, 
    CurYearStart, 
    CurFiscalYearStart, 
    CurYearEnd, 
    CurFiscalYear, 
    Month_Name + ' ' + convert(varchar, Calendar_Year) CalendarMonthYear, 
    'Quarter ' + CONVERT(varchar(1), Fiscal_Quarter) FiscalQuarterName,
    'Quarter ' + CONVERT(varchar(1), Calendar_Qtr) QuarterName,
    convert(varchar(11), [Date], 106) DateName
FROM
    Dim_Date
WHERE
    ([Date] BETWEEN '2011-01-01' AND CONVERT(VARCHAR(10), CONVERT(VARCHAR(4), YEAR(GETDATE()) + 2) + '-12-31'))
GO
