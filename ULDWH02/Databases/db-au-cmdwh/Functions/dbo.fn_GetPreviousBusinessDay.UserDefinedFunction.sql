USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetPreviousBusinessDay]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetPreviousBusinessDay] (@date datetime)
returns datetime
as

--this date function assumes Sunday is the first day of week (SQL Server default)

begin
	declare @PrevDay datetime

	--subtract a single day
	select @PrevDay = dateadd(d,-1,@date)
	
	select @PrevDay = case datepart(dw,@PrevDay) when 1 then dateadd(d,-2,@PrevDay)
												 when 7 then dateadd(d,-1,@PrevDay)
												 else @PrevDay
					  end

	--look up holiday dates in Calendar table, and loop to the next business weekday
	while exists(select [date] from [db-au-cmdwh].dbo.Calendar where isHoliday = 1 and isWeekday = 1 and [date] = @PrevDay)
	begin
		select @PrevDay = dateadd(d,-1,@PrevDay)
		
		select @PrevDay = case datepart(dw,@PrevDay) when 1 then dateadd(d,-2,@PrevDay)
													 when 7 then dateadd(d,-1,@PrevDay)
													 else @PrevDay
						  end
	end
	
	--return the previous business date
	return @PrevDay
end
GO
