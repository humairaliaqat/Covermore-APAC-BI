USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastQuarterStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLastQuarterStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastQuarterStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the last quarter start date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select dateadd(quarter,datediff(quarter,0,dateadd(quarter,-1,@date)),0)
  )
end
GO
