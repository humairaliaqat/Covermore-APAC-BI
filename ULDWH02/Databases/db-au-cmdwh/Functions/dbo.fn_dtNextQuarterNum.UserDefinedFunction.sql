USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextQuarterNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtNextQuarterNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextQuarterNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next quarter number based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select datepart(quarter,dateadd(quarter,1,@date))
  )
end
GO
