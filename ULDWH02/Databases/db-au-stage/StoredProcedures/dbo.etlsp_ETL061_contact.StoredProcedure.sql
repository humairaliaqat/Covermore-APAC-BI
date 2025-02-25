USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL061_contact]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL061_contact]
as

SET NOCOUNT ON

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160713
Prerequisite:   N/A
Description:    transform salesforce contact table
Parameters:		
				
Change History:
                20160713 - LT - Procedure created

*************************************************************************************************************************************/

if object_id('[db-au-cmdwh].dbo.sfContact') is null
begin
	create table [db-au-cmdwh].dbo.sfContact
	(
		ContactID nvarchar(18) null,
		AccountID nvarchar(18) null,
		AgencyID nvarchar(255) null,
		ConsultantID nvarchar(255) null,
		Title nvarchar(255) null,
		FirstName nvarchar(255) null,
		LastName nvarchar(255) null,
		Name nvarchar(255) null,
		DOB date null,
		Status nvarchar(255) null,
		UserType nvarchar(255) null,
		CreatedBy nvarchar(255) null,
		CreatedDate datetime null,
		CRMUserName nvarchar(255) null,
		Department nvarchar(255) null,
		Description nvarchar(max) null,
		Phone nvarchar(255) null,
		HomePhone nvarchar(255) null,
		Fax nvarchar(255) null,
		Email nvarchar(255) null,
		EmailBouncedDate datetime null,
		EmailBouncedReason nvarchar(255) null,
		isDeleted bit null,
		isEmailBounced bit null,
		CourseName nvarchar(255) null,
		ExamResult nvarchar(255) null,
		ExamTime datetime null,
		LastModifiedBy nvarchar(255) null,
		LastModifiedDate datetime null,
		RecordType nvarchar(255) null,
		SystemModStamp datetime null
	)
    create clustered index idx_sfContact_ContactID on [db-au-cmdwh].dbo.sfContact(ContactID)
	create nonclustered index idx_sfContact_AccountID on [db-au-cmdwh].dbo.sfContact(AccountID)
	create nonclustered index idx_sfContact_AgencyID on [db-au-cmdwh].dbo.sfContact(AgencyID)
    create nonclustered index idx_sfContact_ConsultantID on [db-au-cmdwh].dbo.sfContact(ConsultantID)
end
else
	delete a
	from 
		[db-au-cmdwh].dbo.sfContact a 
		inner join [db-au-stage].dbo.sforce_Contact b on
			a.ContactID = b.ID

			
insert [db-au-cmdwh].dbo.sfContact with (tablockx)
(
	ContactID,
	AccountID,
	AgencyID,
	ConsultantID,
	Title,
	FirstName,
	LastName,
	Name,
	DOB,
	Status,
	UserType,
	CreatedBy,
	CreatedDate,
	CRMUserName,
	Department,
	Description,
	Phone,
	HomePhone,
	Fax,
	Email,
	EmailBouncedDate,
	EmailBouncedReason,
	isDeleted,
	isEmailBounced,
	CourseName,
	ExamResult,
	ExamTime,
	LastModifiedBy,
	LastModifiedDate,
	RecordType,
	SystemModStamp
)
select
	c.ID as ContactID,
	c.AccountID,
	c.AgencyID,
	c.ConsultantID,
	c.Title,
	c.FirstName,
	c.LastName,
	c.Name,
	c.BirthDate as DOB,
	c.Status,
	c.UserType,
	createdby.CreatedBy,
	c.CreatedDate,
	c.CRMUserName,
	c.Department,
	c.Description,
	c.Phone,
	c.HomePhone,
	c.Fax,
	c.Email,
	c.EmailBouncedDate,
	c.EmailBouncedReason,
	c.isDeleted,
	c.isEmailBounced,
	c.CourseName,
	c.ExamResult,
	c.ExamTime,
	lastmodified.LastModifiedBy,
	c.LastModifiedDate,
	rectype.RecordType,
	c.SystemModStamp
from
	sforce_Contact c
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
