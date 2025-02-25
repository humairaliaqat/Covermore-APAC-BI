USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast7DaysStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLast7DaysStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast7DaysStart
-- Author:			Linus Tor
-- Dependancies:	rptdb.dbo.rptCalendar
-- Description:		This function returns the start date of the last 
--					7 days based on the input date
/*****************************************************************************/

begin
  return(select dateadd(d,-7,@date))
end
GO
