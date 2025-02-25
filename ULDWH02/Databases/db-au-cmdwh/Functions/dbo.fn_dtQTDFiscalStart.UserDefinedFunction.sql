USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtQTDFiscalStart]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtQTDFiscalStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtQTDFiscalStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Quarter-to-date fiscal start date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select dateadd(quarter,datediff(quarter,0,dateadd(d,-1,@date)),0)
  )
end
GO
