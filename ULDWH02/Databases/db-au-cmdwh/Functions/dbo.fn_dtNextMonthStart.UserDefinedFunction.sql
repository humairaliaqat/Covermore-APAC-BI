USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextMonthStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextMonthStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextMonthStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the next month start date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select convert(datetime,convert(varchar(8),dateadd(month,1,@date),120) + '01')
  )
end
GO
