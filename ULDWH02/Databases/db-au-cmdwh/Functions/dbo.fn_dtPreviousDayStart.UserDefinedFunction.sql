USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtPreviousDayStart]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtPreviousDayStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtPreviousDayStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the previous day start date based on the input date
--
/*****************************************************************************/

begin
  return
  (
	select convert(datetime,convert(varchar(10),dateadd(d,-1,@date),120))
  )
end
GO
