USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetNextBusinessDay]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_GetNextBusinessDay] (@date datetime)
returns datetime
as

--This date function assumes Sunday is first day of week (SQL Server default)

begin
	declare @NextDay datetime
	select @NextDay = dateadd(d,1,@date)	--add a single day

	--move to next weekday if it falls on Sunday or Saturday
	select @NextDay = case datepart(dw,@NextDay) when 1 then dateadd(d,1,@NextDay)
												 when 7 then dateadd(d,2,@NextDay)
												 else @NextDay
					  end

	--look up the holiday dates in Calendar table, and loop to the next business weekday
	while exists(select [date] from [db-au-cmdwh].dbo.Calendar where isHoliday = 1 and isWeekday = 1 and [date] = @NextDay)
	begin
		select @NextDay = dateadd(d,1,@NextDay)
		select @NextDay = case datepart(dw,@NextDay) when 1 then dateadd(d,1,@NextDay)
													 when 7 then dateadd(d,2,@NextDay)
													 else @NextDay
						  end
	end

	--return the next business date
	return @NextDay
END
GO
