USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextFiscalYearStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextFiscalYearStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextFiscalYearStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next fiscal year start date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select case when datepart(month,@date) between 7 and 12 then convert(datetime,convert(varchar(5),dateadd(year,1,@date),120) + '07-01')
				else convert(datetime,convert(varchar(5),dateadd(year,0,@date),120) + '07-01')
		   end
  )
end
GO
