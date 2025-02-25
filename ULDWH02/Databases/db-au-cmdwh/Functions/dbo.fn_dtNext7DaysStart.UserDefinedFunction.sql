USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtNext7DaysStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtNext7DaysStart] (@date datetime)
returns datetime
as

/*****************************************************************************/
-- Title:			dbo.fn_dtNext7DaysStart
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the start date of the next
--					7 days based on the input date
/*****************************************************************************/

begin
  return(select dateadd(d,1,@date))
end
GO
