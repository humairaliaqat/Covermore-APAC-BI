USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetSUNFiscalPeriod]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_GetSUNFiscalPeriod] (@date datetime)
returns int
as


/*****************************************************************************/
-- Title:			dbo.fn_GetSUNFiscalPeriod
-- Author:			Linus Tor
-- Dependancies:	
-- Description:		This function returns SUN Fiscal period based on the input date value
--
/*****************************************************************************/

--uncomment to debug
/*
declare @date datetime
select @date = getdate()
*/


begin
  return
  (
	select cast(case month(@date) when 7 then convert(varchar(4),datepart(year,dateadd(year,1,@date))) + '001'
							 when 8 then convert(varchar(4),datepart(year,dateadd(year,1,@date))) + '002'
							 when 9 then convert(varchar(4),datepart(year,dateadd(year,1,@date))) + '003'
							 when 10 then convert(varchar(4),datepart(year,dateadd(year,1,@date))) + '004'
							 when 11 then convert(varchar(4),datepart(year,dateadd(year,1,@date))) + '005'
							 when 12 then convert(varchar(4),datepart(year,dateadd(year,1,@date))) + '006'
							 when 1 then convert(varchar(4),datepart(year,@date)) + '007'
							 when 2 then convert(varchar(4),datepart(year,@date)) + '008'
							 when 3 then convert(varchar(4),datepart(year,@date)) + '009'
							 when 4 then convert(varchar(4),datepart(year,@date)) + '010'
							 when 5 then convert(varchar(4),datepart(year,@date)) + '011'
							 when 6 then convert(varchar(4),datepart(year,@date)) + '012'
				end	as int)					 							 							 							 							 							 							 							 							 							 
  )
end
GO
