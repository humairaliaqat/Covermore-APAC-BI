USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpTravellers_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_corpTravellers_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine travellers from AU, NZ, AU into one table
/*************************************************************/
if object_id('[db-au-stage].dbo.etl_corpTravellers') is not null drop table [db-au-stage].dbo.etl_corpTravellers

select
  'AU' as CountryKey,
  left('AU-' + cast(b.TravellerID as varchar),41) as TravellerKey,
  left('AU-' + cast(b.RegistrationID as varchar),41) as RegistrationKey,
  b.TravellerID,
  b.RegistrationID,
  b.Title,
  b.FirstName,
  b.Surname,
  b.DOB,
  b.Age,
  b.isPrimary,
  b.isAdult,
  e.EMCID,
  e.IssuedDt as EMCIssuedDate,
  e.EMCAppNo as EMCAssessmentNo,
  e.EMCLoad,
  e.EMCAccept,
  c.ClosingID,
  c.IssuedDt as ClosingIssuedDate,
  c.ClosingLoad,
  c.CloseAccept as ClosingAccept,
  c.ExtraDays as ClosingExtraDays,
  f.FreeDaysID,
  f.FreeDays,
  f.FreeDaysLoad,
  f.IssueDate as FreeDaysIssuedDate
into [db-au-stage].dbo.etl_corpTravellers
from
  [db-au-stage].dbo.corp_tblTravellers_au b
  left join [db-au-stage].dbo.corp_tblEMC_au e on b.TravellerID = e.TravellerID
  left join [db-au-stage].dbo.corp_tblClosings_au c on b.TravellerID = c.TravellerID
  left join [db-au-stage].dbo.corp_tblFreeDays_au f on b.TravellerID = f.TravellerID



if object_id('[db-au-cmdwh].dbo.corpTravellers') is null
begin
    create table [db-au-cmdwh].dbo.corpTravellers
    (    
		CountryKey varchar(2) not null,
		TravellerKey varchar(41) null,
		RegistrationKey varchar(41) null,
		TravellerID int null,
		RegistrationID int NULL,
		Title varchar(10) null,
		FirstName varchar(200) null,
		Surname varchar(200) null,
		DOB datetime null,
		Age int null,
		isPrimary bit null,
		isAdult bit null,
		EMCID int null,
		EMCIssuedDate datetime null,
		EMCAssessmentNo varchar(50) null,
		EMCLoad money null,
		EMCAccept bit null,
		ClosingID int null,
		ClosingIssuedDate datetime null,
		ClosingLoad money null,
		ClosingAccept bit null,
		ClosingExtraDays int null,
		FreeDaysID int null,
		FreeDays int null,
		FreeDaysLoad money null,
		FreeDaysIssuedDate datetime null
    )
    if exists(select name from sys.indexes where name = 'idx_corpTravellers_CountryKey')
    drop index idx_corpTravellers_CountryKey on corpTravellers.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpTravellers_TravellerKey')
    drop index idx_corpTravellers_TravellerKey on corpTravellers.TravellerKey
    
    if exists(select name from sys.indexes where name = 'idx_corpTravellers_RegistrationKey')
    drop index idx_corpTravellers_RegistrationKey on corpTravellers.RegistrationKey
  
    create index idx_corpTravellers_CountryKey on [db-au-cmdwh].dbo.corpTravellers(CountryKey)
    create index idx_corpTravellers_TravellerKey on [db-au-cmdwh].dbo.corpTravellers(TravellerKey)
    create index idx_corpTravellers_RegistrationKey on [db-au-cmdwh].dbo.corpTravellers(RegistrationKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpTravellers



/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpTravellers to [db-au-cmdwh].dbo.corpTravellers
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpTravellers with (tablock)
(
	CountryKey,
	TravellerKey,
	RegistrationKey,
	TravellerID,
	RegistrationID,
	Title,
	FirstName,
	Surname,
	DOB,
	Age,
	isPrimary,
	isAdult,
	EMCID,
	EMCIssuedDate,
	EMCAssessmentNo,
	EMCLoad,
	EMCAccept,
	ClosingID,
	ClosingIssuedDate,
	ClosingLoad,
	ClosingAccept,
	ClosingExtraDays,
	FreeDaysID,
	FreeDays,
	FreeDaysLoad,
	FreeDaysIssuedDate
)
select
	CountryKey,
	TravellerKey,
	RegistrationKey,
	TravellerID,
	RegistrationID,
	Title,
	FirstName,
	Surname,
	DOB,
	Age,
	isPrimary,
	isAdult,
	EMCID,
	EMCIssuedDate,
	EMCAssessmentNo,
	EMCLoad,
	EMCAccept,
	ClosingID,
	ClosingIssuedDate,
	ClosingLoad,
	ClosingAccept,
	ClosingExtraDays,
	FreeDaysID,
	FreeDays,
	FreeDaysLoad,
	FreeDaysIssuedDate	
from [db-au-stage].dbo.etl_corpTravellers
GO
