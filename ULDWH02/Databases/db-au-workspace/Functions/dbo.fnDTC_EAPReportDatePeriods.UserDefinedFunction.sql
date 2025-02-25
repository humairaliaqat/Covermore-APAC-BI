USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [dbo].[fnDTC_EAPReportDatePeriods]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnDTC_EAPReportDatePeriods] 
(
	-- Add the parameters for the function here
	@StartDate datetime, 
	@EndDate DateTime,
	@NumOfPeriods int = 6
)
RETURNS 
@Periods TABLE 
(
	-- Add the column definitions for the TABLE variable here
	id int,
	PeriodStart datetime, 
	PeriodEnd datetime,
	[range] int
)
AS
BEGIN
	/*
	DECLARE @StartDate datetime, 
			@EndDate DateTime,
			@NumOfPeriods int

	select @StartDate = '20160801', @EndDate = '20160831', @NumOfPeriods = 6
	*/
	DECLARE @MaxLoopCount int,
			@CurrentLoopCount int,
			@Range float,
			@CurrentPeriodStart datetime,
			@CurrentPeriodEnd datetime,
			@rangeType varchar(10)
	
	-- chop off time component
	SET @StartDate = [dbo].[DateOnly](@StartDate)
	SET @EndDate = [dbo].[DateOnly](@EndDate)
	
	if(Day(@StartDate) <> 1 OR @EndDate <> [dbo].[DateOnly](DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@EndDate)+1,0))))
	BEGIN
		select @Range = DATEDIFF(Day, @StartDate, @EndDate) + 1,
				@rangeType = 'day'
	END
	ELSE 
	BEGIN
		select @Range = DATEDIFF(MONTH, @StartDate, @EndDate) + CASE When @EndDate = [dbo].[DateOnly](DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@EndDate)+1,0))) THEN 1 ELSE 0 END,
				@RangeType = 'month'
	END

	SET @MaxLoopCount = @NumOfPeriods -1

	SET @StartDate = case @RangeType 
						WHEN 'Day' THEN DATEADD(day, @Range * -1 * @MaxLoopCount, @StartDate) 
					ELSE DATEADD(month, @Range * -1 * @MaxLoopCount, @StartDate) END
	
	--select @RangeType, @StartDate, @Range			
	
	SET @CurrentPeriodStart = @StartDate
	
	SET @CurrentLoopCount = 0
	
	-- Create Period
	WHILE @CurrentPeriodStart < @EndDate AND @CurrentLoopCount <= @MaxLoopCount
	BEGIN
		SET @CurrentPeriodEnd = case @RangeType 
						WHEN 'Day' THEN DATEADD(day, @Range, @CurrentPeriodStart)
						ELSE DATEADD(month, @Range, @CurrentPeriodStart) END

		INSERT INTO @Periods (id, PeriodStart, PeriodEnd, [range])
		SELECT @MaxLoopCount - @CurrentLoopCount + 1, @CurrentPeriodStart, DATEADD(n, -1, @CurrentPeriodEnd), @range
	
		SET @CurrentPeriodStart = @CurrentPeriodEnd
		
		SET @CurrentLoopCount = @CurrentLoopCount + 1 
	END
	
	RETURN 
END

GO
