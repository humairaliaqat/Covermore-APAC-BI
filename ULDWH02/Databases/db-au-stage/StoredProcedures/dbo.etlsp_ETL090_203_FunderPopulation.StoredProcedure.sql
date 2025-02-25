USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_203_FunderPopulation]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_203_FunderPopulation] 
AS
BEGIN

	SET NOCOUNT ON;

	-- OrgEmployeeHist => FunderPopulation 
	-- Must come after the Funder and FunderDepartment

	/*
	OrgEmployeeHist_ID
	Org_ID
	AddDate
	AddUser
	ChangeDate
	ChangeUser
	AsAtDate
	employeeCnt
	RSSiteID
	RSArriveDate
	RSChangeDate
	Group_ID
	SubLevel_ID

	to

	FunderPopulationSK				
	FunderSK				Org_ID
	FunderDepartmentSK		Group_ID / SubLevel_ID
	FunderPopulationID		OrgEmployeeHist_ID
	Population				employeeCnt
	PopulationDate			AsAtDate
	PopulationStartDate		
	PopulationEndDate			
	Notes					*
	CreatedDatetime			RSArriveDate
	UpdatedDatetime			RSChangeDate
	DeletedDatetime
	*/

	-- 1. transform 
	if object_id('tempdb..#src') is not null drop table #src 

	select 
		*,
		convert(varchar(50), null) FunderDepartmentID
	into #src
	from [db-au-stage]..dtc_cli_OrgEmployeeHist 

	update #src 
	set FunderDepartmentID = 
		case 
			when Group_ID = '0' then 'CLI_GRP_' + SubLevel_ID 
			else 'CLI_GRP_' + Group_ID 
		end 

	if object_id('tempdb..#population') is not null drop table #population 

	select * into #population 
	from (
		select 
			f.FunderSK,
			fd.FunderDepartmentSK,
			'CLI_OEH_' + OrgEmployeeHist_ID FunderPopulationID,
			oeh.employeeCnt Population,
			convert(date, oeh.AsAtDate) PopulationDate,
			case 
				when lag(oeh.AsAtDate) over(partition by f.FunderID, fd.FunderDepartmentID order by oeh.AsAtDate) is null then '1900-01-01' 
				else convert(date, oeh.AsAtDate) 
			end PopulationStartDate,
			coalesce(dateadd(day, -1, lead(convert(date, oeh.AsAtDate)) over(partition by f.FunderID, fd.FunderDepartmentID order by oeh.AsAtDate)), '9999-12-31') PopulationEndDate,
			(select * from [db-au-stage]..dtc_cli_OrgEmployeeHist i where i.OrgEmployeeHist_ID = oeh.OrgEmployeeHist_ID for json path, without_array_wrapper) Notes,
			oeh.RSArriveDate CreatedDatetime,
			oeh.RSChangeDate UpdatedDatetime
		from 
			#src oeh 
			cross apply (
				select top 1 FunderSK, FunderID 
				from [db-au-dtc]..pnpFunder 
				where FunderID = 'CLI_ORG_' + oeh.Org_ID
			) f 
			outer apply (
				select top 1 FunderDepartmentSK, FunderDepartmentID 
				from [db-au-dtc]..pnpFunderDepartment 
				where FunderDepartmentID = oeh.FunderDepartmentID
			) fd
	) a

	-- 2. load 
	merge [db-au-dtc]..pnpFunderPopulation as tgt
	using #population 
		on #population.FunderPopulationID = tgt.FunderPopulationID 
	when not matched by target then 
		insert (
			FunderSK, FunderDepartmentSK, FunderPopulationID, 
			Population, PopulationDate, 
			PopulationStartDate, PopulationEndDate, 
			Notes, CreatedDatetime, UpdatedDatetime
		)
		values (
			#population.FunderSK, #population.FunderDepartmentSK, #population.FunderPopulationID, 
			#population.Population, #population.PopulationDate, 
			#population.PopulationStartDate, #population.PopulationEndDate, 
			#population.Notes, #population.CreatedDatetime, #population.UpdatedDatetime
	)
	when matched then update set 
		tgt.FunderSK = #population.FunderSK, 
		tgt.FunderDepartmentSK = #population.FunderDepartmentSK, 
		tgt.Population = #population.Population, 
		tgt.PopulationDate = #population.PopulationDate, 
		tgt.PopulationStartDate = #population.PopulationStartDate, 
		tgt.PopulationEndDate = #population.PopulationEndDate, 
		tgt.Notes = #population.Notes, 
		tgt.CreatedDatetime = #population.CreatedDatetime, 
		tgt.UpdatedDatetime = #population.UpdatedDatetime
	;

END

GO
