USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtQTDFiscalNum]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtQTDFiscalNum] (@date datetime)
returns int
as

/*****************************************************************************/
-- Title:			dbo.fn_dtQTDFiscalNum
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns the Quarter-to-date fiscal number based on the input date 
--
/*****************************************************************************/


begin
  return
  (
	select case datepart(quarter,@date) when 3 then 1
										when 4 then 2
										when 1 then 3
										when 2 then 4
			end
  )
end
GO
