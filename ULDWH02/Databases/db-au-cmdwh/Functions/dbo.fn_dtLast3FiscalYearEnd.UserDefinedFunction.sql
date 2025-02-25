USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast3FiscalYearEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLast3FiscalYearEnd] (@date datetime)  
returns datetime  
as  
  
/*****************************************************************************/  
-- Title:         dbo.fn_dtLast3FiscalYearEnd  
-- Author:        Leonardus Setyabudi
-- Dependancies:   
-- Description:   This function returns the last 3 fiscal year 
--                end date based on the input date  
/*****************************************************************************/  
  
begin  
  return  
  (  
  select 
    case 
      when datepart(month,@date) between 7 and 12 then convert(datetime,convert(varchar(5),dateadd(year,-2,@date),120) + '06-30')  
      else convert(datetime,convert(varchar(5),dateadd(year,-3,@date),120) + '06-30')  
    end  
  )  
end
GO
