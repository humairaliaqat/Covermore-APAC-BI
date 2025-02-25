USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastSatToFriEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_dtLastSatToFriEnd] (@date datetime)
returns datetime
as


/*****************************************************************************/
-- Title:			dbo.fn_dtLastSatToFriEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last Saturday-to-Friday end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case datepart(dw,@date) when 1 then dateadd(d,-2,@date)			--Sunday
								   when 2 then dateadd(d,-3,@date)			--Monday
								   when 3 then dateadd(d,-4,@date)			--Tuesday
								   when 4 then dateadd(d,-5,@date)			--Wednesday
								   when 5 then dateadd(d,-6,@date)			--Thursday
								   when 6 then dateadd(d,-7,@date)			--Friday
								   when 7 then dateadd(d,-1,@date)			--Saturday
		   end
  )			
end
GO
