USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYFiscalYTDStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLYFiscalYTDStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYFiscalYTDStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year fiscal year-to-date start date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case when datepart(month,dateadd(year,-1,dateadd(d,-1,@date))) between 7 and 12 then convert(datetime,convert(varchar(5),dateadd(year,-1,dateadd(d,-1,@date)),120) + '07-01')
				else convert(datetime,convert(varchar(5),dateadd(year,-2,@date),120) + '07-01')
			end
  )
end
GO
