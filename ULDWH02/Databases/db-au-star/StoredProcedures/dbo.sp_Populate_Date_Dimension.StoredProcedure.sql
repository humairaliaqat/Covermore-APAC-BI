USE [db-au-star]
GO
/****** Object:  StoredProcedure [dbo].[sp_Populate_Date_Dimension]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_Populate_Date_Dimension]
@BeginDate DATETIME,
@EndDate DATETIME
AS
SET NOCOUNT ON;
DECLARE @FiscalYearMonthsOffset INT   
DECLARE @DateCounter DATETIME    --Current date in loop
DECLARE @FiscalCounter DATETIME  --Fiscal Year Date in loop 
SET @FiscalYearMonthsOffset = 6
SET @DateCounter = @BeginDate

WHILE @DateCounter <= @EndDate
      BEGIN
            SET @FiscalCounter = DATEADD(m, @FiscalYearMonthsOffset, @DateCounter)
            Insert into Dim_Date
               (Date_SK,
                Date,
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
                Fiscal_Month_Of_Year,
                Fiscal_Quarter,
                Fiscal_Year,
                Fiscal_Year_Month,
                Fiscal_Year_Qtr,
                Create_Date                
               )
                  Values (
                      ( YEAR(@DateCounter) * 10000 ) + ( MONTH(@DateCounter)* 100 )
                      + DAY(@DateCounter)  --Date_SK
                    , @DateCounter -- FullDate 
                    , DATEPART(dw, @DateCounter) --DayOfWeek
                    , DATENAME(dw, @DateCounter) --DayNameOfWeek
                    , DATENAME(dd, @DateCounter) --DayOfMonth
                    , DATENAME(dy, @DateCounter) --DayOfYear                    
                    , CASE DATENAME(dw, @DateCounter)
                        WHEN 'Saturday' THEN 'Weekend'
                        WHEN 'Sunday' THEN 'Weekend'
                        ELSE 'Weekday'
                      END --Weekday_Weekend
                    , DATENAME(ww, @DateCounter) --WeekOfYear
                    , MONTH(@DateCounter) --MonthOfYear  
                    , DATENAME(mm, @DateCounter) --MonthName                                      
                    , DATENAME(qq, @DateCounter) --CalendarQuarter
                    , YEAR(@DateCounter) --CalendarYear
                    , CAST(YEAR(@DateCounter) AS CHAR(4)) + '-'
                      + RIGHT('00' + RTRIM(CAST(DATEPART(mm, @DateCounter) AS CHAR(2))), 2) --CalendarYearMonth
                    , SUBSTRING(DATENAME(mm, @DateCounter),1,3)+'-'+CAST(YEAR(@DateCounter) AS CHAR(4)) --[Calendar_Month_Year]
                    , CAST(YEAR(@DateCounter) AS CHAR(4)) + 'Q' + DATENAME(qq, @DateCounter) --CalendarYearQtr
                    , cast(cast(YEAR(@FiscalCounter) as CHAR(4)) + '0' + RIGHT('00' + RTRIM(CAST(DATEPART(mm, @FiscalCounter) AS CHAR(2))), 2) as integer)--[FiscalMonthOfYear]
                    , DATENAME(qq, @FiscalCounter) --[FiscalQuarter]
                    , YEAR(@FiscalCounter) --[FiscalYear]
                    , CAST(YEAR(@FiscalCounter) AS CHAR(4)) + '-'
                      + RIGHT('00' + RTRIM(CAST(DATEPART(mm, @FiscalCounter) AS CHAR(2))), 2) --[FiscalYearMonth]
                    , CAST(YEAR(@FiscalCounter) AS CHAR(4)) + 'Q' + DATENAME(qq, @FiscalCounter) --[FiscalYearQtr]                    
                    , getdate()
                    )

            -- Increment the date counter for next pass thru the loop
            SET @DateCounter = DATEADD(d, 1, @DateCounter)
      END                    





GO
