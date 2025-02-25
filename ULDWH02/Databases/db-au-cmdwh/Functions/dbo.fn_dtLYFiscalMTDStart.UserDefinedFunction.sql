USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYFiscalMTDStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLYFiscalMTDStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYFiscalMTDStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year fiscal month-to-date start date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select convert(datetime,convert(varchar(8),dateadd(year,-1,dateadd(d,-1,@date)),120) + '01')
  )
end
GO
