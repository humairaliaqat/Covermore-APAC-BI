USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast3MonthToDateEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLast3MonthToDateEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast3MonthToDateEnd
-- Author:			Leonardus Setyabudi
-- Dependencies:	
-- Description:		This function returns the last 3 month end date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select dateadd(d, -1, convert(varchar(10), @date, 120))
  )
end
GO
