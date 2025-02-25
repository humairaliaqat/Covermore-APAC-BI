USE [db-au-actuary]
GO
/****** Object:  UserDefinedFunction [dbo].[func_SameGenderTravellerCount_check]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--use [db-au-actuary]

--create
CREATE 
FUNCTION [dbo].[func_SameGenderTravellerCount_check](@policyKey varchar(41))
RETURNS int
AS
begin
   	declare @SameGenderMaxCount varchar(100)=0
	select @SameGenderMaxCount=max(x.cnt) from(
	      select count(distinct PolicyTravellerKey) cnt
	  from [db-au-actuary].ws.DWHDataSetPremiumComponents
	  where policykey=@policyKey
	  and gender is not null
	  group by gender
	  --having count(distinct PolicyTravellerKey)>0
	  ) x;
      RETURN @SameGenderMaxCount;
end
GO
