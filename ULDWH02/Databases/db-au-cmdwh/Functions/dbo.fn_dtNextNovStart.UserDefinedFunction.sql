USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNextNovStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtNextNovStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNextNovStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns next November start date based 
--					on the input date
/*****************************************************************************/

begin
  return
  (
	select case when month(@date) < 11 then convert(datetime,convert(varchar(5),dateadd(year,0,@date),120)+'11-01')
				else convert(datetime,convert(varchar(5),dateadd(year,1,@date),120)+'11-01')
			end
  )
end
GO
