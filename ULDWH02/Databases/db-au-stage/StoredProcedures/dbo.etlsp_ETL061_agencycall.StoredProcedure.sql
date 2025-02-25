USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL061_agencycall]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL061_agencycall]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160713
Prerequisite:   N/A
Description:    transform salesforce agency calls table
Parameters:		
				
Change History:
                20160713 - LT - Procedure created
				20171010 - LT - Updated sfAgencyCall table, and full re-import of AgencyCall data from Salesforce.com

*************************************************************************************************************************************/


if object_id('[db-au-cmdwh].dbo.sfAgencyCall') is null
begin
	create table [db-au-cmdwh].dbo.sfAgencyCall
	(
		CallID nvarchar(18) null,
		CallNumber nvarchar(80) null,
		AccountID nvarchar(18) null,
		AgencyID nvarchar(1300) null,
		CallStartTime datetime null,
		CallEndTime datetime null,
		CallDuration int null,
		CallDurationText varchar(1300) null,
		CallType nvarchar(255) null,
		CallCategory nvarchar(255) null,
		CallSubCategory nvarchar(255) null,
		ConsultantID nvarchar(18) null,
		ConsultantName nvarchar(255) null,
		CreatedBy nvarchar(255) null,
		CreatedDate datetime null,
		isDeleted bit null,
		LastActivityDate date null,
		LastModifiedBy nvarchar(255) null,
		LastModifiedDate datetime null,
		RecordType varchar(255) null,
		RoleType nvarchar(1300) null,
		StopCall nvarchar(1300) null,
		SurveyEmail nvarchar(255) null,
		SystemModstamp datetime null,
		Timezone nvarchar(200) null,
		CallComment nvarchar(max) null
	)
    create clustered index idx_sfAgencyCall_CallID on [db-au-cmdwh].dbo.sfAgencyCall(CallID)
	create nonclustered index idx_sfAgencyCall_AccountID on [db-au-cmdwh].dbo.sfAgencyCall(AccountID)
	create nonclustered index idx_sfAgencyCall_CallStartTime on [db-au-cmdwh].dbo.sfAgencyCall(CallStartTime)
    create nonclustered index idx_sfAgencyCall_CallType on [db-au-cmdwh].dbo.sfAgencyCall(CallType)
    create nonclustered index idx_sfAgencyCall_CallCategory on [db-au-cmdwh].dbo.sfAgencyCall(CallCategory)
    create nonclustered index idx_sfAgencyCall_CallSubCategory on [db-au-cmdwh].dbo.sfAgencyCall(CallSubCategory)
end
else
	delete a
	from 
		[db-au-cmdwh].dbo.sfAgencyCall a 
		inner join [db-au-stage].dbo.sforce_AgencyCalls b on
			a.CallID = b.ID

			
insert [db-au-cmdwh].dbo.sfAgencyCall with (tablockx)
(
	CallID,
	CallNumber,
	AccountID,
	AgencyID,
	CallStartTime,
	CallEndTime,
	CallDuration,
	CallDurationText,
	CallType,
	CallCategory,
	CallSubCategory,
	ConsultantID,
	ConsultantName,
	CreatedBy,
	CreatedDate,
	isDeleted,
	LastActivityDate,
	LastModifiedBy,
	LastModifiedDate,
	RecordType,
	RoleType,
	StopCall,
	SurveyEmail,
	SystemModstamp,
	Timezone,
	CallComment
)
select
	c.ID as CallID,
	c.[Name] as CallNumber,
	c.Account_Name__c as AccountID,
	c.AgencyID__c as AgencyID,
	c.Call_Start_Time__c as CallStartTime,
	c.CallEndTime__c as CallEndTime,
	c.Call_Duration_Number__c as CallDuration,
	c.Call_duration__c as CallDurationText,
	c.Call_Type__c as CallType,
	c.CallCategory__c as CallCategory,
	c.CallSubCategory__c as CallSubCategory,
	c.Consultant_Name__c as ConsultantID,
	cons.ConsultantName,
	createdby.CreatedBy,
	c.CreatedDate,
	c.isDeleted,
	c.LastActivityDate,
	lastmodified.LastModifiedBy,
	c.LastModifiedDate,
	rectype.RecordType,
	c.Role_Type__c as RoleType,
	c.Stop_Call__c as StopCall,
	c.Survey_Email__c as SurveyEmail,
	c.SystemModstamp,
	c.Time_Zone__c as TimeZone,
	c.Call_Comment__c as CallComment
from
	sforce_AgencyCalls c
	outer apply
	(
		select top 1 Name as ConsultantName
		from [db-au-stage].dbo.sforce_Contact
		where ID = c.Consultant_Name__c
	) cons
	outer apply
	(
		select top 1 Name as CreatedBy
		from [db-au-stage].dbo.sforce_user
		where ID = c.CreatedByID
	) createdby
	outer apply
	(
		select top 1 Name as LastModifiedBy
		from [db-au-stage].dbo.sforce_user
		where ID = c.LastModifiedById
	) lastmodified
	outer apply
	(
		select top 1 Name as RecordType
		from [db-au-stage].dbo.sforce_RecordType
		where ID = c.RecordTypeId
	) rectype



GO
