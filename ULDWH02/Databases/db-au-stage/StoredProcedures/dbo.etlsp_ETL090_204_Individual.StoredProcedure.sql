USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_204_Individual]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_204_Individual] 
AS
BEGIN

	SET NOCOUNT ON;

	-- Person => Individual

-- 1. transform
if object_id('tempdb..#person') is not null drop table #person 

select 
	1 IsCurrent,
	'1900-01-01' StartDate,
	'9999-12-31' EndDate,
	case when p.Group_ID is null or len(p.Group_ID) between 1 and 20 then null else 'CLI_GRP_' + p.Group_ID end Group_ID,
	null FunderSK,
	null FunderDepartmentSK,
	'CLI_PER_' + p.Per_ID IndividualID,
	'CLI_ORG_' + Org_ID FunderID,
	case when Group_ID is null or len(Group_ID) between 1 and 20 then null else 'CLI_GRP_' + Group_ID end FunderDepartmentID,
	FirstName,
	LastName,
	Address1 AddressLine1,
	Address2 AddressLine2,
	City,
	[State],
	[State] StateShort,
	convert(nvarchar(30), Country) Country,
	Zip Postcode,
	case when isnull(Gender,0) = -1 then 'Male' else 'Female' end Gender,
	BirthDate DateOfBirth,
	(select * from [db-au-stage]..dtc_cli_person i where i.Per_ID = p.Per_ID for json path, without_array_wrapper) Notes,
	AddDate CreatedDatetime,
	ChangeDate UpdatedDatetime,
	AddUser CreatedBy,
	ChangeUser UpdatedBy,
	Title,
	EmployeeIdNr EmployeeID
into #person
from 
	[db-au-stage]..dtc_cli_person p 
	left join [db-au-stage]..dtc_cli_base_person bp on bp.Per_id = p.Per_ID 
	left join [db-au-stage]..dtc_cli_person_lookup pl on pl.uniqueindid = bp.pene_id 
where 
	pl.kindid is null 	-- exclude the ones that have already been imported	


-- create lookup table for funder
if object_id('tempdb..#funder') is not null drop table #funder 

select 
	f.FunderSK,
	coalesce('CLI_ORG_' + bo.Org_id, f.FunderID) FunderID
into #funder
from 
	[db-au-dtc].dbo.pnpFunder f 
	left join [db-au-stage].dbo.dtc_cli_org_lookup ol on convert(varchar, ol.kfunderid) = f.FunderID 
	left join [db-au-stage].dbo.dtc_cli_base_org bo on bo.Pene_id = ol.uniquefunderid 
where 
	f.IsCurrent = 1

create index idx_tmp_funder_funderid on #funder (FunderID)

-- create lookup table for funderdepartment
if object_id('tempdb..#funderdepartment') is not null drop table #funderdepartment 

select 
	fd.FunderDepartmentSK,
	coalesce('CLI_GRP_' + bg.Group_ID, fd.FunderDepartmentID) FunderDepartmentID
into #funderdepartment
from 
	[db-au-dtc].dbo.pnpFunderDepartment fd 
	left join [db-au-stage].dbo.dtc_cli_group_lookup gl on convert(varchar, gl.kfunderdeptid) = fd.FunderDepartmentID 
	left join [db-au-stage].dbo.dtc_cli_base_group bg on bg.Pene_id = gl.uniquedepartmentid 

create index idx_tmp_funderdepartment_funderdepartmentid on #funderdepartment (FunderDepartmentID)	


update p set 
	FunderSK = f.FunderSK,
	FunderDepartmentSK = fd.FunderDepartmentSK 
from 
	#person p 
	left join #funder f on f.FunderID = p.FunderID
	left join #funderdepartment fd on fd.FunderDepartmentID = p.FunderDepartmentID 


-- data cleansing
update #person
set Country = 'Australia'
where Country is null
AND [State] in ('NSW','QLD','VIC','ACT','SA' ,'NT' ,'TAS','WA')

update #person
set [State] = null, Country = 'Singapore'
where [State] in ('SG','Sin','SNG','SinG','SinGAPORE')
or Country = 'Singapore'

update #person
set [State] = null, Country = 'New Zealand'
where [State] in ('NZ','New Zealand')

update #person
set [State] = null, Country = 'Jordan'
where [State] in ('JOR')

update #person
set [State] = null, Country = 'United Arab Emirates'
where [State] in ('UAE')

