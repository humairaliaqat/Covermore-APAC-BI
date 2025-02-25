USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_dtL2YYTDStart]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_dtL2YYTDStart] (@date datetime)  
returns datetime  
as  
  
/*****************************************************************************/  
-- Title:   		dbo.fn_dtL2YYTDStart  
-- Author:   		Leonardus Setyabudi  
-- Dependancies:   
-- Description:  	This function returns the previous 3 year 
--					year-to-date start date based on the input date   
--  
/*****************************************************************************/  
  
begin  
  return  
  (  
	select convert(datetime,convert(varchar(5),dateadd(year,-2,dateadd(d,-1,@date)),120) + '01-01')  
  )  
end
GO
