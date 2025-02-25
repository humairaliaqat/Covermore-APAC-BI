USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_302_Timesheet]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Vincent Lam
-- Create date: 23/09/2017
-- Description:	
-- Modification:
--			20180411 DM - Adjusted the imported of the lines to include Disbursement lines.
--			20181113 DM - Adjusted how the existing Service Files link to the Timesheets (using the base records details)
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_302_Timesheet] 
AS
BEGIN

	SET NOCOUNT ON;

	-- patrxdet => ServiceEvent & ServiceEventActivity & ServiceEventAttendee

	/*
	pnpServiceEvent
		ServiceEventSK
		SiteSK
		BookItemSK
		ServiceFileSK					(from job)	
		CaseSK							(from job)
		FunderSK						(from job)
		FunderDepartmentSK				(from job)
		PrimaryWorkerUserSK				(from job)
		SecWorkerUserSK
		BillActOvrIndividualSK
		ServiceEventID					project_code + '_' + tran_date + '_' + resource_code 
		SiteID
		BookItemID
		ServiceFileID					(from job)
		CaseID							(from job)	
		FunderID						(from job)
		FunderDepartmentID				(from job)
		PrimaryWorkerID					(from job)
		PrimaryWorkerUserID				(from job)
		SecWorkerID
		SecWorkerUserID
		BillActOvrIndividualID
		Title								
		StartDatetime					tran_date
		EndDatetime						tran_date
		Out
		Category
		Notes
		CreatedDatetime					created_date
		UpdatedDatetime					last_edit_date
		CreatedBy						created_user
		UpdatedBy						
		NotesFinished
		FollowupRequired
		Lock
		FirstSessionInSeries
		NoteUpdateDatetime
		NoteUpdateUserID
		NoteUpdateUserSK
		UnregClients
		NonScheduled
		ActivityType
		ActivityTypeDescription
		Status							Show / No Show (based on ACTIVITY_CODE)
		WorkshopID
		WorkshopSessionID
		UseSeqOvr
		Confirmed
		AcceptCancellationPolicy
		ResolvedDate
		ReviewRequired
		ForReview
		SiteRegion
		SiteRegionGLCode
	*/
	if object_id('tempdb..#src') is not null drop table #src 

	;with d as (
		select project_code, tran_date, resource_code 
		from [db-au-stage]..dtc_cli_patrxdet 
		where tran_type = 1 and activity_code = 'DNATTE' 
		group by project_code, tran_date, resource_code 
		having sum(qty) > 0 
	)
	select 
		project_code,
		tran_date,
		resource_code,
		'Show' Status 
	into #src 
	from 
		[db-au-stage]..dtc_cli_patrxdet o 
	where 
		tran_type IN (1 ,10)
		and not exists (select 1 from d where project_code = o.project_code and tran_date = o.tran_date and resource_code = o.resource_code)
	group by 
		project_code, tran_date, resource_code 
	union all 
	select 
		project_code,
		tran_date,
		resource_code,
		'No Show'
	from d

	if object_id('tempdb..#MatchingServiceFiles') is not null drop table #MatchingServiceFiles
	 
	--Matching existing Jobs
	-- Added Mod: 20181113 - not relying solely on the pnpServiceFile "ClienteleJobNum"
	-- Added Mod: 20181115 - Added code to match against data from Clientele for Funder & department.
	select ServiceFileSK, 
			CaseSK, 
			COALESCE(f.FunderSK, f1.FunderSK, sf.FunderSK) FunderSK, 
			COALESCE(fd.FunderDepartmentSK, fd1.FunderDepartmentSK, sf.FunderDepartmentSK) FunderDepartmentSK, 
			ServiceFileID, 
			CaseID, 
			COALESCE(f.FunderID, f1.FunderID, sf.FunderID) FunderID, 
			COALESCE(fd.FunderDepartmentID, fd1.FunderDepartmentID, sf.FunderDepartmentID) FunderDepartmentID, 
			isNull(bj.Job_num, sf.ClienteleJobNumber) as Job_num,
			sf.CreatedDatetime
	into #MatchingServiceFiles
	from [db-au-dtc].dbo.pnpServiceFile sf
	left join [db-au-stage].dbo.dtc_cli_ServiceFile_Lookup sfl on CAST(sfl.kprogprovid as varchar) = sf.ServiceFileID -- Added Mod: 20181113 - not relying on the pnpServiceFile "ClienteleJobNum"
	left join [db-au-stage].dbo.dtc_cli_Base_Job bj on sfl.uniquecaseid = bj.Pene_ID-- Added Mod: 20181113 - not relying on the pnpServiceFile "ClienteleJobNum"
	left join [db-au-stage].dbo.dtc_cli_Job J on bj.Job_id = J.Job_ID
	left join [db-au-stage].dbo.dtc_cli_Base_Org bo on J.Org_ID = bo.Org_id
	left join [db-au-stage].dbo.dtc_cli_Person p on J.Per_id = P.Per_id
	left join [db-au-stage].dbo.dtc_cli_Base_Group gp on Nullif(isNull(NUllif(nullif(P.SubLevel_ID,'0z0'),'0'), p.Group_id),'0') = gp.Group_id
	left join [db-au-stage].dbo.dtc_cli_Org_Lookup ol on bo.Pene_id = ol.uniquefunderid
	left join [db-au-stage].dbo.dtc_cli_Group_Lookup gl on gp.Pene_id = gl.uniquedepartmentid
	left join [db-au-dtc].dbo.pnpFunder F on CAST(ol.kfunderid as varchar) = f.FunderID AND f.IsCurrent = 1
	left join [db-au-dtc].dbo.pnpFunderDepartment fd on cast(gl.kfunderdeptid as varchar) = fd.FunderDepartmentID
	left join [db-au-dtc].dbo.pnpFunder F1 on 'CLI_ORG_' + J.Org_ID = F1.FunderID and F1.IsCurrent = 1
	left join [db-au-dtc].dbo.pnpFunderDepartment fd1 on 'CLI_GRP_' + Nullif(isNull(NUllif(nullif(P.SubLevel_ID,'0z0'),'0'), p.Group_id),'0') = fd1.FunderDepartmentID

	-- 1. transform 
	if object_id('tempdb..#serviceevent') is not null drop table #serviceevent 

	select 
		sf.ServiceFileSK,
		sf.CaseSK,
		sf.FunderSK,
		sf.FunderDepartmentSK,
		pwu.PrimaryWorkerUserSK,
		'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code ServiceEventID,
		sf.ServiceFileID,
		sf.CaseID,
		sf.FunderID,
		sf.FunderDepartmentID,
		pwu.PrimaryWorkerID,
		pwu.PrimaryWorkerUserID,
		s.tran_date StartDatetime,
		s.tran_date EndDatetime,
		s.Status,
		sd.SiteID,
		sd.SiteSK
	into #serviceevent
	from 
		#src s 
		outer apply (
			select top 1 ServiceFileSK, CaseSK, FunderSK, FunderDepartmentSK, 
				ServiceFileID, CaseID, FunderID, FunderDepartmentID, sf.Job_num
			from #MatchingServiceFiles sf
			where sf.Job_num = s.project_code-- Added Mod: 20181113 - not relying on the pnpServiceFile "ClienteleJobNum"
			order by CreatedDatetime asc
		) sf 
		outer apply (
			select top 1 UserSK PrimaryWorkerUserSK, UserID PrimaryWorkerUserID, WorkerID PrimaryWorkerID 
			from [db-au-dtc]..pnpUser 
			where ClienteleResourceCode = s.resource_code
		) pwu
		outer apply (
			select top 1 SX.SiteSK, SX.SiteID
			from dtc_cli_DiaryLookup D
			JOIN dtc_cli_DTOffice O ON D.Office = O.OfficeName
			LEFT JOIN [db-au-dtc].dbo.usr_OfficeMapping M ON O.DToffice_id = M.DTOffice_id 
			LEFT JOIN dtc_cli_Temp_Offices T ON O.DToffice_id = T.DToffice_id
			LEFT JOIN dtc_cli_Site_Lookup L ON T.Pene_id = L.uniquesiteid
			JOIN [db-au-dtc].dbo.pnpSite SX ON IsNull(CAST(IsNull(M.ksiteid, L.ksiteid) as varchar), 'CLI_OFF_' + O.DTOffice_ID) = SX.SiteID
			WHERE s.project_code = D.Job_Num AND
				  CAST(S.tran_date as date) = CAST(D.StartDate as date) AND
				  S.resource_code = D.Consultant
			ORDER BY D.StartTime) sd

	-- 2. load 
	merge [db-au-dtc]..pnpServiceEvent as tgt
	using #serviceevent 
		on #serviceevent.ServiceEventID = tgt.ServiceEventID
	when not matched by target then 
		insert (
			ServiceFileSK,
			CaseSK,
			FunderSK,
			FunderDepartmentSK,
			PrimaryWorkerUserSK,
			ServiceEventID,
			ServiceFileID,
			CaseID,
			FunderID,
			FunderDepartmentID,
			PrimaryWorkerID,
			PrimaryWorkerUserID,
			StartDatetime,
			EndDatetime,
			Status,
			siteSK,
			siteID
		)
		values (
			#serviceevent.ServiceFileSK,
			#serviceevent.CaseSK,
			#serviceevent.FunderSK,
			#serviceevent.FunderDepartmentSK,
			#serviceevent.PrimaryWorkerUserSK,
			#serviceevent.ServiceEventID,
			#serviceevent.ServiceFileID,
			#serviceevent.CaseID,
			#serviceevent.FunderID,
			#serviceevent.FunderDepartmentID,
			#serviceevent.PrimaryWorkerID,
			#serviceevent.PrimaryWorkerUserID,
			#serviceevent.StartDatetime,
			#serviceevent.EndDatetime,
			#serviceevent.Status,
			#serviceevent.SiteSK,
			#serviceevent.SiteID
		)
	when matched then update set 
		tgt.ServiceFileSK = #serviceevent.ServiceFileSK,
		tgt.CaseSK = #serviceevent.CaseSK,
		tgt.FunderSK = #serviceevent.FunderSK,
		tgt.FunderDepartmentSK = #serviceevent.FunderDepartmentSK,
		tgt.PrimaryWorkerUserSK = #serviceevent.PrimaryWorkerUserSK,
		tgt.ServiceFileID = #serviceevent.ServiceFileID,
		tgt.CaseID = #serviceevent.CaseID,
		tgt.FunderID = #serviceevent.FunderID,
		tgt.FunderDepartmentID = #serviceevent.FunderDepartmentID,
		tgt.PrimaryWorkerID = #serviceevent.PrimaryWorkerID,
		tgt.PrimaryWorkerUserID = #serviceevent.PrimaryWorkerUserID,
		tgt.StartDatetime = #serviceevent.StartDatetime,
		tgt.EndDatetime = #serviceevent.EndDatetime,
		tgt.Status = #serviceevent.Status,
		tgt.SiteSK = #serviceevent.SiteSK,
		tgt.SiteID = #serviceevent.SiteID
	;

	
	/*
	pnpServiceEventActivity
		ServiceEventActivitySK
		ServiceEventSK						from ServiceEvent
		ServiceFileSK						from ServiceEvent	
		CaseSK								from ServiceEvent
		ItemSK								from Item (Activity_Code)
		FunderSK							from ServiceEvent
		FunderDepartmentSK					from ServiceEvent
		ServiceEventActivityID				'CLI_TSH_' + trx_ctrl_num
		ServiceEventID						project_code + '_' + tran_date + '_' + resource_code 
		ServiceFileID						from ServiceEvent	
		CaseID								from ServiceEvent		
		ItemID								'CLI_ACD_' + ACTIVITY_CODE
		FunderID							from ServiceEvent
		FunderDepartmentID					from ServiceEvent
		Name								from Item (Activity_Code)
		Quantity							qty
		UnitOfMeasurementClass				'Time - Hour'
		UnitOfMeasurementIsTime				'1'
		UnitOfMeasurementIsSchedule			'hours'
		UnitOfMeasurementIsName				'60m'
		UnitOfMeasurementIsEquivalent		1
		Fee									project_sell_fee_amt
		Total								project_sell_amt
		CreatedDatetime						created_date
		UpdatedDatetime						last_edit_date
		CreatedBy							created_user	
		UpdatedBy							last_edit_user
		UseSeqOvr
		WorkshopRegItemID
		WorkshopSessionLineID
		ServiceEventActivityIDRet
		DeletedDatetime
		Invoiced							patrx table
	*/

	-- 1. transform 
	if object_id('tempdb..#serviceeventactivity') is not null drop table #serviceeventactivity 

	select 
		se.ServiceEventSK,
		se.ServiceFileSK,
		se.CaseSK,
		i.ItemSK,
		se.FunderSK,
		se.FunderDepartmentSK,
		'CLI_TSH_' + s.trx_ctrl_num ServiceEventActivityID,
		'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code ServiceEventID,
		se.ServiceFileID,
		se.CaseID,
		'CLI_ACD_' + s.Activity_Code ItemID,
		se.FunderID,
		se.FunderDepartmentID,
		i.Name,
		s.qty Quantity,
		'Time - Hour' UnitOfMeasurementClass,
		'1' UnitOfMeasurementIsTime,
		'hours' UnitOfMeasurementIsSchedule,
		'60m' UnitOfMeasurementIsName,
		1 UnitOfMeasurementIsEquivalent,
		s.project_sell_fee_amt Fee,
		s.project_sell_amt Total,
		s.created_date CreatedDatetime,
		s.last_edit_date UpdatedDatetime,
		s.created_user CreatedBy,	
		s.last_edit_user UpdatedBy,
		case 
			when exists (select 1 from [db-au-stage]..dtc_cli_patrx where trx_ctrl_num = s.inv_ctrl_num and invoice_flag = 1) then 1 
			else 0 
		end Invoiced,
		IsNull(iv.posting_code, p.posting_code) posting_code,
		IsNull(iv.company_code, p.company_code) company_code
	into #serviceeventactivity
	from 
		[db-au-stage]..dtc_cli_patrxdet s 
		outer apply (
			select top 1 ServiceEventSK, ServiceFileSK, CaseSK, FunderSK, FunderDepartmentSK, 
				ServiceFileID, CaseID, FunderID, FunderDepartmentID 
			from [db-au-dtc]..pnpServiceEvent 
			where ServiceEventID = 'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code
		) se 
		outer apply (
			select top 1 ItemSK, Name  
			from [db-au-dtc]..pnpItem 
			where ItemID = 'CLI_ACD_' + s.Activity_Code
		) i
		join [db-au-stage]..dtc_cli_paprojct p on s.project_code = P.project_code
		left join [db-au-stage]..dtc_cli_patrx Iv ON s.inv_ctrl_num = Iv.trx_ctrl_num
	where 
		s.tran_type IN (1,10)

	-- 2. load	
	merge [db-au-dtc]..pnpServiceEventActivity as tgt
	using #serviceeventactivity 
		on #serviceeventactivity.ServiceEventActivityID = tgt.ServiceEventActivityID
	when not matched by target then 
		insert (
			ServiceEventSK,
			ServiceFileSK,
			CaseSK,
			ItemSK,
			FunderSK,
			FunderDepartmentSK,
			ServiceEventActivityID,
			ServiceEventID,
			ServiceFileID,
			CaseID,
			ItemID,
			FunderID,
			FunderDepartmentID,
			Name,
			Quantity,
			UnitOfMeasurementClass,
			UnitOfMeasurementIsTime,
			UnitOfMeasurementIsSchedule,
			UnitOfMeasurementIsName,
			UnitOfMeasurementIsEquivalent,
			Fee,
			Total,
			CreatedDatetime,
			UpdatedDatetime,
			CreatedBy,	
			UpdatedBy,
			Invoiced,
			postingCode,
			companyCode
		)
		values (
			#serviceeventactivity.ServiceEventSK,
			#serviceeventactivity.ServiceFileSK,
			#serviceeventactivity.CaseSK,
			#serviceeventactivity.ItemSK,
			#serviceeventactivity.FunderSK,
			#serviceeventactivity.FunderDepartmentSK,
			#serviceeventactivity.ServiceEventActivityID,
			#serviceeventactivity.ServiceEventID,
			#serviceeventactivity.ServiceFileID,
			#serviceeventactivity.CaseID,
			#serviceeventactivity.ItemID,
			#serviceeventactivity.FunderID,
			#serviceeventactivity.FunderDepartmentID,
			#serviceeventactivity.Name,
			#serviceeventactivity.Quantity,
			#serviceeventactivity.UnitOfMeasurementClass,
			#serviceeventactivity.UnitOfMeasurementIsTime,
			#serviceeventactivity.UnitOfMeasurementIsSchedule,
			#serviceeventactivity.UnitOfMeasurementIsName,
			#serviceeventactivity.UnitOfMeasurementIsEquivalent,
			#serviceeventactivity.Fee,
			#serviceeventactivity.Total,
			#serviceeventactivity.CreatedDatetime,
			#serviceeventactivity.UpdatedDatetime,
			#serviceeventactivity.CreatedBy,	
			#serviceeventactivity.UpdatedBy,
			#serviceeventactivity.Invoiced,
			#serviceeventactivity.posting_code,
			#serviceeventactivity.company_code
		)
	when matched then update set 
		tgt.ServiceEventSK = #serviceeventactivity.ServiceEventSK,
		tgt.ServiceFileSK = #serviceeventactivity.ServiceFileSK,
		tgt.CaseSK = #serviceeventactivity.CaseSK,
		tgt.ItemSK = #serviceeventactivity.ItemSK,
		tgt.FunderSK = #serviceeventactivity.FunderSK,
		tgt.FunderDepartmentSK = #serviceeventactivity.FunderDepartmentSK,
		tgt.ServiceEventID = #serviceeventactivity.ServiceEventID,
		tgt.ServiceFileID = #serviceeventactivity.ServiceFileID,
		tgt.CaseID = #serviceeventactivity.CaseID,
		tgt.ItemID = #serviceeventactivity.ItemID,
		tgt.FunderID = #serviceeventactivity.FunderID,
		tgt.FunderDepartmentID = #serviceeventactivity.FunderDepartmentID,
		tgt.Name = #serviceeventactivity.Name,
		tgt.Quantity = #serviceeventactivity.Quantity,
		tgt.UnitOfMeasurementClass = #serviceeventactivity.UnitOfMeasurementClass,
		tgt.UnitOfMeasurementIsTime = #serviceeventactivity.UnitOfMeasurementIsTime,
		tgt.UnitOfMeasurementIsSchedule = #serviceeventactivity.UnitOfMeasurementIsSchedule,
		tgt.UnitOfMeasurementIsName = #serviceeventactivity.UnitOfMeasurementIsName,
		tgt.UnitOfMeasurementIsEquivalent = #serviceeventactivity.UnitOfMeasurementIsEquivalent,
		tgt.Fee = #serviceeventactivity.Fee,
		tgt.Total = #serviceeventactivity.Total,
		tgt.CreatedDatetime = #serviceeventactivity.CreatedDatetime,
		tgt.UpdatedDatetime = #serviceeventactivity.UpdatedDatetime,
		tgt.CreatedBy = #serviceeventactivity.CreatedBy,
		tgt.UpdatedBy = #serviceeventactivity.UpdatedBy,
		tgt.Invoiced = #serviceeventactivity.Invoiced,
		tgt.postingCode = #serviceeventactivity.posting_code,
		tgt.companyCode = #serviceeventactivity.company_code
	;


	/*
	pnpServiceEventAttendee
		BookItemSK
		ServiceEventSK		from #serviceevent
		IndividualSK		from #serviceevent
		UserSK				from #serviceevent
		BookItemID
		ServiceEventID		from #serviceevent
		IndividualID		from #serviceevent
		UserID				from #serviceevent
		WorkerID			from #serviceevent
		Name				from #serviceevent
		Role				'Primary Worker' / 'Presenting Individual'
		amemshow			
		CreatedDatetime
		UpdatedDatetime
		amemcode			
		kexempttypeid
		DeletedDatetime		
	*/

	-- 1. transform 
	if object_id('tempdb..#serviceeventattendee') is not null drop table #serviceeventattendee  

	select 
		se.ServiceEventSK,
		null IndividualSK,
		u.UserSK,
		s.ServiceEventID,
		null IndividualID,
		s.PrimaryWorkerUserID UserID,
		s.PrimaryWorkerUserID WorkerID,
		u.FirstName + ' ' + u.LastName Name,
		'Primary Worker' Role
	into #serviceeventattendee 
	from 
		#serviceevent s 
		outer apply (
			select top 1 ServiceEventSK 
			from [db-au-dtc]..pnpServiceEvent 
			where ServiceEventID = s.ServiceEventID
		) se 
		outer apply (
			select top 1 UserSK, FirstName, LastName  
			from [db-au-dtc]..pnpUser  
			where UserID = s.PrimaryWorkerUserID
		) u 
	where 
		s.Status = 'Show'
	union all 
	select 
		se.ServiceEventSK,
		sfm.IndividualSK,
		null UserSK,
		'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code ServiceEventID,
		i.IndividualID,
		null UserID,
		null WorkerID,
		i.FirstName + ' ' + i.LastName Name,
		'Presenting Individual' Role 
	from 
		#src s 
		outer apply (
			select top 1 ServiceEventSK 
			from [db-au-dtc]..pnpServiceEvent 
			where ServiceEventID = 'CLI_' + s.project_code + '_' + convert(varchar(10), s.tran_date, 112) + '_' + s.resource_code
		) se 
		outer apply (
			select top 1 ServiceFileSK 
			from [db-au-dtc]..pnpServiceFile 
			where ClienteleJobNumber = s.project_code
		) sf 
		outer apply (
			select top 1 IndividualSK 
			from [db-au-dtc]..pnpServiceFileMember
			where ServiceFileSK = sf.ServiceFileSK
		) sfm 
		outer apply (
			select top 1 IndividualID, FirstName, LastName 
			from [db-au-dtc]..pnpIndividual 
			where IndividualSK = sfm.IndividualSK 
		) i 
	where 
		s.Status = 'Show'	

	-- 2. load 
	merge [db-au-dtc]..pnpServiceEventAttendee  as tgt
	using #serviceeventattendee 
		on #serviceeventattendee.ServiceEventID = tgt.ServiceEventID and isNull(#serviceeventattendee.IndividualID,'') = isNull(tgt.IndividualID,'') and isNull(#serviceeventattendee.UserID,'') = isnull(tgt.UserID,'')
	when not matched by target then 
		insert (
			ServiceEventSK,
			IndividualSK,
			UserSK,
			ServiceEventID,
			IndividualID,
			UserID,
			WorkerID,
			Name,
			Role 
		)
		values (
			#serviceeventattendee.ServiceEventSK,
			#serviceeventattendee.IndividualSK,
			#serviceeventattendee.UserSK,
			#serviceeventattendee.ServiceEventID,
			#serviceeventattendee.IndividualID,
			#serviceeventattendee.UserID,
			#serviceeventattendee.WorkerID,
			#serviceeventattendee.Name,
			#serviceeventattendee.Role 
		)
	when matched then update set 
		tgt.ServiceEventSK = #serviceeventattendee.ServiceEventSK,
		tgt.IndividualSK = #serviceeventattendee.IndividualSK,
		tgt.UserSK = #serviceeventattendee.UserSK,
		tgt.WorkerID = #serviceeventattendee.WorkerID,
		tgt.Name = #serviceeventattendee.Name,
		tgt.Role = #serviceeventattendee.Role 
	;


	-- update [db-au-dtc]..pnpServiceFile, use the first event worker as service file primary worker 
	update sf 
	set 
		PrimaryWorkerUserSK = u.PrimaryWorkerUserSK,
		PrimaryWorkerID = u.PrimaryWorkerID 
	from 
		[db-au-dtc]..pnpServiceFile sf 
		cross apply (
			select top 1 resource_code 
			from dtc_cli_patrxdet 
			where project_code = sf.ClienteleJobNumber 
			order by tran_date 
		) pw 
		cross apply (
			select top 1 UserSK PrimaryWorkerUserSK, WorkerID PrimaryWorkerID 
			from [db-au-dtc]..pnpUser 
			where ClienteleResourceCode = pw.resource_code and IsCurrent = 1
		) u 
	where 
		sf.PrimaryWorkerUserSK is null 

	-- update sites for specific Clientele jobs
	create table #jobs (
		ClienteleJobNumber varchar(50), 
		SiteID varchar(50)
	)

	insert into #jobs (ClienteleJobNumber, SiteID) values ('N663401','14')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664697','DUMMY_FOR_JOB_N664697')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664702','DUMMY_FOR_JOB_N664702')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('V664699','DUMMY_FOR_JOB_V664699')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664700','DUMMY_FOR_JOB_N664700')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664704','DUMMY_FOR_JOB_N664704')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664703','DUMMY_FOR_JOB_N664703')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664705','DUMMY_FOR_JOB_N664705')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664695','DUMMY_FOR_JOB_N664695')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q664701','DUMMY_FOR_JOB_Q664701')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q665175','DUMMY_FOR_JOB_Q665175')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664693','DUMMY_FOR_JOB_N664693')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q664696','DUMMY_FOR_JOB_Q664696')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A664708','DUMMY_FOR_JOB_A664708')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664707','DUMMY_FOR_JOB_N664707')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664706','DUMMY_FOR_JOB_N664706')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q664692','DUMMY_FOR_JOB_Q664692')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q592673','20')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q603956','23')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q603959','19')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q603963','133')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q606333','25')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q607497','24')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q607503','27')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q607505','21')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q607502','26')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392409','7')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392411','1202')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392412','DUMMY_FOR_JOB_A392412')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392413','DUMMY_FOR_JOB_A392413')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392414','10')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392415','65')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A671987','DUMMY_FOR_JOB_A671987')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q680582','28')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q716448','DUMMY_FOR_JOB_Q716448')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q721492','DUMMY_FOR_JOB_Q721492')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q738874','DUMMY_FOR_JOB_Q738874')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664110','113')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('S664097','1202')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664115','128')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('V664603','8')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('T664606','1203')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q665609','1204')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('W664100','11')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('I664101','5')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('I664109','6')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('V664112','9')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('W664096','7')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('V664111','127')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A532847','127')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A532846','113')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A577346','9')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A656223','128')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N664098','10')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('V664113','15')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392416','DUMMY_FOR_JOB_A392416')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A392418','DUMMY_FOR_JOB_A392418')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A437778','11')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A468690','6')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A468689','5')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('A492019','15')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('W650307','DUMMY_FOR_JOB_W650307')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('N686584','113')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q692525','1302')
	insert into #jobs (ClienteleJobNumber, SiteID) values ('Q594148','DUMMY_FOR_JOB_Q594148')


	update se set
		SiteSK = s.SiteSK,
		SiteID = s.SiteID
	from 
		[db-au-dtc]..pnpServiceEvent se 
		join [db-au-dtc]..pnpServiceFile sf on sf.ServiceFileSK = se.ServiceFileSK
		join #jobs j on j.ClienteleJobNumber = sf.ClienteleJobNumber 
		join [db-au-dtc]..pnpSite s on s.SiteID = j.SiteID 

END
GO