update #person
set [State] = null, Country = 'Nigeria'
where [State] in ('NG')

update #person
set [State] = null, Country = 'Fiji'
where Country in ('Fiji') OR
[State] = 'FIJI'

update #person
set [State] = null, Country = 'South Africa'
where [State] in ('ZAR')

update #person
set [State] = null, Country = 'Hong Kong'
where [State] in ('HKG','HK')

update #person
set [State] = null, Country = 'India'
where [State] in ('in')

update #person
set [State] = null, Country = 'Indonesia'
where [State] in ('JAKARTA','inD')

update #person
set [State] = null, Country = 'Spain'
where [State] in ('ESP')

update #person
set [State] = null, Country = 'China'
where [State] in ('CHN')

update #person
set [State] = null, Country = 'Canada'
where [State] in ('CAN','CANADA')

update #person
set [State] = null, Country = 'HUNGARY'
where [State] in ('HUNGARY')

update #person
set [State] = null, Country = 'Malaysia'
where [State] in ('MAL')

update #person
set [State] = null, Country = 'Japan'
where [State] in ('JAP')

update #person
set [State] = null, Country = 'United Kingdom'
where [State] in ('TN2','KENT ','KENT TN2','MILTON KEYNES','UK')
OR [Country] in ('UK','England')

update #person
set [State] = null, Country = 'Papua New Guinea'
where [State] in ('PNG')

update #person
set [State] = null, Country = 'Philippines'
where [State] in ('PHILIPPinES','PHP')

update #person
set [State] = null, Country = 'Thailand'
where [State] in ('THA','BANGKOK')

update #person
set [State] = null, Country = 'Paraguay'
where [State] in ('PAR')

update #person
set [State] = null, Country = 'United States'
where Country = 'USA'
OR [State] = 'USA'

update #person
set [State] = null, Country = 'Vietnam'
where [State] in ('VIE','MO')

update #person
set [State] = null, Country = 'France'
where [State] = 'FR'

