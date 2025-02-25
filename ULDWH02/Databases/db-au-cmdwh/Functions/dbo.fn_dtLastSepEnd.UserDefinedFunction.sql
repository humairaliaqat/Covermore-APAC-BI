USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastSepEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLastSepEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastSepEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns last September end date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select case when month(@date) <= 9 then dateadd(d,-1,dateadd(m,1,convert(datetime,convert(varchar(5),dateadd(year,-1,@date),120) + '09-01')))
				else dateadd(d,-1,dateadd(m,1,convert(datetime,convert(varchar(5),@date,120) + '09-01')))
		   end
  )
end
GO
