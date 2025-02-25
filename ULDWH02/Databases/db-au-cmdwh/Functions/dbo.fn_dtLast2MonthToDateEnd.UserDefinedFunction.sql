USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast2MonthToDateEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLast2MonthToDateEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast2MonthToDateEnd
-- Author:			Linus Tor
-- Dependencies:	
-- Description:		This function returns the last 2 month end date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select dateadd(d, -1, convert(varchar(10), @date, 120))
  )
end
GO
