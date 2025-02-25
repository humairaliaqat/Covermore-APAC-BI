USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtYTDNum]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtYTDNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtYTDNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the year-to-date number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select datepart(year,@date)
  )
end
GO
