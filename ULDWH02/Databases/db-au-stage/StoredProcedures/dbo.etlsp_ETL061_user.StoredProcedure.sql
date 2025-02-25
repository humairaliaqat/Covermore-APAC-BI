USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL061_user]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL061_user]
as

SET NOCOUNT ON

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160209
Prerequisite:   N/A
Description:    transform salesforce user dimension
Parameters:		
				
Change History:
                20160209 - LT - Procedure created

*************************************************************************************************************************************/


if object_id('[db-au-stage].dbo.etl_sfUser') is not null drop table [db-au-stage].dbo.etl_sfUser
select
	u.ID as UserID,
	u.UserType,
	u.Username,
	u.Name,
	u.FirstName,
	u.LastName,
	u.Alias,
	u.IsActive,
	u.BDM__c as BDM,
	m.Manager,
	p.[Profile],
	u.Role_Type__c as RoleType,
	u.CommunityNickname,
	u.CompanyName,
	u.CRMUser__c as CRMUser,
	u.Department,
	u.Division,
	u.Title,
	u.Street,
	u.City,
	u.[State],
	u.PostalCode as Postcode,
	u.Country,
	u.Phone,
	u.MobilePhone,
	u.Fax,
	u.Email,
	c.CreatedBy,
	u.CreatedDate,
	u.LastLoginDate,
	lm.LastModifiedBy,
	u.LastModifiedDate,
	u.LastReferencedDate,
	u.LastViewedDate,
	u.TimeZoneSidKey as Timezone
into [db-au-stage].dbo.etl_sfUser
from
	sforce_user u
	outer apply
	(
		select top 1 Name as Manager
		from sforce_user
		where ID = u.ManagerID
	) m
	outer apply
	(
		select top 1 Name as CreatedBy
		from sforce_user
		where ID = u.CreatedById
	) c
	outer apply
	(
		select top 1 Name as LastModifiedBy
		from sforce_user
		where ID = u.LastModifiedById
	) lm
	outer apply
	(
		select top 1 Name as [Profile]
		from sforce_profile
		where ID = u.ProfileID
	) p


if object_id('[db-au-cmdwh].dbo.sfUser') is null
begin
	create table [db-au-cmdwh].[dbo].[sfUser]
	(
		[UserID] [nvarchar](18) NULL,
		[UserType] [nvarchar](40) NULL,
		[Username] [nvarchar](80) NULL,
		[Name] [nvarchar](121) NULL,
		[FirstName] [nvarchar](40) NULL,
		[LastName] [nvarchar](80) NULL,
		[Alias] [nvarchar](8) NULL,
		[IsActive] [bit] NULL,
		[BDM] [nvarchar](250) NULL,
		[Manager] [nvarchar](121) NULL,
		[Profile] [nvarchar](255) NULL,
		[RoleType] [nvarchar](255) NULL,
		[CommunityNickname] [nvarchar](40) NULL,
		[CompanyName] [nvarchar](80) NULL,
		[CRMUser] [nvarchar](80) NULL,
		[Department] [nvarchar](80) NULL,
		[Division] [nvarchar](80) NULL,
		[Title] [nvarchar](80) NULL,
		[Street] [nvarchar](255) NULL,
		[City] [nvarchar](40) NULL,
		[State] [nvarchar](80) NULL,
		[Postcode] [nvarchar](20) NULL,
		[Country] [nvarchar](80) NULL,
		[Phone] [nvarchar](40) NULL,
		[MobilePhone] [nvarchar](40) NULL,
		[Fax] [nvarchar](40) NULL,
		[Email] [nvarchar](128) NULL,
		[CreatedBy] [nvarchar](121) NULL,
		[CreatedDate] [datetime] NULL,
		[LastLoginDate] [datetime] NULL,
		[LastModifiedBy] [nvarchar](121) NULL,
		[LastModifiedDate] [datetime] NULL,
		[LastReferencedDate] [datetime] NULL,
		[LastViewedDate] [datetime] NULL,
		[Timezone] [nvarchar](40) NULL
	) 
       create clustered index idx_sfUser_UserID on [db-au-cmdwh].dbo.sfUser(UserID)
	   create nonclustered index idx_sfUser_UserType on [db-au-cmdwh].dbo.sfUser(UserType)
	   create nonclustered index idx_sfUser_UserName on [db-au-cmdwh].dbo.sfUser(UserName)
       create nonclustered index idx_sfUser_Name on [db-au-cmdwh].dbo.sfUser(Name)
       create nonclustered index idx_sfUser_isActive on [db-au-cmdwh].dbo.sfUser(isActive)
       create nonclustered index idx_sfUser_Manager on [db-au-cmdwh].dbo.sfUser(Manager)
       create nonclustered index idx_sfUser_RoleType on [db-au-cmdwh].dbo.sfUser(RoleType)
end
else
	delete a
	from [db-au-cmdwh].dbo.sfUser a
		inner join [db-au-stage].dbo.etl_sfUser b on
			a.UserID = b.UserID



insert [db-au-cmdwh].dbo.sfUser with (tablockx)
(
	[UserID],
	[UserType],
	[Username],
	[Name],
	[FirstName],
	[LastName],
	[Alias],
	[IsActive],
	[BDM],
	[Manager],
	[Profile],
	[RoleType],
	[CommunityNickname],
	[CompanyName],
	[CRMUser],
	[Department],
	[Division],
	[Title],
	[Street],
	[City],
	[State],
	[Postcode],
	[Country],
	[Phone],
	[MobilePhone],
	[Fax],
	[Email],
	[CreatedBy],
	[CreatedDate],
	[LastLoginDate],
	[LastModifiedBy],
	[LastModifiedDate],
	[LastReferencedDate],
	[LastViewedDate],
	[Timezone]
)
select
	[UserID],
	[UserType],
	[Username],
	[Name],
	[FirstName],
	[LastName],
	[Alias],
	[IsActive],
	[BDM],
	[Manager],
	[Profile],
	[RoleType],
	[CommunityNickname],
	[CompanyName],
	[CRMUser],
	[Department],
	[Division],
	[Title],
	[Street],
	[City],
	[State],
	[Postcode],
	[Country],
	[Phone],
	[MobilePhone],
	[Fax],
	[Email],
	[CreatedBy],
	[CreatedDate],
	[LastLoginDate],
	[LastModifiedBy],
	[LastModifiedDate],
	[LastReferencedDate],
	[LastViewedDate],
	[Timezone]
from
	[db-au-stage].dbo.etl_sfUser
GO
