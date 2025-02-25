USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast2MonthsEnd]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_dtLast2MonthsEnd] (@date datetime)    
returns datetime    
as    
    
/*****************************************************************************/    
-- Title:         dbo.fn_dtLast2MonthsStart    
-- Author:        Leonardus Setyabudi    
-- Dependencies:     
-- Description:   This function returns last 2 months end date   
--                based on the input date  
--    
/*****************************************************************************/    
    
begin    
  return    
  (    
    select dateadd(d, -1, dateadd(m, 1, convert(datetime, convert(varchar(8), dateadd(month, -1, @date), 120) + '01')))    
  )    
end  
GO
