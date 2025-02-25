USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_countPolicyInforce_DepartureToReturn]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_countPolicyInforce_DepartureToReturn]
(
	@Country varchar(2),
	@StartDate date,
	@EndDate date
)
returns integer
as
begin

	declare @pcount int

	;with cte_inforce as
	(
		select
			PolicyNo,
			PolicyType,
			OldPolicyType
		from Policy with(index(idx_Policy_DepartureDate))
		where 
			CountryKey = @Country and
			(
				DepartureDate >= @StartDate and
				DepartureDate <  dateadd(day, 1, @EndDate)
			) and
			PolicyType in ('N', 'E', 'R')

		union

		select
			PolicyNo,
			PolicyType,
			OldPolicyType
		from Policy with(index(idx_Policy_ReturnDate))
		where 
			CountryKey = @Country and
			DepartureDate < @StartDate and
			ReturnDate >= @StartDate and
			PolicyType in ('N', 'E', 'R')
	)
	select
		@pcount = 
		sum(
			case 
				when PolicyType in ('N', 'E') then 1 
				when PolicyType = 'R' and OldPolicyType in ('N', 'E') then -1 
				else 0 
			end
		)
	from cte_inforce
	
	return @pcount

end
GO
