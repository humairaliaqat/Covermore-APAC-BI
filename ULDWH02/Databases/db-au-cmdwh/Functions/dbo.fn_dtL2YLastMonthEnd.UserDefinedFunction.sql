USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtL2YLastMonthEnd]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtL2YLastMonthEnd] (@date datetime)  
returns datetime  
as  
  
/*****************************************************************************/  
-- Title:   		dbo.fn_dtL2YLastMonthEnd  
-- Author:   		Leonardus Setyabudi  
-- Dependancies:   
-- Description:  	This function returns the Last 2 year 
--					last month end date based on the input date   
--  
/*****************************************************************************/  
  
begin  
  return  
  (  
	select dateadd(d,-1,dateadd(m,1,convert(datetime,convert(varchar(8),dateadd(year,-2,dateadd(month,-1,@date)),120) + '01')))  
  )  
end
GO
