USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtCurFiscalYearNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtCurFiscalYearNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtCurFiscalYearNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the current fiscal year number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case when datepart(month,@date) between 7 and 12 then datepart(year,@date) + 1
				else datepart(year,@date)
		   end
  )
end
GO
