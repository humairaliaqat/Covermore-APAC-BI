USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextFiscalQuarterEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextFiscalQuarterEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextFiscalQuarterEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next fiscal quarter end date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select dateadd(quarter,datediff(quarter,-1,dateadd(quarter,1,@date)),-1)
  )
end
GO
