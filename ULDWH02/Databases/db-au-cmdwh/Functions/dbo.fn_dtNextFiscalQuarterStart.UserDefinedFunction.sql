USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextFiscalQuarterStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextFiscalQuarterStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextFiscalQuarterStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next fiscal quarter start date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select dateadd(quarter,datediff(quarter,0,dateadd(quarter,1,@date)),0)
  )
end
GO
