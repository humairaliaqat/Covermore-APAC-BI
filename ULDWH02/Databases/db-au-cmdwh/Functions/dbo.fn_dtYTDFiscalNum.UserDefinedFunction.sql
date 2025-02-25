USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtYTDFiscalNum]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtYTDFiscalNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtYTDFiscalNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the year-to-date fiscal number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case when datepart(month,@date) between 7 and 12 then datepart(year,dateadd(year,1,@date))
						    else datepart(year,@date)
                      end
  )
end
GO
