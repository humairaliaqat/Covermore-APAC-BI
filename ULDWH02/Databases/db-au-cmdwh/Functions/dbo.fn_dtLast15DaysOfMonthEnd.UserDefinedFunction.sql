USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast15DaysOfMonthEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create function [dbo].[fn_dtLast15DaysOfMonthEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast14DaysOfMonth
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the last 14 days of month based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select dateadd(d,-1,dateadd(m,1,convert(varchar(8),@date,120)+'01'))
  )
end
GO
