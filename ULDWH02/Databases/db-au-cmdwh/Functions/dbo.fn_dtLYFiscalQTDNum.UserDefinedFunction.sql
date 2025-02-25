USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYFiscalQTDNum]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLYFiscalQTDNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYFiscalQTDNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year fiscal quarter-to-date number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case datepart(quarter,dateadd(year,-1,@date))	when 1 then 3
															when 2 then 4
															when 3 then 1
															when 4 then 2
			end
  )
end
GO
