USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNext14DaysEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtNext14DaysEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNext14DaysEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next 14 days end date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select dateadd(d,14,@date)
  )
end
GO
