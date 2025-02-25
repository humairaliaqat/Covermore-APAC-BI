USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYQuarterEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLYQuarterEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYQuarterEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year quarter end based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select dateadd(quarter,datediff(quarter,-1,dateadd(year,-1,@date)),-1)
  )
end
GO
