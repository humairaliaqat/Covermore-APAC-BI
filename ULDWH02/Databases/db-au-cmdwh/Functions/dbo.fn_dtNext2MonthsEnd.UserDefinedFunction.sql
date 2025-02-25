USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNext2MonthsEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNext2MonthsEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNext2MonthsEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next 3 months end date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select dateadd(d,-1,convert(datetime,convert(varchar(8),dateadd(m,3,@date),120) + '01'))
  )
end
GO
