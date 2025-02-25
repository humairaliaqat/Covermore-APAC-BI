USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_303_JobClientProfile]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_303_JobClientProfile] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- JobClientProfile => CompletedDocument & CompletedDocumentAnswer

	/*
	stage tables:
		[db-au-stage]..dtc_cli_ProfileAnswers
		[db-au-stage]..dtc_cli_JobClientProfile
	
	
	pnpCompletedDocument
		CompletedDocumentSK
		DocumentSK
		CaseSK												oa
		ServiceFileSK										oa			
		ServiceEventSK
		BookItemSK
		CompletedDocumentRevisionSK
		CreateUserSK
		UpdateUserSK
		CompletedByBookItemSK
		CreateBookItemSK
		UpdateBookItemSK
		CompletedDocumentID									'CLI_JOB_' + Job_ID	
		CaseID												'CLI_JOB_' + Job_ID	
		Title												Match the titles from Penelope ?
		Description
		DocumentDate
		CreatedDatetime
		UpdatedDatetime
		CreatedBy
		UpdatedBy
		ServiceFileID										'CLI_JOB_' + Job_ID
		Lock
		OriginalCompletedDocumentID
		ServiceEventID
		DocumentID
		Stage
		TitleStage
		BookItemID
		CompletedDocumentRevisionID
		CompletedDocumentRevisionState
		CreateUserID
		UpdateUserID
		CompletedByBookItemID
		kiocrossid
		CreateBookItemID
		UpdateBookItemID
		CompletionTime
		RelationType										'Service File' / 'Case'	
		RelatedAnonymousServiceID
		RelatedFunderID
		RelatedFunderSK
		RelatedInformalSeriesID
		RelatedServiceID
		RelatedServiceSK
		RelatedEventID
		RelatedEventSK
		RelatedGroupEventID
		RelatedGroupMasterID
		RelatedCaseID										'CLI_JOB_' + Job_ID
		RelatedCaseSK										oa		
		RelatedServiceFileID								'CLI_JOB_' + Job_ID
		RelatedServiceFileCompletedAtServiceEventID
		RelatedServiceFileSK								oa
		RelatedIndividualID
		RelatedIndividualSK
		RelatedBlueBookID
		RelatedBlueBookSK
		RelatedReferralID
		RelatedReferralSK
		RelatedFlatTreeID
	*/


	/*
	pnpCompletedDocumentRevision
		CompletedDocumentRevisionSK
		CompletedDocumentSK								oa
		CreateUserSK
		UpdateUserSK
		CreateBookItemSK
		UpdateBookItemSK
		CompletedDocumentRevisionID						'CLI_JOB_' + Job_ID
		CompletedDocumentID								'CLI_JOB_' + Job_ID	
		RevisionDate
		DocumentLetterSent
		CreatedDatetime
		UpdatedDatetime
		CreateUserID
		UpdateUserID
		CreateBookItemID
		UpdateBookItemID
	*/



	/*
	pnpCompletedDocumentAnswer
		CompletedDocumentAnswerSK
		CompletedDocumentRevisionSK						oa	
		BookItemSK
		CompletedDocumentRevisionBodyID
		CompletedDocumentRevisionID						'CLI_JOB_' + Job_ID	
		DocumentBodyPartID
		BookItemID
		QuestionID
		Question										Question 
		QuestionClassID
		QuestionClass
		QuestionClassLevel
		IsNumberQuestion
		QuestionCreatedDatetime
		QuestionUpdatedDatetime
		QuestionCreateUserID
		QuestionUpdateUserID
		QuestionTypeID
		QuestionType
		QuestionTypeAssess
		QuestionFormatID
		QuestionFormat
		QuestionInline
		QuestionListGroupID
		QuestionListGroup
		QuestionListGroupIsSharedList
		QuestionListGroupDefaultSort
		QuestionListGroupColumns
		QuestionListGroupIsScoreList
		QuestionListGroupCreatedDatetime
		QuestionListGroupUpdatedDatetime
		QuestionListGroupCreateUserID
		QuestionListGroupUpdateUserID
		QuestionUseOther
		QuestionCommentTypeID
		QuestionCommentType
		QuestionComment
		QuestionAnswerRequiredTypeID
		QuestionAnswerRequiredType
		QuestionAbbreviation
		QuestionHelpText
		QuestionDefault
		QuestionDecimalPlaces
		QuestionLowerLimit
		QuestionUpperLimit
		QuestionShowCB
		QuestionShared
		QuestionScored
		QuestionDataQuerySpecKeyID
		QuestionDataQueryApplicName
		QuestionDataQueryEntityType
		QuestionDataQueryTableKey
		QuestionDataQueryEntityName
		QuestionDataQueryID
		QuestionDataQueryCategory
		QuestionDataQueryName
		QuestionDataQueryView
		QuestionDataQueryDateComPopID
		QuestionDataQueryIsDataList
		QuestionDataQueryTextForPreview
		QuestionDataQueryTableName
		QuestionDataQueryFieldName
		QuestionLowerEndPointText
		QuestionUpperEndPointText
		QuestionHideNA
		AnswerID									'CLI_JCP_' + JobClientProfile_ID
		CompletedOther
		CompletedText
		IsAnswered
		ParentAnswerID
		ParentQuestionID
		IsValidated
		AnswerYN
		AnswerDate
		AnswerNumber
		AnswerText
		UserID
		UserSK
		SiteID
		SiteSK
		ServiceID
		ServiceSK
		DocumentMasterSK
		DocumentMasterID
		DocumentSection1
	*/


	if object_id('[db-au-dtc]..cliJobClientProfile') is null 
	begin 
		create table [db-au-dtc]..cliJobClientProfile (
			CaseSK int,
			ServiceFileSK int,
			AnswerID varchar(50),
			CaseID varchar(50),
			ServiceFileID varchar(50),
			Profile_Type varchar(50),
			Question_Number int,
			Question nvarchar(1000),
			Answer1 nvarchar(10),
			Answer2 nvarchar(max)
		)
	
		create index idx_cliJobClientProfile_CaseSK on [db-au-dtc]..cliJobClientProfile (CaseSK) 
		create index idx_cliJobClientProfile_ServiceFileSK on [db-au-dtc]..cliJobClientProfile (ServiceFileSK) 
		create index idx_cliJobClientProfile_AnswerID on [db-au-dtc]..cliJobClientProfile (AnswerID) 
		create index idx_cliJobClientProfile_CaseID on [db-au-dtc]..cliJobClientProfile (CaseID) 
		create index idx_cliJobClientProfile_ServiceFileID on [db-au-dtc]..cliJobClientProfile (ServiceFileID) 
		create index idx_cliJobClientProfile_Question on [db-au-dtc]..cliJobClientProfile (Question)
		create index idx_cliJobClientProfile_Answer2 on [db-au-dtc]..cliJobClientProfile (Answer2)
	end 


	select 
		sf.CaseSK,
		sf.ServiceFileSK,
		'CLI_JCP_' + jcp.JobClientProfile_ID AnswerID,
		coalesce(convert(varchar, sflu.kcaseid), 'CLI_JOB_' + jcp.Job_ID) CaseID,
		coalesce(convert(varchar, sflu.kprogprovid), 'CLI_JOB_' + jcp.Job_ID) ServiceFileID,
		case 
			when jcp.Profile_Type = '0' then 'Client Satisfaction Survey'
			when jcp.Profile_Type = '1' then 'Client Profile'
			when jcp.Profile_Type = '2' then 'KPI''s'
			when jcp.Profile_Type = '3' then 'Questionaire'
		end Profile_Type,
		Question_Number,
		Question,
		Answer1,
		coalesce(Answer, Answer2) Answer2 
	into #jcp 
	from 
		[db-au-stage]..dtc_cli_JobClientProfile jcp 
		left join [db-au-stage]..dtc_cli_ProfileAnswers pa on jcp.ProfileQuestion_ID = pa.ProfileQuestion_ID and jcp.Answer1 = pa.Answer_Number 
		left join [db-au-stage]..dtc_cli_Base_Job bj on bj.Job_ID = jcp.Job_ID 
		left join [db-au-stage]..dtc_cli_ServiceFile_Lookup sflu on sflu.uniquecaseid = bj.Pene_ID 
		join [db-au-dtc]..pnpServiceFile sf on sf.ServiceFileID = coalesce(convert(varchar, sflu.kprogprovid), 'CLI_JOB_' + jcp.Job_ID) 
	
	

	merge [db-au-dtc]..cliJobClientProfile as tgt 
	using #jcp 
		on #jcp.AnswerID = tgt.AnswerID 
	when not matched by target then 
		insert (
			CaseSK,
			ServiceFileSK,
			AnswerID,
			CaseID,
			ServiceFileID,
			Profile_Type,
			Question_Number,
			Question,
			Answer1,
			Answer2
		)
		values (
			#jcp.CaseSK,
			#jcp.ServiceFileSK,
			#jcp.AnswerID,
			#jcp.CaseID,
			#jcp.ServiceFileID,
			#jcp.Profile_Type,
			#jcp.Question_Number,
			#jcp.Question,
			#jcp.Answer1,
			#jcp.Answer2
		)
	when matched then update set 
		tgt.CaseSK = #jcp.CaseSK,
		ServiceFileSK = #jcp.ServiceFileSK,
		CaseID = #jcp.CaseID,
		ServiceFileID = #jcp.ServiceFileID,
		Profile_Type = #jcp.Profile_Type,
		Question_Number = #jcp.Question_Number,
		Question = #jcp.Question,
		Answer1 = #jcp.Answer1,
		Answer2 = #jcp.Answer2
	;	



	/*
	pnpServiceFileMember
		ServiceFileMemberSK
		ServiceFileSK
		IndividualSK
		FunderSK
		FunderDepartmentSK
		ServiceFileMemberID				'CLI_JOB_' + Job_ID
		Relationship
		SafetyFlag
		IsCaseInitiator
		IsPrimaryClient
		PresentingIssue1				
		PresentingIssueGroup1
		PresentingIssueGroupClass1
		PresentingIssue2
		PresentingIssueGroup2
		PresentingIssueGroupClass2
		PresentingIssue3
		PresentingIssueGroup3
		PresentingIssueGroupClass3
		CreatedDatetime
		UpdatedDatetime
		luppmemberud1id
		luppmemberud2id
		ppmemberud3
		ppmemberud4
		consentpcehr
	
	
	Clientele Presebting Issues:

		Personal - Family or Relationship Issue
			Child / Adolescent Issues
			Domestic or Family Violence - Emotional/Psychological
			Domestic or Family Violence - Physical
			Domestic Violence
			Extended / Blended Family Issues
			Family Relationship Discord
			Marital / Relationship Discord
			Marital/Relationship Discord
			Separation / Divorce
		Personal - Legal, Financial, Medical or Addiction Issue
			Alcohol Problem
			Drug Problem
			Financial Issue
			Gambling Problem
			General Healthy Eating
			Legal Issue
			Medical / Health
			Medical Issue
			Quit Smoking
			Weight Management
		Personal - Psychological Issue
			Anger
			Anxiety
			Depression
			Grief & Loss
			Personal Stress
			Personal Trauma
			Psychotic Disorder
			Self Esteem

		Primary Presenting Issue Category
			Bullying
			Other (General Bullying/Workplace Conflict)
			Personal:  Family or Relationship
			Personal:  Legal, Financial, Medical or Addiction
			Personal:  Psychological
			Predatory Behaviour
			Sexual Discrimination
			Sexual Harassment
			Victimisation
			Work Related:  Interpersonal
			Work Related:  Occupational Health
			Work Related:  Vocational
		Secondary Issue 
			NULL
			Alcohol and other drug issue
			Alleged bullying and harassment
			Behavioural problem at work
			Conflict (team)
			Conflict between self, peer and manager
			Domestic violence
			Employee mental health issue
			Employee personal problem
			Employee physical injury, illness and disability
			Equity, diversity, discrimination
			Grief and loss
			H
			Managers role and responsibilities
			Managing aggressive, threatening or violent behaviour 
			Managing suicidal behaviours
			Managing through organisational change
			None
			Other
			Performance management
			Team functioning/cohesion issues
			Workplace incident

		Work Related - Interpersonal Issue
			Co-workers
			Discrimination, Harassment, or Bullying
			Public / Clients
			Staff
			Supervisor / Manager
		Work Related - Occupational Health Issue
			Accident / Injury
			Allegation of impropriety. Offer of support with dismissal pending.
			Client presented with interpersonal problems with supvr. she felt unfairly treated. Struggled with how to deal with situation. No psych symptoms
			Client said he has been accused of saying inappropirate things to a young girl.
			Clinet concerned about scrutiny due media coverage of recent abuse in DECD
			coping and supporting others through significant workplace trauma
			Has been stood down with another 24 staff as a result on recruitment processes they were in recruited under
			N/A
			Shiftwork
			the cx is currently under investigation over work related incident - suspected association around his private contact with one student,
			Work Trauma
		Work Related - Vocational Issue
			Career Planning
			Client said he was shocked
			Client took one night off
			cx is currently stood down from work
			no
			Organisational Change
			Redundancy
			Removed from workplace
			Retirement
			Work Role Change
			Work Satisfaction
			Worklife Balance
			Workload
	*/


	if object_id('tempdb..#src') is not null drop table #src
	;with pig as (
		select distinct 
			ServiceFileID,
			replace(Answer2, ':  ', ' - ') + ' Issue' PresentingIssueGroup
		from 
			[db-au-dtc]..cliJobClientProfile 
		where 
			Question = 'Primary Presenting Issue Category'
			and Answer2 in (
				'Personal:  Family or Relationship',
				'Personal:  Legal, Financial, Medical or Addiction',
				'Personal:  Psychological',
				'Work Related:  Interpersonal',
				'Work Related:  Occupational Health',
				'Work Related:  Vocational'
			)
	),
	ppi as (
		select  
			ServiceFileID,
			Question,
			max(Answer2) Answer2 
		from 
			[db-au-dtc]..cliJobClientProfile 
		where 
			Answer2 is not null 
			and Question in (
				'Personal - Family or Relationship Issue',
				'Personal - Legal, Financial, Medical or Addiction Issue',
				'Personal - Psychological Issue',
				'Work Related - Interpersonal Issue',
				'Work Related - Occupational Health Issue',
				'Work Related - Vocational Issue'
			)
		group by 
			ServiceFileID,
			Question
	)
	select 
		ppi.ServiceFileID ServiceFileMemberID,
		replace(replace(replace(ppi.Question, ' - ', ' '), ' Issue', ''), 'Work Related', 'Work') PresentingIssueGroup1,
		ppi.Answer2 PresentingIssue1 
	into #src 
	from 
		pig 
		join ppi on ppi.ServiceFileID = pig.ServiceFileID and ppi.Question = pig.PresentingIssueGroup


	-- pnpServiceFileMember.PresentingIssue1 
	-- pnpServiceFileMember.PresentingIssueGroup1 
	update sfm 
	set 
		PresentingIssueGroup1 = #src.PresentingIssueGroup1,
		PresentingIssue1 = #src.PresentingIssue1 
	from 
		[db-au-dtc]..pnpServiceFileMember sfm 
		join #src on #src.ServiceFileMemberID = sfm.ServiceFileMemberID 
	-- where 
		--sfm.PresentingIssueGroup1 is null 
		--and sfm.PresentingIssue1 is null 

	
	-- pnpServiceFile.CounsellingType 
	update sf 
	set 
		CounsellingType = jcp.Answer2 
	from 
		[db-au-dtc]..pnpServiceFile sf 
		join [db-au-dtc]..cliJobClientProfile jcp on sf.ServiceFileID = jcp.ServiceFileID 
	where 
		Question like '1st Appointment Only%Appointment type requested' 
		and sf.CounsellingType is null 


	-- pnpServiceFile.EmploymentPeriod
	update sf 
	set 
		EmploymentPeriod = jcp.Answer2 
	from 
		[db-au-dtc]..pnpServiceFile sf 
		join [db-au-dtc]..cliJobClientProfile jcp on sf.ServiceFileID = jcp.ServiceFileID 
	where 
		Question = 'Employment Period' 
		and sf.EmploymentPeriod is null 


	-- pnpServiceFile.WorkPlaceDiversityGroup
	update sf 
	set 
		WorkPlaceDiversityGroup = jcp.Answer2 
	from 
		[db-au-dtc]..pnpServiceFile sf 
		join [db-au-dtc]..cliJobClientProfile jcp on sf.ServiceFileID = jcp.ServiceFileID 
	where 
		Question = 'Work Place Diversity Group' 
		and sf.WorkPlaceDiversityGroup is null 
	

	-- pnpServiceFile.CaseManagement
	update sf 
	set 
		CaseManagement = jcp.Answer2 
	from 
		[db-au-dtc]..pnpServiceFile sf 
		join [db-au-dtc]..cliJobClientProfile jcp on sf.ServiceFileID = jcp.ServiceFileID 
	where 
		Question = 'Case Management' 
		and sf.CaseManagement is null 
	

	-- pnpServiceFile.ReferralSource
	update sf 
	set 
		ReferralSource = case when jcp.Answer2 like 'Self: %' then 'Self'
			else jcp.Answer2
			end
	from 
		[db-au-dtc]..pnpServiceFile sf 
		join [db-au-dtc]..cliJobClientProfile jcp on sf.ServiceFileID = jcp.ServiceFileID 
	where 
		Question = 'Referral and EAP Information Source' 
		and sf.ReferralSource is null 
	

	-- pnpServiceFile.SelfReferralSource
	update sf 
	set 
		SelfReferralSource = case 
			when jcp.Answer2 = 'Self:  Internal Newsletter/Briefing' then 'Internal Newsletter'
			when jcp.Answer2 = 'Self:  Family Member' then 'Relative'
			else replace(replace(jcp.Answer2, 'Self:  ', ''), '/', ' / ')
		end
	from 
		[db-au-dtc]..pnpServiceFile sf 
		join [db-au-dtc]..cliJobClientProfile jcp on sf.ServiceFileID = jcp.ServiceFileID 
	where 
		question = 'Referral and EAP Information Source' 
		and Answer2 like 'Self: %'
		and sf.SelfReferralSource is null 


END
GO
