USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextFiscalMonthEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextFiscalMonthEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextFiscalMonthEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next fiscal month end date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select dateadd(d,-1,convert(datetime,convert(varchar(8),dateadd(m,2,@date),120) + '01'))
  )
end
GO
