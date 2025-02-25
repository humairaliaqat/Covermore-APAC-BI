USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtMTDNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtMTDNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtMTDNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the month-to-date number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select datepart(month,@date)
  )
end
GO
