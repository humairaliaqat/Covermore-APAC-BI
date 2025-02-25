USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtCurWeekEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtCurWeekEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtCurWeekEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the current week end date based on the input date (sun-sat)
--
/*****************************************************************************/


begin
  return
  (
	select case datepart(dw,@date)	when 1 then dateadd(d,6,@date)
									when 2 then dateadd(d,5,@date)
									when 3 then dateadd(d,4,@date)
									when 4 then dateadd(d,3,@date)
									when 5 then dateadd(d,2,@date)
									when 6 then dateadd(d,1,@date)
									when 7 then dateadd(d,0,@date)
			end
  )
end
GO
