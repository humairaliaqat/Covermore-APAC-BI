USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYLastWeekEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLYLastWeekEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYLastWeekEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year last week end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select DATEADD(dd, 8-(DATEPART(dw, dateadd(week,-1,dateadd(year,-1,@date)))), dateadd(week,-1,dateadd(year,-1,@date)))
  )
end
GO
