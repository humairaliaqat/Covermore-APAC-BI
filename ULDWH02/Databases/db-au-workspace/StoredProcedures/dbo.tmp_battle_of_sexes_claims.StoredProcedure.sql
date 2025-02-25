USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_battle_of_sexes_claims]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_battle_of_sexes_claims]
as

SET NOCOUNT ON

--Claims Data
if object_id('tempdb..#claims') is not null drop table #claims
select 
	case when n.Title = 'MR' then 'Male'
		 when n.Title in ('Miss','Ms','Mrs') then 'Female'
		 else 'Unknown'
	end as Gender,
	e.EventDesc,
	e.PerilCode,
	e.PerilDesc,
	s.SectionCode,
	n.NameID,
	n.Title,
	n.FirstName,
	n.Surname,
	count(distinct e.EventID) as ClaimCount,
	sum(p.PaymentAmount) as PaymentAmount,
	sum(case when s.SectionCode in ('MED','HOSP') then 1 else 0 end) as MedicalNumber,
	sum(case when s.SectionCode in ('MED','HOSP') then p.PaymentAmount else 0 end) as MedicalPaid,
	sum(case when e.PerilDesc like '%injury%' then 1 else 0 end) as Injury,
	sum(case when e.PerilDesc like '%illness%' then 1 else 0 end) as Illness,
	sum(case when (e.EventDesc like '%motor%' or e.EventDesc like '%cycle%' or e.EventDesc like '%bike%' or e.EventDesc like '%MVA%') then 1 else 0 end) as Motorcycle,
	sum(case when s.SectionCode = 'LUGG' and e.PerilDesc like '%lost%' then 1 else 0 end) as LuggageLost,
	sum(case when (s.SectionCode = 'LUGG' and e.PerilDesc like '%stolen%') or (s.SectionCode = 'LUGG' and e.PerilDesc like '%stolem%') or (s.SectionCode = 'LUGG' and e.PerilDesc like '%theft%') then 1 else 0 end) as LuggageStolen,
	sum(case when e.EventDesc like '%snow%' or e.EventDesc like '%skii%' then 1 else 0 end) as WintersportNumber,
	sum(case when e.EventDesc like '%snow%' or e.EventDesc like '%skii%' then p.PaymentAmount else 0 end) as WintersportPaid
from
	[db-au-cmdwh].dbo.clmEvent e
	join [db-au-cmdwh].dbo.clmSection s on e.EventKey = s.EventKey	
	join [db-au-cmdwh].dbo.clmPayment p on s.SectionKey = p.SectionKey
	join [db-au-cmdwh].dbo.clmName n on p.PayeeKey = n.NameKey
where
	e.CountryKey = 'AU' and
	e.EventDate between '2012-01-01' and '2012-12-31' and
	p.PaymentStatus in ('PAID','RECY') and
	n.isThirdParty = 0
group by
	case when n.Title = 'MR' then 'Male'
		 when n.Title in ('Miss','Ms','Mrs') then 'Female'
		 else 'Unknown'
	end,
	e.EventDesc,
	e.PerilCode,
	e.PerilDesc,
	s.SectionCode,
	n.NameID,
	n.Title,
	n.FirstName,
	n.Surname
order by n.NameID
GO
