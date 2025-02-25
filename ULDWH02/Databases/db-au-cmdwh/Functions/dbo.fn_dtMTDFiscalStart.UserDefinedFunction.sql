USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtMTDFiscalStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtMTDFiscalStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtMTDFiscalStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the month-to-date fiscal start date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select convert(datetime,convert(varchar(8),dateadd(d,-1,@date),120) + '01')
  )
end
GO
