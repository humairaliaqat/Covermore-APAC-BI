USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_208_Service]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_208_Service] 
AS
BEGIN

	SET NOCOUNT ON;

-- ServiceType => Service

/*
stage tables:
	[db-au-stage]..dtc_cli_ServiceType 

pnpService
	ServiceSK
	ServiceID						'CLI_SRV_' + ServiceType_ID
	Name							ServiceType
	ServiceType						
	Stream
	Notes
	StartDate
	EndDate
	Status
	luasertype1
	luasertype2
	luasertype3
	CreatedDatetime					AddDate
	UpdatedDatetime					ChangeDate		
	CreatedBy						AddUser
	UpdatedBy						ChangeUser
	CostCentreGLAccount
	luasertype4
	NaturalGLAccount
	BillService
	CPTCode
	SuggestedSessionCount
	SuggestedApptLength
	IsEAPCaseService
	DefaultBookingTabAttendee
	fahcsiaprog
	fahcsiaservicetype
	IsFRC
	IsLegalAss
	HasParentAgree
	DefaultBookingEventMembers
	defaultbookingservfilemembers
	fahcsiaprogenddate
	hasfahcsiafeedback
	kexempttypeidchilddefault
	fahcsiasessfeedefaulttopaying
	kexempttypeidnofeedefault
	DefaultBookingWorkers
*/


-- 1. transform 
if object_id('tempdb..#src') is not null drop table #src 
select * into #src 
from (
	select 
		'CLI_SRV_' + ServiceType_ID ServiceID,
		ServiceType Name,
		case 
			when ServiceType_ID = '3B9F143FFC3C4A90BB0BE9134BDD232D' then 'OAS' 
			when ServiceType_ID = '08063ED0F3434DF5AD5AEF372E9990FF' then 'Performance' 
			when ServiceType_ID = '09DD0F3006004EC38D82B0D7050939CD' then 'Health' 
			when ServiceType_ID = '0D3B3BBF0BEF4FC7BADB70515527073F' then 'Health' 
			when ServiceType_ID = '81B1EDC4D6DA4E9F985F15E88B53FB0A' then 'OAS' 
			when ServiceType_ID = '13781B4CFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781B6DFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781B7CFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781B8BFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781B9FFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781BAEFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781B36FE8911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '13781BC6FE8911D4A30500902741A956' then 'EAP' 
			when ServiceType_ID = '13781BFEFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781C08FE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781C1AFE8911D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '13781BCEFE8911D4A30500902741A956' then 'EAP' 
			when ServiceType_ID = '13781BF3FE8911D4A30500902741A956' then 'Trauma' 
			when ServiceType_ID = '13781C30FE8911D4A30500902741A956' then 'EAP' 
			when ServiceType_ID = '13781C39FE8911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '13781C3FFE8911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '13781C4EFE8911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '13781C5DFE8911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '13781C65FE8911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '16FDA982CFD24BF69793065519D54267' then 'Health' 
			when ServiceType_ID = '13781C6CFE8911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '29283778D6C946818E9D3E74671A4A1F' then 'Performance' 
			when ServiceType_ID = '3248B65AA127422085B38F8A29034E95' then 'Health' 
			when ServiceType_ID = '13781C78FE8911D4A30500902741A956' then 'EAP' 
			when ServiceType_ID = '268DBEDD4ED24464B0EE39FAED8F2DDD' then 'EAP' 
			when ServiceType_ID = '331F3200FDD911D4A30500902741A956' then 'Internal' 
			when ServiceType_ID = '46F730F7AD6D4AD69A2B52A4F0BE468F' then 'EAP' 
			when ServiceType_ID = '527E61AC9E4B469DB6F157598173CEF7' then 'EAP' 
			when ServiceType_ID = '57D8B680F69411D4A30500902741A956' then 'Performance' 
			when ServiceType_ID = '572014E0F69411D4B2600008C7E32216' then 'EAP' 
			when ServiceType_ID = '588DBCD0323F4C048AF18ADBB067DDAC' then 'EAP' 
			when ServiceType_ID = '5C1FBD41E03A429F8D4D4E068B73C93F' then 'Health' 
			when ServiceType_ID = '5F8131291E0640AA8F5995C066974C8A' then 'OAS' 
			when ServiceType_ID = '6540E09ECF154DD0900AF6873B634B93' then 'Health' 
			when ServiceType_ID = '68B07C042C62424DB86D2136AA860565' then 'Health' 
			when ServiceType_ID = '590F31B8608A4495B8DE499420D21791' then 'Internal' 
			when ServiceType_ID = '6C90309C65B64190A4F2D032C76ACE3F' then 'OAS' 
			when ServiceType_ID = '708FD7406B2311D5AE610040C79961BF' then 'EAP' 
			when ServiceType_ID = '968423522AAD49DBA46590C2CC748882' then 'Performance' 
			when ServiceType_ID = '9821C1E1D1084ABBB103BA33C1F7C446' then 'On-Site' 
			when ServiceType_ID = '9D85F6853A8F4A1794E66355CF6F87B8' then 'Health' 
			when ServiceType_ID = 'A3442004633843A6B0AF2AF33AC5D219' then 'Health' 
			when ServiceType_ID = 'B04AB60616314E22A7FE12FB16B24F82' then 'Performance' 
			when ServiceType_ID = 'B742EEADE105416D9C7A359EEF34BC50' then 'Health' 
			when ServiceType_ID = 'B9271BD545264963B88834E17D3C2941' then 'Health' 
			when ServiceType_ID = 'CA714EF1E4684C3DADD9D71911687CF4' then 'Health' 
			when ServiceType_ID = 'CC75AD8FE2B845A2B88AF00B7AFB489C' then 'Trauma' 
			when ServiceType_ID = 'D0ED5E94E3174D5F9A2B0C0E1B29B92A' then 'EAP' 
			when ServiceType_ID = 'D62A06F0A039417AB4E3CE17B5B0BA17' then 'Health' 
			when ServiceType_ID = 'E3FE116896CC4799AEAB7C6B1F647F83' then 'Health' 
			when ServiceType_ID = 'E61E0A2522D44FD0A78E0C3CF4D43DE3' then 'OAS' 
			when ServiceType_ID = 'EB9FA30419184EBFAA493D778D250B48' then 'EAP' 
			when ServiceType_ID = 'F4CEC9C9E96C40689C4624384F4C9A02' then 'Performance' 
			when ServiceType_ID = 'FB6DC03AC8BB4DD1A1822D6389B6F7DA' then 'Performance' 
			when ServiceType_ID = 'FF65BBE34B5E4F998F249637923844B4' then 'Health'  
		end Stream,
		AddDate CreatedDatetime,
		ChangeDate UpdatedDatetime,
		AddUser CreatedBy,
		ChangeUser UpdatedBy
	from [db-au-stage]..dtc_cli_ServiceType 
) a

