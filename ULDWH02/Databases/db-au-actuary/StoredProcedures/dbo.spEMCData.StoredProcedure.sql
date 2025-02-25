USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [dbo].[spEMCData]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spEMCData] @Domain varchar(2),
								@StartDate date,
								@EndDate date
as

SET NOCOUNT ON

--20190417 - LT - Procedure created. Can't find previous code for this.

--uncomment to debug
/*
declare @Domain varchar(2)
declare @StartDate date
declare @EndDate date
select @Domain = 'AU', @StartDate = '2017-09-01', @EndDate = '2017-09-30'
*/

if object_id('[db-au-actuary].ws.tmp_EMCData') is not null drop table [db-au-actuary].ws.tmp_EMCData
select
	pts.CountryKey as Domain,
	pts.PolicyKey,
	pts.PolicyNumber as TransactionNumber,
	pts.TransactionType,
	pts.TransactionStatus,
	pe.FirstName,
	pe.LastName,
	pe.DOB,
	emc.ApplicationID,
	emc.ApplicationType,
	emc.MedicalRisk,
	emc.Condition,
	emc.ConditionStatus,
	emc.MedicalScore,
	emc.GroupID,
	emc.GroupStatus,
	emc.GroupScore
into [db-au-actuary].ws.tmp_EMCData
from
	[db-au-cmdwh].dbo.penPolicyTransSummary pts with(nolock)
	inner join [db-au-cmdwh].dbo.penPolicyTravellerTransaction ptt with(nolock) on pts.PolicyTransactionKey = ptt.PolicyTransactionKey
	inner join [db-au-cmdwh].dbo.penPolicyEMC pe with(nolock) on ptt.PolicyTravellerTransactionKey = pe.PolicyTravellerTransactionKey
	inner join [db-au-cmdwh].dbo.penAddOn ao with(nolock) on 
		pe.AddOnID = ao.AddOnID and 
		pe.CountryKey = ao.CountryKey and
		pe.CompanyKey = ao.CompanyKey	
	cross apply
	(
		select
			e.ApplicationID,
			e.ApplicationType,
			e.MedicalRisk,
			m.Condition,
			m.ConditionStatus,
			m.MedicalScore,
			m.GroupID,
			m.GroupStatus,
			m.GroupScore
		from
			[db-au-cmdwh].dbo.emcApplications e with(nolock)
			left join [db-au-cmdwh].dbo.emcMedical m with(nolock) on e.ApplicationKey = m.ApplicationKey
		where
			e.ApplicationKey = pe.EMCApplicationKey
	) emc
where
	pts.CountryKey = @Domain and
	pts.PostingDate >= @StartDate and
	pts.PostingDate < dateadd(d,1,@EndDate)

create clustered index idx_tmpEMCData_PolicyKey on [db-au-actuary].ws.tmp_EMCData(PolicyKey)


if object_id('[db-au-actuary].dataout.EMCData') is null
begin
	create table [db-au-actuary].dataout.EMCData
	(
		[Domain] [varchar](2) NOT NULL,
		[PolicyKey] [varchar](41) NULL,
		[TransactionNumber] [varchar](50) NULL,
		[TransactionType] [varchar](50) NULL,
		[TransactionStatus] [nvarchar](50) NULL,
		[FirstName] [nvarchar](100) NULL,
		[LastName] [nvarchar](100) NULL,
		[DOB] [datetime] NULL,
		[ApplicationID] [int] NOT NULL,
		[ApplicationType] [varchar](25) NULL,
		[MedicalRisk] [decimal](18, 2) NOT NULL,
		[Condition] [varchar](50) NULL,
		[ConditionStatus] [varchar](19) NULL,
		[MedicalScore] [numeric](18, 2) NULL,
		[GroupID] [int] NULL,
		[GroupStatus] [varchar](20) NULL,
		[GroupScore] [decimal](18, 2) NULL
	)
	create clustered index idx_EMCData_PolicyKey on [db-au-actuary].dataout.EMCData(PolicyKey)
end
else
	delete e
	from
		[db-au-actuary].dataout.EMCData e
		inner join [db-au-actuary].ws.tmp_EMCData t on e.PolicyKey = t.PolicyKey


insert [db-au-actuary].dataout.EMCData
(
	[Domain],
	[PolicyKey],
	[TransactionNumber],
	[TransactionType],
	[TransactionStatus],
	[FirstName],
	[LastName],
	[DOB],
	[ApplicationID],
	[ApplicationType],
	[MedicalRisk],
	[Condition],
	[ConditionStatus],
	[MedicalScore],
	[GroupID],
	[GroupStatus],
	[GroupScore]
)
select
	[Domain],
	[PolicyKey],
	[TransactionNumber],
	[TransactionType],
	[TransactionStatus],
	[FirstName],
	[LastName],
	[DOB],
	[ApplicationID],
	[ApplicationType],
	[MedicalRisk],
	[Condition],
	[ConditionStatus],
	[MedicalScore],
	[GroupID],
	[GroupStatus],
	[GroupScore]
from
	[db-au-actuary].ws.tmp_EMCData
GO
