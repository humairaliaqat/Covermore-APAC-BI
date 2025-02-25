USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYMTDMonthNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLYMTDMonthNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYMTDMonthNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year month-to-date Month number date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select datepart(month,dateadd(year,-1,@date))
  )
end
GO
