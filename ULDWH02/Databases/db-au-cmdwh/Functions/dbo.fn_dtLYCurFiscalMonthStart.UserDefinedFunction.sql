USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLYCurFiscalMonthStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLYCurFiscalMonthStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLYCurFiscalMonthStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Last year Current fiscal month start date based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select convert(datetime,convert(varchar(8),dateadd(year,-1,@date),120) + '01')
  )
end
GO
