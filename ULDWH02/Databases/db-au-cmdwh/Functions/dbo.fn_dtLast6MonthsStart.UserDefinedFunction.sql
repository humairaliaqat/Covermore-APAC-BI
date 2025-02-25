USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtLast6MonthsStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtLast6MonthsStart] (@date datetime)  
returns datetime  
as  
  
/*****************************************************************************/  
-- Title:   		dbo.fn_dtLast6MonthsStart  
-- Author:   		Leonardus Setyabudi  
-- Dependencies:   
-- Description:  	This function returns last 6 months start date 
--					based on the input date
--  
/*****************************************************************************/  
  
begin  
  return  
  (  
	select convert(datetime,convert(varchar(8),dateadd(month,-6,@date),120) + '01')  
  )  
end
GO
