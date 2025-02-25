USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_AddWorkDays]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_AddWorkDays] (@date datetime, @DaysToAdd int)
returns datetime
as

/********************************************************************************************
-- returns date after given number of work days
-- uses functions: dbo.fn_GetNextBusinessDay for addition
--				   dbo.fn_GetPreviousBusinessDay for subtraction
**********************************************************************************************/

begin
	declare @NextDay datetime
	declare @Counter int
	
	if @DaysToAdd > 0
	begin
		select @Counter = 1
		
		-- Drop the time part and initialize the Return Variable
		select @NextDay = convert(datetime,convert(varchar(10),@date,120))
		while @Counter <= @DaysToAdd
		begin
			select @NextDay = dbo.fn_GetNextBusinessDay(@NextDay)
			select @Counter = @Counter+1
		end
	end
	else
	begin
		select @Counter = abs(@DaysToAdd)

		-- Drop the time part and initialize the Return Variable
		select @NextDay = convert(datetime,convert(varchar(10),@date,120))

		while @Counter > 0
		begin
			select @NextDay = dbo.fn_GetPreviousBusinessDay(@NextDay)
			select @Counter = @Counter-1
		end
	end

	return @NextDay
end
GO
