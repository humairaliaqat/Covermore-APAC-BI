USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_isMedibankMember]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_isMedibankMember](@MemberNumber varchar(25))
returns varchar(10)
as
begin

--uncomment to debug
/*
declare @MemberNumber varchar(25)
select @MemberNumber = '       28277433T'
*/

declare @isMedibankMember varchar(10)
declare @TotalProductWeighting int
declare @ModValue int
declare @CheckValue char(1)
declare @MemberLookup table(ModValue int, CheckValue char(1))

select @MemberNumber = ltrim(rtrim(@MemberNumber))

--populate @MemberLookup mod and check values as supplied by Medibank
insert @MemberLookup values(1,'Y')
insert @MemberLookup values(2,'X')
insert @MemberLookup values(3,'W')
insert @MemberLookup values(4,'T')
insert @MemberLookup values(5,'L')
insert @MemberLookup values(6,'K')
insert @MemberLookup values(7,'J')
insert @MemberLookup values(8,'H')
insert @MemberLookup values(9,'F')
insert @MemberLookup values(10,'B')
insert @MemberLookup values(11,'A')


if isnumeric(left(ltrim(rtrim(@MemberNumber)),8)) = 0 or len(ltrim(rtrim(@MemberNumber))) < 9		--check if valid MemberNumber
	select @isMedibankMember = 'No'
else
begin
	
	--get total product weighting value
	select
		@TotalProductWeighting = convert(int,substring(@MemberNumber,1,1)) * 5 +		--5 is constant weighting for 1st digit
								 convert(int,substring(@MemberNumber,2,1)) * 8 +		--8 is constant weighting for 2nd digit
								 convert(int,substring(@MemberNumber,3,1)) * 4 +		--4 is constant weighting for 3rd digit
								 convert(int,substring(@MemberNumber,4,1)) * 2 +		--2 is constant weighint for 4th digit
								 convert(int,substring(@MemberNumber,5,1)) * 1 +		--1 is constant weighint for 5th digit
								 convert(int,substring(@MemberNumber,6,1)) * 6 +		--6 is constant weighint for 6th digit
								 convert(int,substring(@MemberNumber,7,1)) * 3 +		--3 is constant weighint for 7th digit
								 convert(int,substring(@MemberNumber,8,1)) * 7			--7 is constant weighint for 8th digit

	--get Mod value
	select @ModValue = isnull((@TotalProductWeighting % 11) + 1,0)

	--look up CheckValue with the derived @ModValue
	select @CheckValue = CheckValue
	from @MemberLookup
	where ModValue = @ModValue

	select @isMedibankMember = case when @MemberNumber = left(@MemberNumber,8) + @CheckValue then 'Yes' else 'No' end
end

--select @MemberNumber, @TotalProductWeighting, @ModValue, @CheckValue, @isMedibankMember

return isnull(@isMedibankMember,'No')

end
GO
