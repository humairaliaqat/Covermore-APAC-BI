USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtYTDFiscalEnd]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtYTDFiscalEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtYTDFiscalEnd
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the year-to-date fiscal end date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select convert(datetime,convert(varchar(10),dateadd(d,-1,@date),120))
  )
end
GO
