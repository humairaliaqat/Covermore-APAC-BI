USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpRegistration_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_corpRegistration_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine registration from AU, NZ, AU into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpRegistration') is not null drop table [db-au-stage].dbo.etl_corpRegistration

select
  'AU' as CountryKey,
  left('AU-' + cast(b.RegistrationID as varchar),41) as RegistrationKey,
  left('AU-' + cast(b.QtID as varchar),10) as QuoteKey,
  left('AU-' + cast(b.EmpID as varchar),53) as EmployeeKey,  
  b.RegistrationID,
  b.QtID as QuoteID,
  b.EmpID as EmployeeID,
  b.DestTypeID as DestinationTypeID,
  (select top 1 DestDesc from dbo.corp_tblDestTypes_au where DestTypeID = b.DestTypeID) as Destination,
  b.[State],
  b.Email,
  b.IssueDate,
  b.TripStart,
  b.TripEnd,
  b.Duration,
  b.[Status],
  b.CancelDate
into [db-au-stage].dbo.etl_corpRegistration
from
  [db-au-stage].dbo.corp_tblRegistration_au b



if object_id('[db-au-cmdwh].dbo.corpRegistration') is null
begin
    create table [db-au-cmdwh].dbo.corpRegistration
    (    
		CountryKey varchar(2) not null,
		RegistrationKey varchar(41) null,
		QuoteKey varchar(10) null,
		EmployeeKey varchar(53) null,
		RegistrationID [int] NULL,
		QuoteID [int] NOT NULL,
		EmpployeeID [varchar](50) NULL,
		DestinationTypeID [int] NULL,
		Destination [varchar](150) NULL,
		[State] [varchar](5) NULL,
		[Email] [varchar](510) NULL,
		[Issuedate] [datetime] NULL,
		[TripStart] [datetime] NULL,
		[TripEnd] [datetime] NULL,
		[Duration] [int] NULL,
		[Status] [varchar](20) NULL,
		[CancelDate] [datetime] NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpRegistration_CountryKey')
    drop index idx_corpRegistration_CountryKey on corpRegistration.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpRegistration_RegistrationKey')
    drop index idx_corpRegistration_RegistrationKey on corpRegistration.RegistrationKey

    if exists(select name from sys.indexes where name = 'idx_corpRegistration_QuoteKey')
    drop index idx_corpRegistration_QuoteKey on corpRegistration.QuoteKey

    if exists(select name from sys.indexes where name = 'idx_corpRegistration_EmployeeKey')
    drop index idx_corpRegistration_EmployeeKey on corpRegistration.EmployeeKey
    
    create index idx_corpRegistration_CountryKey on [db-au-cmdwh].dbo.corpRegistration(CountryKey)
    create index idx_corpRegistration_RegistrationKey on [db-au-cmdwh].dbo.corpRegistration(RegistrationKey)
    create index idx_corpRegistration_QuoteKey on [db-au-cmdwh].dbo.corpRegistration(QuoteKey)
    create index idx_corpRegistration_EmployeeKey on [db-au-cmdwh].dbo.corpRegistration(EmployeeKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpRegistration



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpRegistration to [db-au-cmdwh].dbo.corpRegistration
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpRegistration with (tablock)
(
	CountryKey,
	RegistrationKey,
	QuoteKey,
	EmployeeKey,
	RegistrationID,
	QuoteID,
	EmpployeeID,
	DestinationTypeID,
	Destination,
	[State],
	[Email],
	[Issuedate],
	[TripStart],
	[TripEnd],
	[Duration],
	[Status],
	[CancelDate]
)
select
	CountryKey,
	RegistrationKey,
	QuoteKey,
	EmployeeKey,
	RegistrationID,
	QuoteID,
	EmployeeID,
	DestinationTypeID,
	Destination,
	[State],
	[Email],
	[Issuedate],
	[TripStart],
	[TripEnd],
	[Duration],
	[Status],
	[CancelDate]
from [db-au-stage].dbo.etl_corpRegistration
GO
