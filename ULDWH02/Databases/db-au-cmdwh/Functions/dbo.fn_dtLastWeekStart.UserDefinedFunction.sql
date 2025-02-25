USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastWeekStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLastWeekStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastWeekStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the last week start date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select DATEADD(dd, -(DATEPART(dw, dateadd(week,-1,@date))-2), dateadd(week,-1,@date))
  )
end
GO