-- 2. load
merge [db-au-dtc]..pnpService as tgt
using #src
	on #src.ServiceID = tgt.ServiceID 
when not matched by target then 
	insert (
		ServiceID,
		Name,
		Stream,
		CreatedDatetime,
		UpdatedDatetime,
		CreatedBy,
		UpdatedBy
	)
	values (
		#src.ServiceID,
		#src.Name,
		#src.Stream,
		#src.CreatedDatetime,
		#src.UpdatedDatetime,
		#src.CreatedBy,
		#src.UpdatedBy
	)
when matched then update set 
	tgt.ServiceID = #src.ServiceID,
	tgt.Name = #src.Name,
	tgt.Stream = #src.Stream,
	tgt.CreatedDatetime = #src.CreatedDatetime,
	tgt.UpdatedDatetime = #src.UpdatedDatetime,
	tgt.CreatedBy = #src.CreatedBy,
	tgt.UpdatedBy = #src.UpdatedBy
;


update [db-au-dtc]..pnpService
set DisplayName = 
case 
	when [Name] = 'Assessment@Work' then 'Assessment@Work'
	when [Name] = 'Aust Post Relief Fund' then 'Aust Post Relief Fund'
	when [Name] = 'Change @Work - R' then 'Change@Work R'
	when [Name] = 'Change@Work' then 'Change@Work'
	when [Name] = 'Change@Work R - Case Management' then 'Change@Work R'
	when [Name] = 'Change@Work R - Individual' then 'Change@Work R'
	when [Name] = 'Clinical Management' then 'Clinical Management'
	when [Name] = 'Conflict@Work' then 'Conflict@Work'
	when [Name] = 'Conflict@Work - Mediation' then 'Conflict@Work'
	when [Name] = 'Contract Fees' then 'Contract Fees'
	when [Name] = 'Corporate Services' then 'Corporate Services'
	when [Name] = 'Dev@Work - Assessment' then 'Assessment@Work'
	when [Name] = 'Dev@Work - Coaching' then 'Development@Work'
	when [Name] = 'Dev@Work - Consulting' then 'Development@Work'
	when [Name] = 'Dev@Work - Supervision' then 'Development@Work'
	when [Name] = 'Dev@Work - Surveys' then 'Development@Work'
	when [Name] = 'Dev@Work - Training' then 'Development@Work'
	when [Name] = 'Development@Work' then 'Development@Work'
	when [Name] = 'DFV Support' then 'DFV Support'
	when [Name] = 'DFV Support - Manager' then 'DFV Support'
	when [Name] = 'DFV Support - managerAssist' then 'DFV Support'
	when [Name] = 'Dignity@Work' then 'Dignity@Work'
	when [Name] = 'Discontinued Service' then 'Discontinued Service'
	when [Name] = 'DTC Business Mgmt & Planning' then 'DTC Business Mgmt & Planning'
	when [Name] = 'DTC Customer Relationship Mgmt' then 'DTC Customer Relationship Mgmt'
	when [Name] = 'DTC Health' then 'DTC Health'
	when [Name] = 'DTC Health - 2CRisk ' then 'DTC Health - 2CRisk '
	when [Name] = 'DTC Health - Body Management' then 'DTC Health - Body Management'
	when [Name] = 'DTC Health - Financial Health ' then 'DTC Health - Financial Health '
	when [Name] = 'DTC Health - Flu Vaccinations ' then 'DTC Health - Flu Vaccinations '
	when [Name] = 'DTC Health - Health Coaching' then 'DTC Health - Health Coaching'
	when [Name] = 'DTC Health - Health Portal' then 'DTC Health - Health Portal'
	when [Name] = 'DTC Health - Musculoskeletal ' then 'DTC Health - Musculoskeletal '
	when [Name] = 'DTC Health - Nutrition' then 'DTC Health - Nutrition'
	when [Name] = 'DTC Health - Onsite Health Che' then 'DTC Health - Onsite Health Che'
	when [Name] = 'DTC Health - Optus Gym' then 'DTC Health - Optus Gym'
	when [Name] = 'DTC Health - Program Mgmt' then 'DTC Health - Program Mgmt'
	when [Name] = 'DTC Health - Resilience' then 'DTC Health - Resilience'
	when [Name] = 'DTC Health - Sleep' then 'DTC Health - Sleep'
	when [Name] = 'DTC Health -Exec Health Assess' then 'DTC Health -Exec Health Assess'
	when [Name] = 'DTC Health -Health Risk Assess' then 'DTC Health -Health Risk Assess'
	when [Name] = 'DTC Internal Training & Dev' then 'DTC Internal Training & Dev'
	when [Name] = 'DTC People & Team Mgmt' then 'DTC People & Team Mgmt'
	when [Name] = 'DTC Sales/Business Dev' then 'DTC Sales/Business Dev'
	when [Name] = 'EAP  Program Support' then 'EAP  Program Support'
	when [Name] = 'EAP Program Management' then 'Program Management'
	when [Name] = 'EAP Program Support' then 'EAP Program Support'
	when [Name] = 'eapdirect' then 'eapdirect'
	when [Name] = 'employeeAssist' then 'employeeAssist'
	when [Name] = 'Executive Support' then 'Executive Support'
	when [Name] = 'Internal - Administration Error' then 'Internal - Administration Error'
	when [Name] = 'Internal - Services to DTC' then 'Internal - Services to DTC'
	when [Name] = 'legalAssist' then 'employeeAssist'
	when [Name] = 'managerAssist' then 'managerAssist'
	when [Name] = 'Medical Records' then 'Medical Records'
	when [Name] = 'MentalWellbeing@Work' then 'MentalWellbeing@Work'
	when [Name] = 'moneyAssist' then 'employeeAssist'
	when [Name] = 'Nutrition@DTC' then 'employeeAssist'
	when [Name] = 'On-Site Services' then 'On-Site Services'
	when [Name] = 'On-Site Services employeeAssist' then 'On-Site Services employeeAssist'
	when [Name] = 'On-Site Services managerAssist' then 'On-Site Services managerAssist'
	when [Name] = 'On-Site Services Post Deployment Debrief' then 'On-Site Services Post Deployment Debrief'
	when [Name] = 'On-Site Services Program Management' then 'On-Site Services Program Management'
	when [Name] = 'Org Advisory Service' then 'Org Advisory Service'
	when [Name] = 'Post Case Management' then 'Post Case Management'
	when [Name] = 'Program Management' then 'Program Management'
	when [Name] = 'Psychological Counselling' then 'Psychological Counselling'
	when [Name] = 'Risk@Work' then 'Risk@Work'
	when [Name] = 'Risk@Work - Clinical' then 'Risk@Work'
	when [Name] = 'Risk@Work - Stress' then 'Risk@Work'
	when [Name] = 'Risk@Work - Violence' then 'Risk@Work'
	when [Name] = 'SpeakUp' then 'SpeakUp'
	when [Name] = 'Stress@Work' then 'Stress@Work'
	when [Name] = 'traumaAssist' then 'traumaAssist'
	when [Name] = 'traumaAssist - Case Management' then 'traumaAssist'
	when [Name] = 'traumaAssist - Individual' then 'traumaAssist'
	when [Name] = 'Wellcheck' then 'Wellcheck'
	when [Name] = 'Wellcheck - Case Management' then 'Wellcheck'
	when [Name] = 'Wellcheck - Individual' then 'Wellcheck'
	when [Name] = 'Win Win Parenting' then 'Win Win Parenting'
	when [Name] = 'Worker Contractual Information' then 'Worker Contractual Information'
	when [Name] = 'worklifeAssist' then 'worklifeAssist'
	else null 
end 



END

GO
