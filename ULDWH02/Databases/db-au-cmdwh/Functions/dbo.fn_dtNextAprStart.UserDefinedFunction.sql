USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextAprStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextAprStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextAprStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns next April start date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select case when month(@date) < 4 then convert(datetime,convert(varchar(5),dateadd(year,0,@date),120)+'04-01')
				else convert(datetime,convert(varchar(5),dateadd(year,1,@date),120)+'04-01')
			end
  )
end
GO
