USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast2YearEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLast2YearEnd] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLast2YearEnd
-- Author:			Leonardus Setyabudi
-- Dependancies:	
-- Description:		This function returns the Last 2 year end date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select convert(datetime,convert(varchar(5),dateadd(year,-2,@date),120) + '12-31')
  )
end
GO
