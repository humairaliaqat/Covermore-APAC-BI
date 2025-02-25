USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLastAugStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLastAugStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtLastAugStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns last August start date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select case when month(@date) <= 8 then convert(datetime,convert(varchar(5),dateadd(year,-1,@date),120)+'08-01')
				else convert(datetime,convert(varchar(5),@date,120)+'08-01')
			end
  )
end
GO
