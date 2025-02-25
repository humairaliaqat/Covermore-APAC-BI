USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_countPolicyInforce_IssuedToReturn]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_countPolicyInforce_IssuedToReturn]
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
			OldPolicyType,
			PlanCode,
			CancellationPremium,
			IssuedDate
		from Policy with(index(idx_Policy_IssuedDate))
		where 
			CountryKey = @Country and
			(
				IssuedDate >= @StartDate and
				IssuedDate <  dateadd(day, 1, @EndDate)
			) and
			PolicyType in ('N', 'E', 'R')

		union

		select
			PolicyNo,
			PolicyType,
			OldPolicyType,
			PlanCode,
			CancellationPremium,
			IssuedDate
		from Policy with(index(idx_Policy_ReturnDate))
		where 
			CountryKey = @Country and
			IssuedDate < @StartDate and
			ReturnDate >= @StartDate and
			PolicyType in ('N', 'E', 'R')
	)
	select
		@pcount = 
		sum(
			case 
				when 
				(
				  (PlanCode like 'C%' or PlanCode like 'XC%') and 
				  (CancellationPremium <> 0) 
				) or
				IssuedDate < '2010-10-01' -- introduction of canx plan
				then
					case 
						when PolicyType in ('N', 'E') then 1 
						when PolicyType = 'R' and OldPolicyType in ('N', 'E') then -1 
						else 0 
					end
				else 0
				end
		)
	from cte_inforce
	
	return @pcount

end
GO
