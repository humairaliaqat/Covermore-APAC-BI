USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastMonthNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLastMonthNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastMonthNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the last month number based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select datepart(month,dateadd(m,-1,@date))
  )
end
GO
