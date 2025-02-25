USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtCurFiscalYearStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtCurFiscalYearStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtCurFiscalYearStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the current fiscal year start date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case when datepart(month,@date) between 7 and 12 then convert(datetime,convert(varchar(5),@date,120) + '07-01')
                else convert(datetime,convert(varchar(5),dateadd(year,-1,@date),120) + '07-01')
		   end
  )
end
GO
