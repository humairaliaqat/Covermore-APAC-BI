USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_isAHMMember]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_isAHMMember](@MemberNumber varchar(25))
returns varchar(10)
as
begin


--uncomment to debug
/*
declare @MemberNumber varchar(9)
select @MemberNumber = '27026806'
*/

declare @isAHMMember varchar(10)
declare @TotalProductWeighting int
declare @ModValue int
declare @CheckValue char(1)
declare @MemberLookup table(ModValue int, CheckValue char(1))

select @MemberNumber = ltrim(rtrim(@MemberNumber))

if isnumeric(left(ltrim(rtrim(@MemberNumber)),7)) = 0 or len(ltrim(rtrim(@MemberNumber))) < 8 or len(ltrim(rtrim(@MemberNumber))) > 8	--check if valid MemberNumber
	select @isAHMMember = 'No'
else
begin
	
	--get total product weighting value
	select
		@TotalProductWeighting = convert(int,substring(@MemberNumber,1,1)) * 1 +		--1 is constant weighting for 1st digit
								 convert(int,substring(@MemberNumber,2,1)) * 2 +		--2 is constant weighting for 2nd digit
								 convert(int,substring(@MemberNumber,3,1)) * 3 +		--3 is constant weighting for 3rd digit
								 convert(int,substring(@MemberNumber,4,1)) * 4 +		--4 is constant weighint for 4th digit
								 convert(int,substring(@MemberNumber,5,1)) * 5 +		--5 is constant weighint for 5th digit
								 convert(int,substring(@MemberNumber,6,1)) * 6 +		--6 is constant weighint for 6th digit
								 convert(int,substring(@MemberNumber,7,1)) * 7 			--7 is constant weighint for 7th digit
								 

	--get Mod value
	select @ModValue = @TotalProductWeighting % 11

	--get CheckValue with the derived @ModValue
	select @CheckValue = case when @ModValue >= 10 then '0' else convert(varchar,@ModValue) end


	select @isAHMMember = case when @MemberNumber = left(@MemberNumber,7) + @CheckValue then 'Yes' else 'No' end
end

--select @MemberNumber, @TotalProductWeighting, @ModValue, @CheckValue, @isAHMMember

return isnull(@isAHMMember,'No')


end

GO
