USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtCurQuarterNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtCurQuarterNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtCurQuarterNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the current quarter number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select datepart(quarter,@date)
  )
end
GO
