USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtCurMonthNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtCurMonthNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtCurMonthNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the current month number based on the input date (sun-sat)
--
/*****************************************************************************/


begin
  return
  (
	select datepart(month,@date)
  )
end
GO
