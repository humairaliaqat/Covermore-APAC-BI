USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast21DaysEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLast21DaysEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast21DaysEnd
-- Author:			Saurabh Date
-- Dependancies:	
-- Description:		This function returns the last 21 days end date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select dateadd(d,-1,@date)
  )
end
GO
