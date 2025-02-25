USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYCurMonthEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLYCurMonthEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYCurMonthEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year Current month end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select dateadd(d,-1,dateadd(m,1,convert(datetime,convert(varchar(8),dateadd(year,-1,@date),120) + '01')))
  )
end
GO
