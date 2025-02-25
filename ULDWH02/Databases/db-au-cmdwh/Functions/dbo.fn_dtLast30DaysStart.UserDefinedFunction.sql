USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast30DaysStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLast30DaysStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast30DaysStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the last 30 days start date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select dateadd(d,-30,@date)
  )
end
GO
