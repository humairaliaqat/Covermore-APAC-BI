USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYFiscalYearEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLYFiscalYearEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYFiscalYearEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year fiscal year end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case when datepart(month,dateadd(year,-1,@date)) between 7 and 12 then convert(datetime,convert(varchar(5),@date,120) + '06-30')
				else convert(datetime,convert(varchar(5),dateadd(year,-1,@date),120) + '06-30')
		   end
  )
end
GO
