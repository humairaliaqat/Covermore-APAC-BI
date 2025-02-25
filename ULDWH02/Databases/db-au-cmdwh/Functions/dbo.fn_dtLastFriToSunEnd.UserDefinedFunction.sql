USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastFriToSunEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLastFriToSunEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastFriToSunEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the last friday to Sunday end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case datepart(dw,@date) when 1 then dateadd(d,-7,@date)			--Sunday
								   when 2 then dateadd(d,-1,@date)			--Monday
								   when 3 then dateadd(d,-2,@date)			--Tuesday
								   when 4 then dateadd(d,-3,@date)			--Wednesday
								   when 5 then dateadd(d,-4,@date)			--Thursday
								   when 6 then dateadd(d,-5,@date)			--Friday
								   when 7 then dateadd(d,-6,@date)			--Saturday
		   end
  )			
end
GO
