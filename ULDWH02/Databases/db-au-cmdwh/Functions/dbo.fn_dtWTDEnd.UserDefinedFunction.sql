USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtWTDEnd]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtWTDEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtWTDEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the week-to-date end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case when datepart(dw,@date) = 2 then @date								--Monday
	            else convert(datetime,convert(varchar(10),dateadd(d,-1,@date),120))
		   end
  )		
end
GO
