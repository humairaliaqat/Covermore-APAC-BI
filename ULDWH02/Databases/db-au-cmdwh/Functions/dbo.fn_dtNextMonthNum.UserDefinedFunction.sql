USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextMonthNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtNextMonthNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextMonthNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next month number based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select datepart(month,dateadd(month,1,@date))
  )
end
GO
