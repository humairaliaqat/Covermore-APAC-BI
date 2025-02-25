USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastWeekendStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLastWeekendStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastWeekendStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns last weekend start date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select case when datepart(WeekDay,@date) = 1 then convert(datetime,convert(varchar(10),dateadd(d,-8,@date),120))
				when datepart(WeekDay,@date) = 2 then convert(datetime,convert(varchar(10),dateadd(d,-2,@date),120))
				when datepart(WeekDay,@date) = 3 then convert(datetime,convert(varchar(10),dateadd(d,-3,@date),120))
				when datepart(WeekDay,@date) = 4 then convert(datetime,convert(varchar(10),dateadd(d,-4,@date),120))
				when datepart(WeekDay,@date) = 5 then convert(datetime,convert(varchar(10),dateadd(d,-5,@date),120))
				when datepart(WeekDay,@date) = 6 then convert(datetime,convert(varchar(10),dateadd(d,-6,@date),120))
				when datepart(WeekDay,@date) = 7 then convert(datetime,convert(varchar(10),dateadd(d,-7,@date),120))
			end
  )
end
GO
