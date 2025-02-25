USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtQTDNum]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtQTDNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtQTDNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Quarter-to-date number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select datepart(quarter,@date)
  )
end
GO
