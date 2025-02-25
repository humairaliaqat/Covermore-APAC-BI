USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_ReportingPeriods]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Dane Murray
-- Create date: 2018-08-13
-- Description:	To return the Current Period and Last year Same Period for CBA reporting purposes
-- =============================================
CREATE FUNCTION [dbo].[UDF_ReportingPeriods] 
(	
	-- Add the parameters for the function here
	@Start datetime, 
	@End datetime,
	@PreviousPeriods int = 6
)
RETURNS @periods TABLE (
	PeriodText varchar(50),
	PeriodDateNum int,
	CurrentPeriod bit,
	[Date] date,
	PeriodStartDate date,
	PeriodEndDate date,
	SortOrder int

)
AS
Begin
	-- chop off time component
	SELECT @Start = CAST(@Start as date),  @End = CAST(@End as date)

	;with DatePeriods as (
		select 'Current Period' as PeriodText, C.Date
		from [ULDWH02].[db-au-cmdwh].dbo.Calendar C
		where C.Date between @Start and @End
		union all
		select 'Last Year at Current Period' as PeriodText, C.Date
		from [ULDWH02].[db-au-cmdwh].dbo.Calendar C
		where C.Date between DateAdd(year, -1, @Start) and DateAdd(year, -1, @End)
	)
	insert into @periods(PeriodText, PeriodDateNum, CurrentPeriod, [Date], PeriodStartDate, PeriodEndDate, SortOrder)
	select	PeriodText, 
			row_number() over(partition by PeriodText order by Date) as PeriodDateNum,
			CASE PeriodText WHEN 'Current Period' THEN 1 ELSE 0 END,
			Date, 
			min(Date) over(Partition by PeriodText),
			max(Date) over(Partition by PeriodText),
			0 as SortOrder
	from DatePeriods

	DECLARE @MaxLoopCount int,
			@CurrentLoopCount int,
			@Range float,
			@CurrentPeriodStart datetime,
			@CurrentPeriodEnd datetime,
			@rangeType varchar(10)
	
	if(Day(@Start) <> 1 OR @End <> EOMONTH(@End,0))
	BEGIN
		select	@Range = DATEDIFF(Day, @Start, @End) + 1,
				@rangeType = 'day'
		
		--if(@Range = 1)
		--	set @PreviousPeriods = 30
	END
	ELSE 
	BEGIN
		select	@Range = DATEDIFF(MONTH, @Start, @End) + CASE When @End = EOMONTH(@End,0) THEN 1 ELSE 0 END,
				@RangeType = 'month'
	END


	SET @MaxLoopCount = @PreviousPeriods - 1

	SET @Start = case @RangeType 
						WHEN 'Day' THEN DATEADD(day, @Range * -1 * @MaxLoopCount, @Start) 
						ELSE DATEADD(month, @Range * -1 * @MaxLoopCount, @Start) 
				 END
	
	SET @CurrentPeriodStart = @Start
	
	SET @CurrentLoopCount = 0
	
	-- Create Period
	WHILE @CurrentPeriodStart <= @End AND @CurrentLoopCount <= @MaxLoopCount
	BEGIN
		SET @CurrentPeriodEnd = case @RangeType 
						WHEN 'Day' THEN DATEADD(day, @Range, @CurrentPeriodStart)
						ELSE DATEADD(month, @Range, @CurrentPeriodStart) END

		INSERT INTO @Periods (PeriodText, PeriodDateNum, CurrentPeriod, [Date], PeriodStartDate, PeriodEndDate, SortOrder)
		SELECT 'History Periods' PeriodText, 
				row_number() over(order by Date) as PeriodDateNum,
				0,
				Date, 
				min(Date) over(Partition by @CurrentPeriodStart),
				max(Date) over(Partition by @CurrentPeriodStart),
				@CurrentLoopCount as SortOrder--@MaxLoopCount - @CurrentLoopCount + 1, @CurrentPeriodStart, DATEADD(n, -1, @CurrentPeriodEnd), @range
		from [ULDWH02].[db-au-cmdwh].dbo.Calendar C
		where C.Date >= @CurrentPeriodStart and
		C.Date < @CurrentPeriodEnd
	
		SET @CurrentPeriodStart = @CurrentPeriodEnd
		
		SET @CurrentLoopCount = @CurrentLoopCount + 1 
	END

	return;
end
GO
