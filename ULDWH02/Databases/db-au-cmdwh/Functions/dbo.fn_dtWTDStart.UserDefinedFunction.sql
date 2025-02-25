USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtWTDStart]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtWTDStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtWTDStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the week-to-date start date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select @date-(datepart(dw,@date-1)-1)
  )
end
GO
