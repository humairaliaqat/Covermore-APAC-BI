USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL038_bobjUser]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL038_bobjUser]
as

SET NOCOUNT ON

if object_id('[db-au-cmdwh].dbo.bobjUser') is null
begin
	create table [db-au-cmdwh].dbo.bobjUser
	(
		UserID float null,
		UserName nvarchar(255) null,
		UserFullName nvarchar(255) null,
		[Owner] nvarchar(255) null,
		[Description] nvarchar(255) null,
		EmailAddress nvarchar(255) null,
		CreateDate datetime null,
		UpdateDate datetime null,
		LastLogonDate datetime null,
		Kind nvarchar(255) null
	)
end	
else
	truncate table [db-au-cmdwh].dbo.bobjUser


insert [db-au-cmdwh].dbo.bobjUser with(tablock)
(
	UserID,
	UserName,
	UserFullName,
	[Owner],
	[Description],
	EmailAddress,
	CreateDate,
	UpdateDate,
	LastLogonDate,
	Kind
)
select
	[SI_ID] as UserID,
	[SI_NAME] as UserName,
	[SI_USERFULLNAME] as UserFullName,
	[SI_OWNER] as [Owner],
	[SI_DESCRIPTION] as [Description],	
	[SI_EMAIL_ADDRESS] as EmailAddress,	
	[SI_CREATION_TIME] as CreateDate,
	[SI_UPDATE_TS] as UpdateDate,
	[SI_LASTLOGONTIME] as LastLogonDate,	
	[SI_KIND] as Kind	
from
	[db-au-stage].dbo.etl_usrBIReportUsers
GO
