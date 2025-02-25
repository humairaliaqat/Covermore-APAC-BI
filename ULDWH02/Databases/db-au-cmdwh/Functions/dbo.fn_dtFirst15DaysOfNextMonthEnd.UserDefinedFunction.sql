USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtFirst15DaysOfNextMonthEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[fn_dtFirst15DaysOfNextMonthEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast14DaysOfMonth
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the first 15 days of next month based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select dateadd(day,14,dateadd(m,1,convert(varchar(8),@date,120)+'01'))
  )
end
GO
