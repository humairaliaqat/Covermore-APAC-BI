USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1025]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt1025]	
				@DateRange varchar(30),
				@StartDate datetime,
				@EndDate datetime,
				@SuperGroup varchar(200)
as
begin

SET NOCOUNT ON  

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt1025
--  Author:         Yi Yang
--  Date Created:   20181024
--  Description:    Returns details list of COI by Post
--					
--  Parameters:     
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--                  @SuperGroup: optional. Valid SuperGroup name
--                  
--  Change History: 
/****************************************************************************************************/
  
--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
declare @SuperGroup varchar(200)
select @DateRange = 'Yesterday', @StartDate = null, @EndDate = null, @SuperGroup = 'CBA Group'
*/

/* get reporting dates */
if @DateRange <> '_User Defined'
    select 
        @StartDate = StartDate, 
        @EndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange

;with COI_cte as
(
	select 
		o.SuperGroupName, 
		pbp.PolicyNumber,
		pbp.AddressLine1,
		pbp.AddressLine2,
		pbp.Suburb,
		pbp.Postcode,
		pbp.State, 
		pbp.CountryName,
		pbp.policykey,
		ptvl.Title,
		ptvl.FirstName,
		ptvl.LastName, 
		ptvl.PolicyTravellerKey,
		ptvl.PolicyEMCKey,
		case 
			when 
				ptvl.PolicyEMCKey is not null 
			then 'Yes' 
			else 'No' 
		end as HasEMC,
	
		pbp.createDateTime,
		Row_number() Over(Partition by pbp.policykey order by pbp.createDateTime desc) as row#,
		@StartDate [StartDate],
		@EndDate [EndDate]	

	from  
		penPolicyCOIByPost as pbp 
		left join penPolicy as p on p.PolicyKey = pbp.PolicyKey
		join penOutlet as o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
		outer apply 
		(
			select 
				pt.PolicyKey, 
				pt.PolicyTravellerKey,
				pt.Title,
				pt.FirstName,
				pt.LastName,
				max(pe.PolicyEMCKey) as PolicyEMCKey

			from 
				penPolicyTraveller as pt
				left join penPolicyTravellerTransaction as ptt on ptt.PolicyTravellerKey = pt.PolicyTravellerKey
				left join penPolicyEMC as pe on pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey

			where 
				pt.PolicyKey = p.PolicyKey and 
				pt.isPrimary = 1	
			group by 
				pt.PolicyKey, 
				pt.PolicyTravellerKey,
				pt.Title,
				pt.FirstName,
				pt.LastName
		) ptvl

	where 
		
		pbp.createDateTime >= @StartDate and
		pbp.createDateTime < dateadd(d,1,@EndDate)
		and o.SuperGroupName = @SuperGroup
)

select
		SuperGroupName, 
		PolicyNumber,
		PolicyKey,
		AddressLine1,
		AddressLine2,
		Suburb,
		Postcode,
		State, 
		CountryName,
		Title,
		FirstName,
		LastName, 
		CreateDateTime,
		HasEMC,
		StartDate,
		EndDate
from 
	COI_cte 
where 
	row# = 1 


end

GO
