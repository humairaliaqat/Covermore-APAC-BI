USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_battle_of_sexes_policy]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[tmp_battle_of_sexes_policy]
as

SET NOCOUNT ON


if object_id('tempdb..#policies') is not null drop table #policies
select
	case when t.Title = 'MR' then 'Male'
		 when t.Title in ('Miss','Ms','Mrs') then 'Female'
		 else 'Unknown'
	end as Gender,
	p.PolicyID,
	p.PolicyNumber,
	p.PrimaryCountry,
	t.PolicyTravellerID,
	t.Title,
	t.FirstName,
	t.LastName,
	t.DOB,
	t.Age,
	t.isAdult,
	t.isPrimary,
	--sum(t.Age) / count(p.PolicyID) as AverageAge,
	sum(pt.EMCCount) as EMCCount,
	sum(pt.WintersportCount) as WinterSportCount,
	sum(case when t.Age between 18 and 21 then 1 else 0 end) as YoungTraveller,
	sum(case when t.Age >= 65 then 1 else 0 end) as OlderTraveller
--into #Policies	
from
	[db-au-cmdwh].dbo.penPolicy p
	join [db-au-cmdwh].dbo.penPolicyTransSummary pt on p.PolicyKey = pt.PolicyKey		
	join [db-au-cmdwh].dbo.penPolicyTraveller t on p.PolicyKey = t.PolicyKey
where
	p.CountryKey = 'AU' and
	p.StatusDescription <> 'Cancelled' and
	convert(varchar(10),p.IssueDate,120) between '2012-01-01' and '2012-12-31'
group by
	case when t.Title = 'MR' then 'Male'
		 when t.Title in ('Miss','Ms','Mrs') then 'Female'
		 else 'Unknown'
	end,
	p.PolicyID,
	p.PolicyNumber,
	p.PrimaryCountry,
	t.PolicyTravellerID,
	t.Title,
	t.FirstName,
	t.LastName,
	t.DOB,
	t.Age,
	t.isAdult,
	t.isPrimary
order by
	p.PolicyNumber	


/*
--Single Adult with Children group by Gender
select
	a.Gender,
	count(a.PolicyNumber) as SingleAdultChildren
from
(	
select 
	Gender,
	PolicyNumber,	
	sum(case when isPrimary = 1 and isAdult = 1 then 1 else 0 end) as PrimaryAdult,
	sum(case when isAdult = 1 then 1 else 0 end) as Adult,
	sum(case when isAdult <> 1 then 1 else 0 end) as Children	
from
	#policies
group by Gender,PolicyNumber
) a
where a.Adult = 1 and Children > 1
group by a.Gender


--Top 20 countries Male
select top 20
	PrimaryCountry as Destination,
	count(PolicyNumber) as TopDestination
from
	#Policies
where Gender = 'Male' and PrimaryCountry <> 'Australia'	
group by
	PrimaryCountry
order by TopDestination desc			
	
	
--Top 20 countries Female
select top 20
	PrimaryCountry as Destination,
	count(PolicyNumber) as TopDestination
from
	#Policies
where Gender = 'Female' and PrimaryCountry <> 'Australia'	
group by
	PrimaryCountry
order by TopDestination desc			
	

--First Organiser with more than 1 adult on policy by Gender
select
	a.Gender,
	sum(a.FirstOrganiser) as FirstOrganiser
from
(
select
	Gender,
	PolicyNumber,
	sum(case when isAdult = 1 and isPrimary = 1 then 1 else 0 end) as FirstOrganiser,
	count(PolicyTravellerID) as TravellerCount	
from
	#Policies
group by Gender, PolicyNumber
) a
where a.TravellerCount > 1
group by a.Gender

*/
GO
