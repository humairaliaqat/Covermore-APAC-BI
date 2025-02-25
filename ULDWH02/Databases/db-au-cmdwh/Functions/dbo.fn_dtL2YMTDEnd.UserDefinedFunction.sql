USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtL2YMTDEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtL2YMTDEnd] (@date datetime)  
returns datetime  
as  
  
/*****************************************************************************/  
-- Title:   		dbo.fn_dtL2YMTDEnd  
-- Author:   		Leonardus Setyabudi  
-- Dependancies:   
-- Description:  	This function returns the Last 2 year 
--					month-to-date end date based on the input date   
--  
/*****************************************************************************/  
  
  
begin  
  return  
  (  
	select convert(datetime,convert(varchar(10),dateadd(year,-2,dateadd(d,-1,@date)),120))  
  )  
end
GO
