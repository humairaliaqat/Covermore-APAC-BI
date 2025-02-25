USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimDate]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_dimDate]	
    @StartDate datetime,
    @EndDate datetime
    
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131126
Prerequisite:   N/A
Description:    populate Dim_Date dimension with dates.
Parameters:		@StartDate:	Required. Format YYYY-MM-DD eg. 2013-01-01
				@EndDate:	Required. Format YYYY-MM-DD eg. 2013-01-01
Change History:
                20131126 - LT - Procedure created
                20150204 - LS - add batch logging
                20160406 - LS - bug fix on Total_Work_Days & Remaining_Work_Days
                                it double counts holidays on weekend

*************************************************************************************************************************************/

--uncomment to debug
/*
declare 
    @StartDate datetime,
    @EndDate datetime
select 
    @StartDate = '2001-01-01', 
    @EndDate = '2100-12-31'
*/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Policy Star',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'




    declare @FiscalYearMonthsOffset int
    declare @FiscalDayYearOffSet int
    declare @DateCounter datetime		--Current date in loop
    declare @FiscalCounter datetime		--Fiscal Year Date in loop 
    set @FiscalYearMonthsOffset = 6		--Fiscal month offset (ie July = 1, August = 2, Sep = 3 ... Jun = 12)
    set @DateCounter = @StartDate
    set datefirst 1						--set Monday to Sunday week



    if object_id('[db-au-star].dbo.Dim_Date') is null
    begin
	    create table [db-au-star].[dbo].[Dim_Date]
	    (
		    [Date_SK] [int] not null,
		    [Month_SK] [int] not null,
		    [Date] [datetime] not null,
		    [Day_Of_Week] [int] not null,
		    [Day_Name_Of_Week] [nvarchar](50) not null,
		    [Day_Of_Month] [int] not null,
		    [Day_Of_Year] [int] not null,
		    [Weekday_Weekend] [nvarchar](50) not null,
		    [Week_Of_Year] [int] not null,
		    [Month_of_Year] [int] not null,
		    [Month_Name] [nvarchar](50) not null,
		    [Calendar_Qtr] [nvarchar](50) not null,
		    [Calendar_Year] [int] not null,
		    [Calendar_Year_Month] [nvarchar](50) not null,
		    [Calendar_Month_Year] [nvarchar](50) not null,
		    [Calendar_Year_Qtr] [nvarchar](50) not null,
		    [Fiscal_Day_Of_Year] [int] not null,
		    [Fiscal_Month_Of_Year] [int] not null,
		    [Fiscal_Quarter] [nvarchar](50) not null,
		    [Fiscal_Year] [int] not null,
		    [Fiscal_Year_Month] [nvarchar](50) not null,
		    [Fiscal_Year_Qtr] [nvarchar](50) not null,
		    [isHoliday] [int] null,						--based on AU NSW work days
		    [isWeekday] [int] null,
		    [isWeekend] [int] null,
		    [isWorkDay] [int] null,
		    [Total_Work_Days] [int] null,				--based on AU NSW work days
		    [Remaining_Work_Days] [int] null,			--based on AU NSW work days
		    [Create_Date] [datetime] not null,
            Last7DaysStart datetime null,          --last 7 days start date
            Last7DaysEnd datetime null,            --last 7 days end date
            LastWeekNum int null,                       --last week number
            LastWeekStart datetime null,           --last week start date (Mon-Sun)
            LastWeekEnd datetime null,             --last week end date (Mon-Sun)
            Last14DaysStart datetime null,         --last 14 days start date
            Last14DaysEnd datetime null,           --last 14 days end date
            Last30DaysStart datetime null,         --last 30 days start date
            Last30DaysEnd datetime null,           --last 30 days end date
            LastMonthNum int null,                      --last month number
            LastFiscalMonthNum int null,                --last fiscal month number
            LastMonthStart datetime null,          --last month start date
            LastFiscalMonthStart datetime null,    --last fiscal month start date
            LastMonthEnd datetime null,            --last month end date
            LastFiscalMonthEnd datetime null,      --last fiscal month end date
            LastQuarterNum int null,                    --last quarter number
            LastFiscalQuarterNum int null,              --last fiscal quarter number
            LastQuarterStart datetime null,        --last quarter start date
            LastFiscalQuarterStart datetime null,  --last fiscal quarter start date
            LastQuarterEnd datetime null,          --last quarter end date
            LastFiscalQuarterEnd datetime null,    --last fiscal quarter end date
            LastYearNum int null,                       --last year number
            LastFiscalYearNum int null,                 --last fiscal year number
            LastYearStart datetime null,           --last year start date
            LastFiscalStart datetime null,         --last fiscal year start date
            LastYearEnd datetime null,             --last year end date
            LastFiscalYearEnd datetime null,       --last fiscal year end date
            Next7DaysStart datetime null,          --next 7 days start date
            Next7DaysEnd datetime null,            --next 7 days end date
            NextWeekNum int null,                       --next week number
            NextWeekStart datetime,                --next week start date (Mon-Sun)
            NextWeekEnd datetime,                  --next week end date (Mon-Sun)
            Next14DaysStart datetime null,         --next 14 days start date
            Next14DaysEnd datetime null,           --next 14 days end date
            Next30DaysStart datetime null,         --next 30 days start date
            Next30DaysEnd datetime null,           --next 30 days end date
            NextMonthNum int null,                      --next month number
            NextFiscalMonthNumber int null,             --next fiscal month number
            NextMonthStart datetime null,          --next month start date
            NextFiscalMonthStart datetime null,    --next fiscal month start date
            NextMonthEnd datetime null,            --next month end date
            NextFiscalMonthEnd datetime null,      --next fiscal month end date
            NextQuarterNum int null,                    --next quarter number
            NextFiscalQuarterNum int null,              --next fiscal quarter number
            NextQuarterStart datetime null,        --next quarter start date
            NextFiscalQuarterStart datetime null,  --next fiscal quarter start date
            NextQuarterEnd datetime null,          --next quarter end date
            NextFiscalQuarterEnd datetime null,    --next fiscal quarter end date
            NextYearNum int null,                       --next year number
            NextFiscalYearNum int null,                 --next fiscal year number
            NextYearStart datetime null,           --next year start date
            NextFiscalYearStart datetime null,     --next fiscal year start date
            NextYearEnd datetime null,             --next year end date
            NextFiscalYearEnd datetime null,       --next fiscal year end date
            PreviousDay datetime null,             --previous day date
            CurWeekNum int null,                        --current week number
            CurWeekStart datetime null,            --current week start date (Mon-Sun)
            CurWeekEnd datetime null,              --current week end date (Mon-Sun)
            CurMonthNum int null,                       --current month number
            CurFiscalMonthNum int null,                 --current fiscal month number
            CurMonthStart datetime null,           --current month start date
            CurFiscalMonthStart datetime null,     --current fiscal month start date
            CurMonthEnd datetime null,             --current month end date
            CurFiscalMonthEnd datetime null,       --current fiscal month end date
            CurQuarterNum int null,                     --current quarter number
            CurFiscalQuarterNum int null,               --current fiscal quarter number
            CurQuarterStart datetime null,         --current quarter start date
            CurFiscalQuarterStart datetime null,   --current fiscal quarter start date
            CurQuarterEnd datetime null,           --current quarter end date
            CurFiscalQuarterEnd datetime null,     --current fiscal quarter end date
            CurYearNum int null,                        --current year number
            CurFiscalYearNum int null,                  --current fiscal year number
            CurYearStart datetime null,            --current year start date
            CurFiscalYearStart datetime null,      --current fiscal year start date
            CurYearEnd datetime null,              --current year end date
            CurFiscalYear datetime null,           --current fiscal year end date
            MTDNum int null,                            --month-to-date number
            MTDFiscalNum int null,                      --month-to-date fiscal number
            MTDStart datetime null,                --month-to-date start date
            MTDFiscalStart datetime null,          --month-to-date fiscal start date
            MTDEnd datetime null,                  --month-to-date end date
            MTDFiscalEnd datetime null,            --month-to-date fiscal end date
            WTDNum int null,                            --week-to-date number
            WTDStart datetime null,                --week-to-date start date (Mon-Sun)
            WTDEnd datetime null,                  --week-to-date end date    (Mon-Sun)
            QTDNum int null,                            --quarter-to-date number
            QTDFiscalNumber int null,                   --quarter-to-date fiscal number
            QTDStart datetime null,                --quarter-to-date start date
            QTDFiscalStart datetime null,          --quarter-to-date fiscal start date
            QTDEnd datetime null,                  --quarter-to-date end date
            QTDFiscalEnd datetime null,            --quarter-to-date fiscal end date
            YTDNum int null,                            --year-to-date number
            YTDFiscalNum int null,                      --year-to-date fiscal number
            YTDStart datetime null,                --year-to-date start date
            YTDFiscalStart datetime null,          --year-to-date fiscal start date
            YTDEnd datetime null,                  --year-to-date end date
            YTDFiscalEndDate datetime null,        --year-to-date fiscal end date
            LYCurMonthNum int null,                     --last year current month number
            LYCurFiscalMonthNum int null,               --last year current fiscal month number
            LYCurMonthStart datetime null,         --last year current month start date
            LYCurFiscalMonthStart datetime null,   --last year current fiscal month start date
            LYCurMonthEnd datetime null,           --last year current month end date
            LYCurFiscalMonthEnd datetime null,     --last year current fiscal month end
            LYYearNum int null,                         --last year year number
            LYFiscalYearNum int null,                   --last year fiscal year number
            LYYeartStart datetime null,            --last year year start date
            LYFiscalYearStart datetime null,       --last year fiscal year start date
            LYYearEnd datetime null,               --last year year end date
            LYFiscalYearEnd datetime null,         --last year fiscal year end date
            LYQuarterNum int null,                      --last year quarter number
            LYFiscalQuarterNum int null,                --last year fiscal quarter number
            LYQuarterStart datetime null,          --last year quarter start date
            LYFiscalQuarterStart datetime null,    --last year fiscal quarter start date
            LYQuarterEnd datetime null,            --last year quarter end date
            LYFiscalQuarterEnd datetime null,      --last year fiscal quarter end date
            LYWeekNum int null,                         --last year week number
            LYWeekStart datetime null,             --last year week start date
            LYWeekEnd datetime null,               --last year week end date
            LYMTDNum int null,                          --last year month-to-date number
            LYFiscalMTDNum int null,                    --last year fiscal month-to-date number
            LYMTDStart datetime null,              --last year month-to-date start date
            LYFiscalMTDStart datetime null,        --last year fiscal month-to-date start date
            LYMTDEnd datetime null,                --last year month-to-date end date
            LYFiscalMTDEnd datetime null,          --last year fiscal month-to-date end date
            LYQTDNum int null,                          --last year quarter-to-date number
            LYFiscalQTDNum int null,                    --last year fiscal quarter-to-date number
            LYQTDStart datetime null,              --last year quarter-to-date start date
            LYFiscalQTDStart datetime null,        --last year fiscal quarter-to-date start date
            LYQTDEnd datetime null,                --last year quarter-to-date end date
            LYFiscalQTDEnd datetime null,          --last year fiscal quarter-to-date end date
            LYYTDNum int null,                          --last year year-to-date number
            LYFiscalYTDNum int null,                    --last year fiscal year-to-date number
            LYYTDStart datetime null,              --last year year-to-date start date
            LYFiscalYTDStart datetime null,        --last year fiscal year-to-date start date
            LYYTDEnd datetime null,                --last year year-to-date end date
            LYFiscalYTDEnd datetime null,          --last year fiscal year-to-date end date		
		    CONSTRAINT [Dim_Date_PK] PRIMARY KEY CLUSTERED 
		    (
			    [Date_SK] ASC
		    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	    ) ON [PRIMARY]
    end

    begin transaction
    begin try


        delete [db-au-star].dbo.Dim_Date
        where [Date] between @StartDate and @EndDate
        	

        while @DateCounter <= @EndDate
        begin
	        select @FiscalCounter = dateadd(m, @FiscalYearMonthsOffset, @DateCounter)						--set fiscal counter offset
	        select @FiscalDayYearOffSet = case when [db-au-cmdwh].dbo.fn_isLeapYear(year(@DateCounter)) = 1 then -182
									           else -181													--set fiscal day of year offset
								          end
	        Insert [db-au-star].dbo.Dim_Date with(tablock)
	        select
		        convert(int,convert(nvarchar(8),@DateCounter,112)),											--Date_SK
		        convert(int,convert(nvarchar(6),@DateCounter,112)+'01'),									--Month_SK
		        @DateCounter,																				--FullDate 
		        datepart(dw, @DateCounter),																	--DayOfWeek
		        datepart(dw, @DateCounter),																	--DayNameOfWeek
		        datename(dd, @DateCounter),																	--DayOfMonth
		        datename(dy, @DateCounter),																	--DayOfYear                    
		        case datename(dw, @DateCounter) when 'Saturday' then 'Weekend'
										        when 'Sunday' then 'Weekend'
										        else 'Weekday'
		        end,																						--Weekday_Weekend
		        datename(ww, @DateCounter),																	--WeekOfYear
		        month(@DateCounter),																		--MonthOfYear  
		        datename(mm, @DateCounter),																	--MonthName                                      
		        datename(qq, @DateCounter),																	--CalendarQuarter
		        year(@DateCounter),																			--CalendarYear
		        convert(nvarchar(7),@DateCounter,120),														--CalendarYearMonth
		        substring(datename(mm, @DateCounter),1,3) + '-' + cast(year(@DateCounter) as nvarchar(4)),	--Calendar_Month_Year
		        cast(year(@DateCounter) as nvarchar(4)) + 'Q' + datename(qq, @DateCounter),					--CalendarYearQtr
		        datename(dy, dateadd(dy,@FiscalDayYearOffSet,@DateCounter)),								--FiscalDayOfYear
		        cast(cast(year(@FiscalCounter) as nvarchar(4)) + '0' + 
			         right('00' + rtrim(cast(datepart(mm, @FiscalCounter) as nvarchar(2))), 2) as integer),	--FiscalMonthOfYear
		        datename(qq, @FiscalCounter),																--FiscalQuarter
		        year(@FiscalCounter),																		--FiscalYear
		        cast(year(@FiscalCounter) as nvarchar(4)) + '-' + 
			         right('00' + rtrim(cast(datepart(mm, @FiscalCounter) as nvarchar(2))), 2),				--FiscalYearMonth
		        cast(year(@FiscalCounter) as nvarchar(4)) + 'Q' + datename(qq, @FiscalCounter),				--FiscalYearQtr
		        0 as isHoliday,																				--based on AU NSW holidays
                case when datepart(dw,@DateCounter) in (1,2,3,4,5) then 1 else 0 end as isWeekDay,			--Monday to Sunday week
                case when datepart(dw,@DateCounter) in (6,7) then 1 else 0 end as isWeekEnd,				--Monday to Sunday weekend
                0 as isWorkDay,																				--based on AU NSW work days
		        0 as Total_Work_Days,																		--based on AU NSW work days. Total work days for month
		        0 as Remaining_Work_Days,																	--based on AU NSW work days. Remaining work days for month
		        getdate(),																					--create date
                Last7DaysStart = [db-au-cmdwh].dbo.fn_dtLast7DaysStart(@DateCounter),                                                      --last 7 days start date
                Last7DaysEnd = [db-au-cmdwh].dbo.fn_dtLast7DaysEnd(@DateCounter),                                                          --last 7 days end date
                LastWeekNum = [db-au-cmdwh].dbo.fn_dtLastWeekNum(@DateCounter),                                                            --last week number
                LastWeekStart = [db-au-cmdwh].dbo.fn_dtLastWeekStart(@DateCounter),                                                        --last week start date (Mon-Sun)
                LastWeekEnd = [db-au-cmdwh].dbo.fn_dtLastWeekEnd(@DateCounter),                                                            --last week end date (Mon-Sun)
                Last14DaysStart = [db-au-cmdwh].dbo.fn_dtLast14DaysStart(@DateCounter),                                                    --last 14 days start date
                Last14DaysEnd = [db-au-cmdwh].dbo.fn_dtLast14DaysEnd(@DateCounter),                                                        --last 14 days end date
                Last30DaysStart = [db-au-cmdwh].dbo.fn_dtLast30DaysStart(@DateCounter),                                                    --last 30 days start date
                Last30DaysEnd = [db-au-cmdwh].dbo.fn_dtLast30DaysEnd(@DateCounter),                                                        --last 30 days end date
                LastMonthNum = [db-au-cmdwh].dbo.fn_dtLastMonthNum(@DateCounter),                                                          --last month number
                LastFiscalMonthNum = [db-au-cmdwh].dbo.fn_dtLastFiscalMonthNum(@DateCounter),                                              --last fiscal month number
                LastMonthStart = [db-au-cmdwh].dbo.fn_dtLastMonthStart(@DateCounter),                                                      --last month start date
                LastFiscalMonthStart = [db-au-cmdwh].dbo.fn_dtLastFiscalMonthStart(@DateCounter),                                          --last fiscal month start date
                LastMonthEnd = [db-au-cmdwh].dbo.fn_dtLastMonthEnd(@DateCounter),                                                          --last month end date
                LastFiscalMonthEnd = [db-au-cmdwh].dbo.fn_dtLastFiscalMonthEnd(@DateCounter),                                              --last fiscal month end date
                LastQuarterNum = [db-au-cmdwh].dbo.fn_dtLastQuarterNum(@DateCounter),                                                      --last quarter number
                LastFiscalQuarterNum = [db-au-cmdwh].dbo.fn_dtLastFiscalQuarterNum(@DateCounter),                                          --last fiscal quarter number
                LastQuarterStart = [db-au-cmdwh].dbo.fn_dtLastQuarterStart(@DateCounter),                                                  --last quarter start date
                LastFiscalQuarterStart = [db-au-cmdwh].dbo.fn_dtLastFiscalQuarterStart(@DateCounter),                                      --last fiscal quarter start date
                LastQuarterEnd = [db-au-cmdwh].dbo.fn_dtLastQuarterEnd(@DateCounter),                                                      --last quarter end date
                LastFiscalQuarterEnd = [db-au-cmdwh].dbo.fn_dtLastFiscalQuarterEnd(@DateCounter),                                          --last fiscal quarter end date
                LastYearNum = [db-au-cmdwh].dbo.fn_dtLastYearNum(@DateCounter),                                                            --last year number
                LastFiscalYearNum = [db-au-cmdwh].dbo.fn_dtLastFiscalYearNum(@DateCounter),                                                --last fiscal year number
                LastYearStart = [db-au-cmdwh].dbo.fn_dtLastYearStart(@DateCounter),                                                        --last year start date
                LastFiscalYearStart = [db-au-cmdwh].dbo.fn_dtLastFiscalYearStart(@DateCounter),                                            --last fiscal year start date
                LastYearEnd = [db-au-cmdwh].dbo.fn_dtLastYearEnd(@DateCounter),                                                            --last year end date
                LastFiscalYearEnd = [db-au-cmdwh].dbo.fn_dtLastFiscalYearEnd(@DateCounter),                                                --last fiscal year end date
                Next7DaysStart = [db-au-cmdwh].dbo.fn_dtNext7DaysStart(@DateCounter),                                                      --next 7 days start date
                Next7DaysEnd = [db-au-cmdwh].dbo.fn_dtNext7DaysEnd(@DateCounter),                                                          --next 7 days end date
                NextWeekNum = [db-au-cmdwh].dbo.fn_dtNextWeekNum(@DateCounter),                                                            --next week number
                NextWeekStart = [db-au-cmdwh].dbo.fn_dtNextWeekStart(@DateCounter),                                                        -- Next week start date (Mon-Sun)
                NextWeekEnd = [db-au-cmdwh].dbo.fn_dtNextWeekEnd(@DateCounter),                                                            -- Next week end date (Mon-Sun)
                Next14DaysStart = [db-au-cmdwh].dbo.fn_dtNext14DaysStart(@DateCounter),                                                    --next 14 days start date
                Next14DaysEnd = [db-au-cmdwh].dbo.fn_dtNext14DaysEnd(@DateCounter),                                                        --next 14 days end date
                Next30DaysStart = [db-au-cmdwh].dbo.fn_dtNext30DaysStart(@DateCounter),                                                    --next 30 days start date
                Next30DaysEnd = [db-au-cmdwh].dbo.fn_dtNext30DaysEnd(@DateCounter),                                                        --next 30 days end date
                NextMonthNum = [db-au-cmdwh].dbo.fn_dtNextMonthNum(@DateCounter),                                                          --next month number
                NextFiscalMonthNum = [db-au-cmdwh].dbo.fn_dtNextFiscalMonthNum(@DateCounter),                                              --next fiscal month number
                NextMonthStart = [db-au-cmdwh].dbo.fn_dtNextMonthStart(@DateCounter),                                                      --next month start date
                NextFiscalMonthStart = [db-au-cmdwh].dbo.fn_dtNextFiscalMonthStart(@DateCounter),                                          --next fiscal month start date
                NextMonthEnd = [db-au-cmdwh].dbo.fn_dtNextMonthEnd(@DateCounter),                                                          --next month end date
                NextFiscalMonthEnd = [db-au-cmdwh].dbo.fn_dtNextFiscalMonthEnd(@DateCounter),                                              --next fiscal month end date
                NextQuarterNum = [db-au-cmdwh].dbo.fn_dtNextQuarterNum(@DateCounter),                                                      --next quarter number
                NextFiscalQuarterNum = [db-au-cmdwh].dbo.fn_dtNextFiscalQuarterNum(@DateCounter),                                          --next fiscal quarter number
                NextQuarterStart = [db-au-cmdwh].dbo.fn_dtNextQuarterStart(@DateCounter),                                                  --next quarter start date
                NextFiscalQuarterStart = [db-au-cmdwh].dbo.fn_dtNextFiscalQuarterStart(@DateCounter),                                      --next fiscal quarter start date
                NextQuarterEnd = [db-au-cmdwh].dbo.fn_dtNextQuarterEnd(@DateCounter),                                                      --next quarter end date
                NextFiscalQuarterEnd = [db-au-cmdwh].dbo.fn_dtNextFiscalQuarterEnd(@DateCounter),                                          --next fiscal quarter end date
                NextYearNum = [db-au-cmdwh].dbo.fn_dtNextYearNum(@DateCounter),                                                            --next year number
                NextFiscalYearNum = [db-au-cmdwh].dbo.fn_dtNextFiscalYearNum(@DateCounter),                                                --next fiscal year number
                NextYearStart = [db-au-cmdwh].dbo.fn_dtNextYearStart(@DateCounter),                                                        --next year start date
                NextFiscalYearStart = [db-au-cmdwh].dbo.fn_dtNextFiscalYearStart(@DateCounter),                                            --next fiscal year start date
                NextYearEnd = [db-au-cmdwh].dbo.fn_dtNextYearEnd(@DateCounter),                                                            --next year end date
                NextFiscalYearEnd = [db-au-cmdwh].dbo.fn_dtNextFiscalYearEnd(@DateCounter),                                                --next fiscal year end date
                PreviousDay = [db-au-cmdwh].dbo.fn_dtPreviousDay(@DateCounter),                                                            --previous day date
                CurWeekNum = [db-au-cmdwh].dbo.fn_dtCurWeekNum(@DateCounter),                                                              --current week number
                CurWeekStart = [db-au-cmdwh].dbo.fn_dtCurWeekStart(@DateCounter),                                                          --current week start date (Mon-Sun)
                CurWeekEnd = [db-au-cmdwh].dbo.fn_dtCurWeekEnd(@DateCounter),                                                              --current week end date (Mon-Sun)
                CurMonthNum = [db-au-cmdwh].dbo.fn_dtCurMonthNum(@DateCounter),                                                            --current month number
                CurFiscalMonthNum = [db-au-cmdwh].dbo.fn_dtCurFiscalMonthNum(@DateCounter),                                                --current fiscal month number
                CurMonthStart = [db-au-cmdwh].dbo.fn_dtCurMonthStart(@DateCounter),                                                        --current month start date
                CurFiscalMonthStart = [db-au-cmdwh].dbo.fn_dtCurFiscalMonthStart(@DateCounter),                                            --current fiscal month start date
                CurMonthEnd = [db-au-cmdwh].dbo.fn_dtCurMonthEnd(@DateCounter),                                                            --current month end date
                CurFiscalMonthEnd = [db-au-cmdwh].dbo.fn_dtCurFiscalMonthEnd(@DateCounter),                                                --current fiscal month end date
                CurQuarterNum = [db-au-cmdwh].dbo.fn_dtCurQuarterNum(@DateCounter),                                                        --current quarter number
                CurFiscalQuarterNum = [db-au-cmdwh].dbo.fn_dtCurFiscalQuarterNum(@DateCounter),                                            --current fiscal quarter number
                CurQuarterStart = [db-au-cmdwh].dbo.fn_dtCurQuarterStart(@DateCounter),                                                    --current quarter start date
                CurFiscalQuarterStart = [db-au-cmdwh].dbo.fn_dtCurFiscalQuarterStart(@DateCounter),                                        --current fiscal quarter start date
                CurQuarterEnd = [db-au-cmdwh].dbo.fn_dtCurQuarterEnd(@DateCounter),                                                        --current quarter end date
                CurFiscalQuarterEnd = [db-au-cmdwh].dbo.fn_dtCurFiscalQuarterEnd(@DateCounter),                                            --current fiscal quarter end date
                CurYearNum = [db-au-cmdwh].dbo.fn_dtCurYearNum(@DateCounter),                                                              --current year number
                CurFiscalYearNum = [db-au-cmdwh].dbo.fn_dtCurFiscalYearNum(@DateCounter),                                                  --current fiscal year number
                CurYearStart = [db-au-cmdwh].dbo.fn_dtCurYearStart(@DateCounter),                                                          --current year start date
                CurFiscalYearStart = [db-au-cmdwh].dbo.fn_dtCurFiscalYearStart(@DateCounter),                                              --current fiscal year start date
                CurYearEnd = [db-au-cmdwh].dbo.fn_dtCurFiscalYearStart(@DateCounter),                                                      --current year end date
                CurFiscalYearEnd = [db-au-cmdwh].dbo.fn_dtCurFiscalYearEnd(@DateCounter),                                                  --current fiscal year end date
                MTDNum = [db-au-cmdwh].dbo.fn_dtMTDNum(@DateCounter),                                                                      --month-to-date number
                MTDFiscalNum = [db-au-cmdwh].dbo.fn_dtMTDFiscalNum(@DateCounter),                                                          --month-to-date fiscal number
                MTDStart = [db-au-cmdwh].dbo.fn_dtMTDStart(@DateCounter),                                                                  --month-to-date start date
                MTDFiscalStart = [db-au-cmdwh].dbo.fn_dtMTDFiscalStart(@DateCounter),                                                      --month-to-date fiscal start date
                MTDEnd = [db-au-cmdwh].dbo.fn_dtMTDEnd(@DateCounter),                                                                      --month-to-date end date
                MTDFiscalEnd = [db-au-cmdwh].dbo.fn_dtMTDFiscalEnd(@DateCounter),                                                          --month-to-date fiscal end date
                WTDNum = [db-au-cmdwh].dbo.fn_dtWTDNum(@DateCounter),                                                                      --week-to-date number
                WTDStart = [db-au-cmdwh].dbo.fn_dtWTDStart(@DateCounter),                                                                  --week-to-date start date (Mon-Sun)
                WTDEnd = [db-au-cmdwh].dbo.fn_dtWTDEnd(@DateCounter),                                                                      --week-to-date end date      (Mon-Sun)
                QTDNum = [db-au-cmdwh].dbo.fn_dtQTDNum(@DateCounter),                                                                      --quarter-to-date number
                QTDFiscalNum = [db-au-cmdwh].dbo.fn_dtQTDFiscalNum(@DateCounter),                                                          --quarter-to-date fiscal number
                QTDStart = [db-au-cmdwh].dbo.fn_dtQTDStart(@DateCounter),                                                                  --quarter-to-date start date
                QTDFiscalStart = [db-au-cmdwh].dbo.fn_dtQTDFiscalStart(@DateCounter),                                                      --quarter-to-date fiscal start date
                QTDEnd = [db-au-cmdwh].dbo.fn_dtQTDEnd(@DateCounter),                                                                      --quarter-to-date end date
                QTDFiscalEnd = [db-au-cmdwh].dbo.fn_dtQTDFiscalEnd(@DateCounter),                                                          --quarter-to-date fiscal end date
                YTDNum = [db-au-cmdwh].dbo.fn_dtYTDNum(@DateCounter),                                                                      --year-to-date number
                YTDFiscalNum = [db-au-cmdwh].dbo.fn_dtYTDFiscalNum(@DateCounter),                                                          --year-to-date fiscal number
                YTDStart = [db-au-cmdwh].dbo.fn_dtYTDStart(@DateCounter),                                                                  --year-to-date start date
                YTDFiscalStart = [db-au-cmdwh].dbo.fn_dtYTDFiscalStart(@DateCounter),                                                      --year-to-date fiscal start date
                YTDEnd = [db-au-cmdwh].dbo.fn_dtYTDEnd(@DateCounter),                                                                      --year-to-date end date
                YTDFiscalEnd = [db-au-cmdwh].dbo.fn_dtYTDFiscalEnd(@DateCounter),                                                          --year-to-date fiscal end date
                LYCurMonthNum = [db-au-cmdwh].dbo.fn_dtLYCurMonthNum(@DateCounter),                                                        --last year current month number
                LYCurFiscalMonthNum = [db-au-cmdwh].dbo.fn_dtLYCurFiscalMonthNum(@DateCounter),                                            --last year current fiscal month number
                LYCurMonthStart = [db-au-cmdwh].dbo.fn_dtLYCurMonthStart(@DateCounter),                                                    --last year current month start date
                LYCurFiscalMonthStart = [db-au-cmdwh].dbo.fn_dtLYCurFiscalMonthStart(@DateCounter),                                        --last year current fiscal month start date
                LYCurMonthEnd = [db-au-cmdwh].dbo.fn_dtLYCurMonthEnd(@DateCounter),                                                        --last year current month end date
                LYCurFiscalMonthEnd = [db-au-cmdwh].dbo.fn_dtCurFiscalMonthEnd(@DateCounter),                                              --last year current fiscal month end
                LYYearNum = [db-au-cmdwh].dbo.fn_dtLYYearNum(@DateCounter),                                                                --last year year number
                LYFiscalYearNum = [db-au-cmdwh].dbo.fn_dtLYFiscalYearNum(@DateCounter),                                                    --last year fiscal year number
                LYYeartStart = [db-au-cmdwh].dbo.fn_dtLYYearStart(@DateCounter),                                                           --last year year start date
                LYFiscalYearStart = [db-au-cmdwh].dbo.fn_dtLYFiscalYearStart(@DateCounter),                                                --last year fiscal year start date
                LYYearEnd = [db-au-cmdwh].dbo.fn_dtLYYearEnd(@DateCounter),                                                                --last year year end date
                LYFiscalYearEnd = [db-au-cmdwh].dbo.fn_dtLYFiscalYearEnd(@DateCounter),                                                    --last year fiscal year end date
                LYQuarterNum = [db-au-cmdwh].dbo.fn_dtLYQuarterNum(@DateCounter),                                                          --last year quarter number
                LYFiscalQuarterNum = [db-au-cmdwh].dbo.fn_dtLYFiscalQuarterNum(@DateCounter),                                              --last year fiscal quarter number
                LYQuarterStart = [db-au-cmdwh].dbo.fn_dtLYQuarterStart(@DateCounter),                                                      --last year quarter start date
                LYFiscalQuarterStart = [db-au-cmdwh].dbo.fn_dtLYFiscalQuarterStart(@DateCounter),                                          --last year fiscal quarter start date
                LYQuarterEnd = [db-au-cmdwh].dbo.fn_dtLYQuarterEnd(@DateCounter),                                                          --last year quarter end date
                LYFiscalQuarterEnd = [db-au-cmdwh].dbo.fn_dtLYFiscalQuarterEnd(@DateCounter),                                              --last year fiscal quarter end date
                LYWeekNum = [db-au-cmdwh].dbo.fn_dtLYWeekNum(@DateCounter),                                                                --last year week number
                LYWeekStart = [db-au-cmdwh].dbo.fn_dtLYWeekStart(@DateCounter),                                                            --last year week start date
                LYWeekEnd = [db-au-cmdwh].dbo.fn_dtLYWeekEnd(@DateCounter),                                                                --last year week end date
                LYMTDNum = [db-au-cmdwh].dbo.fn_dtLYMTDNum(@DateCounter),                                                                  --last year month-to-date number
                LYFiscalMTDNum = [db-au-cmdwh].dbo.fn_dtLYFiscalMTDNum(@DateCounter),                                                      --last year fiscal month-to-date number
                LYMTDStart = [db-au-cmdwh].dbo.fn_dtLYMTDStart(@DateCounter),                                                              --last year month-to-date start date
                LYFiscalMTDStart = [db-au-cmdwh].dbo.fn_dtLYFiscalMTDStart(@DateCounter),                                                  --last year fiscal month-to-date start date
                LYMTDEnd = [db-au-cmdwh].dbo.fn_dtLYMTDEnd(@DateCounter),                                                                  --last year month-to-date end date
                LYFiscalMTDEnd = [db-au-cmdwh].dbo.fn_dtLYFiscalMTDEnd(@DateCounter),                                                      --last year fiscal month-to-date end date
                LYQTDNum = [db-au-cmdwh].dbo.fn_dtLYQTDNum(@DateCounter),                                                                  --last year quarter-to-date number
                LYFiscalQTDNum = [db-au-cmdwh].dbo.fn_dtLYFiscalQTDNum(@DateCounter),                                                      --last year fiscal quarter-to-date number
                LYQTDStart = [db-au-cmdwh].dbo.fn_dtLYQTDStart(@DateCounter),                                                              --last year quarter-to-date start date
                LYFiscalQTDStart = [db-au-cmdwh].dbo.fn_dtLYFiscalQTDStart(@DateCounter),                                                  --last year fiscal quarter-to-date start date
                LYQTDEnd = [db-au-cmdwh].dbo.fn_dtLYQTDEnd(@DateCounter),                                                                  --last year quarter-to-date end date
                LYFiscalQTDEnd = [db-au-cmdwh].dbo.fn_dtLYFiscalQTDEnd(@DateCounter),                                                      --last year fiscal quarter-to-date end date
                LYYTDNum = [db-au-cmdwh].dbo.fn_dtLYYTDNum(@DateCounter),                                                                  --last year year-to-date number
                LYFiscalYTDNum = [db-au-cmdwh].dbo.fn_dtLYFiscalYTDNum(@DateCounter),                                                      --last year fiscal year-to-date number
                LYYTDStart = [db-au-cmdwh].dbo.fn_dtLYYTDStart(@DateCounter),                                                              --last year year-to-date start date
                LYFiscalYTDStart = [db-au-cmdwh].dbo.fn_dtLYFiscalYTDStart(@DateCounter),                                                  --last year fiscal year-to-date start date
                LYYTDEnd = [db-au-cmdwh].dbo.fn_dtLYYTDEnd(@DateCounter),                                                                  --last year year-to-date end date
                LYFiscalYTDEnd = [db-au-cmdwh].dbo.fn_dtLYFiscalYTDEnd(@DateCounter)                                                      --last year fiscal year-to-date end date	

	        -- Increment the date counter for next pass thru the loop
	        select @DateCounter = DATEADD(d, 1, @DateCounter)
        end


        /********************************************************************************/
        -- NOTE THE FOLLOWING ARE STANDARD NSW PUBLIC HOLIDAYS
        -- IF THERE ARE NON-STANDARD NSW PUBLIC HOLIDAYS, YOU NEED TO MANUALLY UPDATE THEM
        /********************************************************************************/

        /********************************************************************************/
        --Easter Holidays
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        set isHoliday = 1
        where
        [Date] between @StartDate and @EndDate and
        [Date] = DATEADD(dd,-2,CONVERT(datetime,[db-au-cmdwh].dbo.fn_GetEasterDate(DATEPART(yy,[Date]))))

        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        WHERE
        [Date] between @StartDate and @EndDate and
        [Date] = DATEADD(dd,+1,CONVERT(datetime,[db-au-cmdwh].dbo.fn_GetEasterDate(DATEPART(yy,[Date]))))

        /********************************************************************************/
        --New Year Day
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        SET    isHoliday = 1
        WHERE [Date] IN (SELECT CASE WHEN DATEPART(dw,[Date]) IN (6) THEN
        DATEADD(dd,+2,[Date])
        WHEN DATEPART(dw,[Date]) IN (7) THEN
        DATEADD(dd,+1,[Date]) ELSE [Date] END
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 1 AND DATEPART(dd,[Date]) IN (1))

        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 1 AND DATEPART(dd,[Date]) IN (1)

        /********************************************************************************/
        --Australia Day
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        WHERE [Date] IN (SELECT CASE WHEN DATEPART(dw,[Date]) IN (6) THEN
        DATEADD(dd,+2,[Date])
        WHEN DATEPART(dw,[Date]) IN (7) THEN
        DATEADD(dd,+1,[Date]) ELSE [Date] END
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 1 AND DATEPART(dd,[Date]) IN (26))

        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 1 AND DATEPART(dd,[Date]) IN (26)

        /********************************************************************************/
        --ANZAC Day
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 0
        WHERE [Date] IN (SELECT CASE WHEN DATEPART(dw,[Date]) IN (6) THEN
        DATEADD(dd,+2,[Date])
        WHEN DATEPART(dw,[Date]) IN (7) THEN
        DATEADD(dd,+1,[Date]) ELSE [Date] END
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 4 AND DATEPART(dd,[Date]) IN (25))

        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 4 AND DATEPART(dd,[Date]) IN (25)

        /********************************************************************************/
        --Queens Birthday
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        WHERE [Date] IN (SELECT (MIN([Date]) + 7) FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 6 AND DATEPART(dw,[Date]) = 1
        GROUP BY DATEPART(yy,[Date]))

        /********************************************************************************/
        --Bank Holiday
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        WHERE [Date] IN (SELECT MIN([Date]) FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 8 AND DATEPART(dw,[Date]) = 1
        GROUP BY DATEPART(yy,[Date]))

        /********************************************************************************/
        --Labour Day
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        WHERE [Date] IN (SELECT MIN([Date]) FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 10 AND DATEPART(dw,[Date]) = 1
        GROUP BY DATEPART(yy,[Date]))

        /********************************************************************************/
        --Christmas & Boxing Day
        /********************************************************************************/
        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        WHERE [Date] IN (SELECT CASE WHEN DATEPART(dw,[Date]) IN (7,6) THEN
        DATEADD(dd,+2,[Date]) ELSE [Date] END
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 12 AND DATEPART(dd,[Date]) IN (25,26))

        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        WHERE [Date] IN (SELECT CASE WHEN DATEPART(dw,[Date]) IN (6) THEN
        DATEADD(dd,+2,[Date])
        WHEN DATEPART(dw,[Date]) IN (7) THEN
        DATEADD(dd,+1,[Date]) ELSE [Date] END
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 12 AND DATEPART(dd,[Date]) IN (25,26))


        update [db-au-star].dbo.Dim_Date
        SET isHoliday = 1
        FROM [db-au-star].dbo.Dim_Date
        WHERE [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 12 AND DATEPART(dd,[Date]) IN (25)

        update [db-au-star].dbo.Dim_Date
        set isHoliday = 1
        from [db-au-star].dbo.Dim_Date
        where [Date] between @StartDate and @EndDate and DATEPART(mm,[Date]) = 12 AND DATEPART(dd,[Date]) IN (26)



        /*****************************************************/
        --Update isWorkDay
        /*****************************************************/
        update [db-au-star].dbo.Dim_Date
        set isWorkDay = case when isWeekday = 1 and isHoliday = 0 then 1
					         else 0
				        end
        where 
	        [date] between @StartDate and @EndDate

        /*****************************************************/
        --Update Total_Work_Days
        /*****************************************************/
        update [db-au-star].dbo.Dim_Date
        set Total_Work_Days = d.Total_Work_Days
        from
	        [db-au-star].dbo.Dim_Date a
	        join
	        (
		        select 
                    Calendar_Year_Month, 
                    --sum(b.isWeekday) - sum(b.isHoliday) as Total_Work_Days
                    sum
                    (
                        case
                            when b.isHoliday = 1 then 0
                            when b.isWeekday = 1 then 1
                            else 0
                        end
                    ) Total_Work_Days
		        from [db-au-star].dbo.Dim_Date b
	            where b.[Date] between b.CurMonthStart and b.CurMonthEnd
	            group by Calendar_Year_Month
	        ) d on a.[Calendar_Year_Month] = d.[Calendar_Year_Month]


        /*****************************************************/
        --Update Remaining_Work_Days
        /*****************************************************/
        update [db-au-star].dbo.Dim_Date
        set Remaining_Work_Days = 
            a.Total_Work_Days - 
            (
                select 
                    --sum(x.isWeekday - x.isHoliday) as RemainingWorkDays
                    sum
                    (
                        case
                            when x.isHoliday = 1 then 0
                            when x.isWeekday = 1 then 1
                            else 0
                        end
                    ) RemainingWorkDays
				from [db-au-star].dbo.Dim_Date x
				where x.[Date] between a.CurMonthStart and a.[Date]
            )
        from 
	        [db-au-star].dbo.Dim_Date a
        where 
	        a.[date] between @StartDate and @EndDate
	    
	    
	    
	    
        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished'

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
