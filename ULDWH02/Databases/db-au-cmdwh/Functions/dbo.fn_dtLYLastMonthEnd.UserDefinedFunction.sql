USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYLastMonthEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLYLastMonthEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYLastMonthEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year last month end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select dateadd(d,-1,dateadd(m,1,convert(datetime,convert(varchar(8),dateadd(year,-1,dateadd(month,-1,@date)),120) + '01')))
  )
end
GO
