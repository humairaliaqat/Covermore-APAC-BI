USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetWorkDaysBetween]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_GetWorkDaysBetween] (@StartDate datetime, @EndDate datetime)
returns int
as

/********************************************************************************************
-- returns number of business days between given dates
-- (negative values indicates then the second date is earlier than the first one)
**********************************************************************************************/

begin
	declare @date1 datetime
	declare @date2 datetime
	declare @tempdate datetime
	declare @day int
	declare @count int
	declare @multiplier int
	
	if @StartDate <= @EndDate
	begin
		select @date1 = convert(datetime,convert(varchar(10),@StartDate,120))
		select @date2 = convert(datetime,convert(varchar(10),@EndDate,120))
		select @multiplier = 1
	end
	else
	begin
		select @date2 = convert(datetime,convert(varchar(10),@StartDate,120))
		select @date1 = convert(datetime,convert(varchar(10),@EndDate,120))
		select @multiplier = -1
	end

	select @tempdate = @date1
	select @count = 0

	--process till tempdate becomes date2
	while (datediff(dd,@tempdate,@date2) >= 0)
	begin
		select @day = datepart(dw,@tempdate)

		if (@day <> 1 AND @day <> 7)					--if it is not a Saturday or a Sunday			
			if not exists(select * from [db-au-cmdwh].dbo.Calendar where isHoliday = 1 and isWeekend = 0 and [date] = @tempdate) --if it is not a Public Holiday
				select @count = @count + 1				--Increment @tempdate by 1 day
				
		select @tempdate = dateadd(dd,1,@tempdate)
	end
	
	return @count * @multiplier
end
GO
