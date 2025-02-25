USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYQuarterNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLYQuarterNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYQuarterNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year quarter number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select datepart(quarter,dateadd(year,-1,@date))
  )
end
GO
