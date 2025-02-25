USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastThuToWedStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLastThuToWedStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastThuToWedStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the last Thursday to Wedneday start date based on the input date 
--
/*****************************************************************************/



begin
  return
  (
	select case datepart(dw,@date) when 1 then dateadd(d,-10,@date)			--Sunday
								   when 2 then dateadd(d,-11,@date)			--Monday
								   when 3 then dateadd(d,-12,@date)			--Tuesday
								   when 4 then dateadd(d,-13,@date)			--Wednesday
								   when 5 then dateadd(d,-7,@date)			--Thursday
								   when 6 then dateadd(d,-8,@date)			--Friday
								   when 7 then dateadd(d,-9,@date)			--Saturday
		   end
  )			
end

GO
