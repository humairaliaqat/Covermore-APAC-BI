USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextMonthEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextMonthEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextMonthEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next month end date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select dateadd(d,-1,convert(datetime,convert(varchar(8),dateadd(m,2,@date),120) + '01'))
  )
end
GO
