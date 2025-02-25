USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextWeekEnd]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextWeekEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextWeekEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next week end date based on the input date (mon-sun)
--
/*****************************************************************************/

begin
  return
  (
	select case datepart(dw,@date)	when 1 then dateadd(d,13,@date)
									when 2 then dateadd(d,12,@date)
									when 3 then dateadd(d,11,@date)
									when 4 then dateadd(d,10,@date)
									when 5 then dateadd(d,9,@date)
									when 6 then dateadd(d,8,@date)
									when 7 then dateadd(d,7,@date)
			end
  )
end
GO