update #person
set [State] = null, Country = null
where [State] in ('N/A','NA','NCD','EAO','EAP','IL','ISA','ONLinE ASSISTANCE','ONLinE','.','TBC','XXXX','inT','MAY','MA','KONSANTinOS
','BROOKLYN','')
or [State] = ''
or ([State] is null and Country = 'Australia')

update #person
set [State] = null
where Country <> 'Australia' 
AND [State] is null

update #person
set [State] = 
	case when IsNull(Country,'Australia') = 'Australia' then 
		case [State]
			when 'NSW' then 'New South Wales'
			when 'NSW04 14602159' then 'New South Wales'
			when '`NSW' then 'New South Wales'
			when 'ONNSW' then 'New South Wales'
			when 'HRN' then 'New South Wales'
			when '2010' then 'New South Wales'
			when 'SYDNEY' then 'New South Wales'
			when 'SYD' then 'New South Wales'
			when 'QLD' then 'Queensland'
			when 'QLD4003' then 'Queensland'
			when 'QLF' then 'Queensland'
			when 'VIC' then 'Victoria'
			when 'VICVIC' then 'Victoria'
			when 'VUIC' then 'Victoria'
			when 'ACT' then 'ACT'
			when 'SA'  then 'South Australia'
			when 'NT'  then 'Northern Territory'
			when 'HOBART' then 'Tasmania'
			when 'TAS' then 'Tasmania'
			when 'WA'  then 'Western Australia'
			when 'WAP'  then 'Western Australia'
			when '2170' then 'ACT'
			when '4701' then 'Queensland'
			when 'NSW 2039' then 'New South Wales'
			when '2034' then 'New South Wales'
			when 'MSW' then 'New South Wales'
			when 'NS' then 'New South Wales'
			when 'NSDW' then 'New South Wales'
			when '3155' then 'Victoria'
			when '3672' then 'Victoria'
			when 'V' then 'Victoria'
			when 'VICX' then 'Victoria'
			when 'VIIC' then 'Victoria'
			when 'VOC' then 'Victoria'
			when 'GMY' then 'Victoria'
			when 'W.A.' then 'Victoria'
			when '4005' then 'Queensland'
			when '4068' then 'Queensland'
			when 'Q' then 'Queensland'
			when 'P' then 'Queensland'
			when 'SKO' then NULL
			when 'DARWin' then 'Northern Territory'
		else [State] end
	else [State] end

	
update #person
set StateShort = 
	case when IsNull(Country,'Australia') = 'Australia' then 
		case [State]
			when 'NSW04 14602159' then 'NSW'
			when '`NSW' then 'NSW'
			when 'ONNSW' then 'NSW'
			when 'HRN' then 'NSW'
			when '2010' then 'NSW'
			when 'SYDNEY' then 'NSW'
			when 'SYD' then 'NSW'
			when 'QLD4003' then 'QLD'
			when 'QLF' then 'QLD'
			when 'VIC' then 'VIC'
			when 'VICVIC' then 'VIC'
			when 'VUIC' then 'VIC'
			when 'HOBART' then 'TAS'
			when 'WAP'  then 'WA'
			when '2170' then 'ACT'
			when '4701' then 'QLD'
			when 'NSW 2039' then 'NSW'
			when '2034' then 'NSW'
			when 'MSW' then 'NSW'
			when 'NS' then 'NSW'
			when 'NSDW' then 'NSW'
			when '3155' then 'VIC'
			when '3672' then 'VIC'
			when 'V' then 'VIC'
			when 'VICX' then 'VIC'
			when 'VIIC' then 'VIC'
			when 'VOC' then 'VIC'
			when 'GMY' then 'VIC'
			when 'W.A.' then 'VIC'
			when '4005' then 'QLD'
			when '4068' then 'QLD'
			when 'Q' then 'QLD'
			when 'P' then 'QLD'
			when 'SKO' then NULL
			when 'DARWin' then 'NT'
		else StateShort end
	else StateShort end	
	

-- 2. load
merge [db-au-dtc].dbo.pnpIndividual as tgt
using #person
	on #person.IndividualID = tgt.IndividualID 
when not matched by target then 
	insert (
		IsCurrent,
		StartDate,
		EndDate,
		FunderSK,
		FunderDepartmentSK,
		IndividualID,
		FunderID,
		FunderDepartmentID,
		FirstName,
		LastName,
		AddressLine1,
		AddressLine2,
		City,
		[State],
		StateShort,
		Country,
		Postcode,
		Gender,
		DateOfBirth,
		Notes,
		CreatedDatetime,
		UpdatedDatetime,
		CreatedBy,
		UpdatedBy,
		Title,
		EmployeeID
	)
	values (
		#person.IsCurrent,
		#person.StartDate,
		#person.EndDate,
		#person.FunderSK,
		#person.FunderDepartmentSK,
		#person.IndividualID,
		#person.FunderID,
		#person.FunderDepartmentID,
		#person.FirstName,
		#person.LastName,
		#person.AddressLine1,
		#person.AddressLine2,
		#person.City,
		#person.[State],
		#person.StateShort,
		#person.Country,
		#person.Postcode,
		#person.Gender,
		#person.DateOfBirth,
		#person.Notes,
		#person.CreatedDatetime,
		#person.UpdatedDatetime,
		#person.CreatedBy,
		#person.UpdatedBy,
		#person.Title,
		#person.EmployeeID
	)
when matched then update set 
	tgt.IsCurrent = #person.IsCurrent,
	tgt.StartDate = #person.StartDate,
	tgt.EndDate = #person.EndDate,
	tgt.FunderSK = #person.FunderSK,
	tgt.FunderDepartmentSK = #person.FunderDepartmentSK,
	tgt.FunderID = #person.FunderID,
	tgt.FunderDepartmentID = #person.FunderDepartmentID,
	tgt.FirstName = #person.FirstName,
	tgt.LastName = #person.LastName,
	tgt.AddressLine1 = #person.AddressLine1,
	tgt.AddressLine2 = #person.AddressLine2,
	tgt.City = #person.City,
	tgt.[State] = #person.[State],
	tgt.StateShort = #person.StateShort,
	tgt.Country = #person.Country,
	tgt.Postcode = #person.Postcode,
	tgt.Gender = #person.Gender,
	tgt.DateOfBirth = #person.DateOfBirth,
	tgt.Notes = #person.Notes,
	tgt.CreatedDatetime = #person.CreatedDatetime,
	tgt.UpdatedDatetime = #person.UpdatedDatetime,
	tgt.CreatedBy = #person.CreatedBy,
	tgt.UpdatedBy = #person.UpdatedBy,
	tgt.Title = #person.Title,
	tgt.EmployeeID = #person.EmployeeID
;


END

GO
