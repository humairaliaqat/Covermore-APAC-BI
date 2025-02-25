USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL048_BusinessObjectsAuditEvent]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL048_BusinessObjectsAuditEvent] @DateRange varchar(30),
															@StartDate varchar(10),
															@EndDate varchar(10)
as

begin
SET NOCOUNT ON


	--uncomment to debug
/*
	declare @DateRange varchar(30)
	declare @StartDate varchar(10)
	declare @EndDate varchar(10)
	select 
		@DateRange = '_User Defined', 
		@StartDate = '2016-01-01', 
		@EndDate = '2016-01-01'
*/

	declare
		@batchid int,
		@start date,
		@end date,
		@name varchar(50),
		@rptStartDate date,
		@rptEndDate date


	exec [db-au-stage].dbo.syssp_getrunningbatch
	    @SubjectArea = 'BusinessObjects Audit Events',
	    @BatchID = @batchid out,
	    @StartDate = @start out,
	    @EndDate = @end out

	select
	    @name = object_name(@@procid)

	exec [db-au-stage].dbo.syssp_genericerrorhandler
	    @LogToTable = 1,
	    @ErrorCode = '0',
	    @BatchID = @batchid,
	    @PackageID = @name,
	    @LogStatus = 'Running'


	if @DateRange = '_User Defined'
		select 
			@rptStartDate = @StartDate, 
			@rptEndDate = @EndDate
	else
		select 
			@rptStartDate = StartDate,
			@rptEndDate = EndDate
		from 
			[db-au-cmdwh].dbo.vDateRange
		where 
			DateRange = @DateRange


	if object_id('tempdb..#BobjAuditEvent') is not null drop table #BobjAuditEvent
	select 
		cl.Cluster,	
		[db-au-stage].dbo.xfn_ConvertUTCToLocal(cl.LastPollTime,'AUS EASTERN STANDARD TIME') as LastPollTime,
		srv.ServerName,
		srvtype.ServerType,
		sts.ServiceType,
		ap.ApplicationType,
		au.[Version],
		au.[State],
		case when au.Potentially_Incomplete_Data = 1 then 'Yes' else 'No' end as PotentiallyIncompleteData,
		[db-au-stage].dbo.xfn_ConvertUTCToLocal(Retrieved_Events_Completed_By,'AUS EASTERN STANDARD TIME') as RetrievedEventsCompletedBy,
		e.Event_ID as EventID,
		[db-au-stage].dbo.xfn_ConvertUTCToLocal(e.Start_Time,'AUS EASTERN STANDARD TIME') as StartTime,
		e.Duration_ms as DurationMS,
		convert(float,e.Duration_ms) / 1000 as DurationSec,
		e.[User_Name] as UserName,
		e.Object_ID as ObjectID,
		e.Object_Name as ObjectName,
		e.Object_Folder_Path as ObjectFolderPath,
		e.Top_Folder_Name as TopFolderName,
		e.Top_Folder_ID as TopFolderID,
		e.Folder_ID as FolderID,
		c.ClientType,
		ec.EventCategoryType,
		et.EventType,
		es.[Status],
		o.ObjectType,
		e.Start_Time as StartTimeUTC,
		ed.EventDetailID,
		ed.EventDetail,
		ed.EventDetailType,
		ed.EventDetailBunch,
		case when e.Object_ID > '' and e.Object_ID <> 'unknown' then 1 else 0 end as isObject,
		case when e.User_ID not in ('unknown','0') then 1 else 0 end as hasUser,
		case when e.Object_Folder_Path not like '%/ZZ_%' and
				  e.Object_Folder_Path not like '%/User Folders%' and
				  e.Object_Folder_Path not like '%/_Shared Folders%' and
				  e.Object_Folder_Path not like '%/_Documents%' then 1
			else 0
		end as isReportable,
		case when e.Object_Folder_Path like '% AU/%' then 'AU'
			 when e.Object_Folder_Path like '% NZ/%' then 'NZ'
			 when e.Object_Folder_Path like '% MY/%' then 'MY'
			 when e.Object_Folder_Path like '% ID/%' then 'ID'
			 when e.Object_Folder_Path like '% CN/%' then 'CN'
			 when e.Object_Folder_Path like '% UK/%' then 'UK'
			 when e.Object_Folder_Path like '%/Global Services/%' then 'AU'
			 when e.Object_Folder_Path like '%/Travel Insurance Partners/%' then 'AU'
			 when e.Object_Folder_Path like '%/Global SIM/%' then 'AU'
			 when e.Object_Folder_Path like '%/Assistance/%' then 'AU'
			 else 'Unknown'
		end as Country,
		case when e.Object_Folder_Path like '%/Assistance/%' then 'Assistance'
			 when e.Object_Folder_Path like '%/Travel Insurance Partners/%' then 'Travel Insurance Partners'
			 when e.Object_Folder_Path like '%/Insurance/%' then 'Insurance'
			 when e.Object_Folder_Path like '%/Global Services/%' then 'Global Services'
			 else 'Unknown'
		end as BusinessLine,
		case when e.Object_Folder_Path like '%/Assistance/%' then 'Assistance'
			when e.Object_Folder_Path like '%/Travel Insurance Partners/%' then 'Sales AU'
			when e.Object_Folder_Path like '%/Claims AU/%' then 'Claims AU'
			when e.Object_Folder_Path like '%/Claims NZ/%' then 'Claims NZ'
			when e.Object_Folder_Path like '%/Claims MY/%' then 'Claims MY'
			when e.Object_Folder_Path like '%/Claims IN/%' then 'Claims IN'
			when e.Object_Folder_Path like '%/Claims UK/%' then 'Claims UK'
			when e.Object_Folder_Path like '%/CRM AU/%' then 'CRM AU'
			when e.Object_Folder_Path like '%/CRM NZ/%' then 'CRM NZ'
			when e.Object_Folder_Path like '%/CRM UK/%' then 'CRM UK'
			when e.Object_Folder_Path like '%/Customer Service AU/%' then 'Customer Service AU'
			when e.Object_Folder_Path like '%/eCommerce AU/%' then 'eCommerce AU'
			when e.Object_Folder_Path like '%/EMC AU/%' then 'EMC AU'
			when e.Object_Folder_Path like '%/Sales AU/%' then 'Sales AU'
			when e.Object_Folder_Path like '%/Sales NZ/%' then 'Sales NZ'
			when e.Object_Folder_Path like '%/Sales MY/%' then 'Sales MY'
			when e.Object_Folder_Path like '%/Sales CN/%' then 'Sales CN'
			when e.Object_Folder_Path like '%/Sales UK/%' then 'Sales UK'
			when e.Object_Folder_Path like '%/Sales UK/%' then 'Sales UK'
			when e.Object_Folder_Path like '%/Sales UK/%' then 'Sales UK'
			when e.Object_Folder_Path like '%/Compliance/%' then 'Risk & Compliance'
			when e.Object_Folder_Path like '%/Finance/%' then 'Finance'
			when e.Object_Folder_Path like '%/IT/%' then 'IT'
			when e.Object_Folder_Path like '%/Marketing/%' then 'Marketing'
			when e.Object_Folder_Path like '%/Pricing/%' then 'Pricing'
			when e.Object_Folder_Path like '%/Global SIM/%' then 'Global SIM'
			else 'Unknown'
		end	as Department
	into #BobjAuditEvent	
	from
		[db-au-bobjaudit].dbo.ADS_EVENT e
		inner join [db-au-bobjaudit].dbo.ADS_AUDITEE au on
			e.Cluster_ID = au.Cluster_ID and
			e.Server_ID = au.Server_ID and
			e.Service_Type_ID = au.Service_Type_ID
		outer apply				-- cluster
		(
			select top 1
				cs.Cluster_Name as Cluster,
				c.Last_Poll_Time as LastPollTime
			from
				[db-au-bobjaudit].dbo.ADS_Cluster c
				join [db-au-bobjaudit].dbo.ADS_Cluster_Str cs on
					c.Cluster_ID = cs.Cluster_ID
			where
				c.Cluster_ID = e.Cluster_ID and

				cs.[Language] = 'EN'
		) cl
		outer apply				-- server
		(
			select top 1
				sns.Server_Name as ServerName
			from
				[db-au-bobjaudit].dbo.ADS_Server_Name_Str sns
			where
				sns.Cluster_ID = e.Cluster_ID and
				sns.Server_ID = e.Server_ID and
				sns.[Language] = 'EN'
		) srv
		outer apply
		(
			select top 1
				sts.Server_Type_Name as ServerType
			from
				[db-au-bobjaudit].dbo.ADS_SERVER_TYPE_STR sts
			where
				sts.Server_Type_ID = au.Server_Type_ID and
				sts.[Language] = 'EN'
		) srvtype
		outer apply
		(
			select top 1
				ats.Application_Type_Name as ApplicationType
			from
				[db-au-bobjaudit].dbo.ADS_APPLICATION_TYPE_STR ats
			where
				ats.Application_Type_ID = au.Application_Type_ID and
				ats.[Language] = 'EN'
		) ap
		outer apply
		(
			select top 1
				Service_Type_Name as ServiceType
			from
				[db-au-bobjaudit].dbo.ADS_Service_Type_Str
			where
				Service_Type_ID = e.Service_Type_ID
		) sts
		outer apply				--event details
		(
			select top 1
				convert(nvarchar(256),d.Event_Detail_Value) as EventDetail,
				edt.Event_Detail_Type_Name as EventDetailType,
				d.Event_Detail_ID as EventDetailID,
				d.Bunch as EventDetailBunch
			from
				[db-au-bobjaudit].dbo.ADS_EVENT_DETAIL d
				inner join [db-au-bobjaudit].dbo.ADS_EVENT_DETAIL_TYPE_STR edt on
					d.Event_Detail_Type_ID = edt.Event_Detail_Type_ID
			where
				d.Event_ID = e.Event_ID and
				edt.[Language] = 'EN'
		) ed
		outer apply				--event status
		(
			select top 1 
				Status_Name as [Status]
			from
				[db-au-bobjaudit].dbo.ADS_STATUS_STR
			where
				Status_ID = e.Status_ID and
				[Language] = 'EN' and
				Event_Type_ID = e.Event_Type_ID			
		) es
		outer apply				--application client type
		(
			select top 1 
				Application_Type_Name as ClientType
			from 
				[db-au-bobjaudit].dbo.ADS_APPLICATION_TYPE_STR
			where
				Application_Type_ID = e.Client_Type_ID and
				[Language] = 'EN'
		) c
		outer apply				--object type
		(
			select top 1 
				Object_Type_Name as ObjectType
			from 
				[db-au-bobjaudit].dbo.ADS_OBJECT_TYPE_STR
			where
				Object_Type_ID = e.Object_Type_ID and
				[Language] = 'EN'
		) o
		outer apply				--category type
		(
			select top 1
				ec.Event_Category_Name as EventCategoryType
			from
				[db-au-bobjaudit].dbo.ADS_EVENT_TYPE et
				join [db-au-bobjaudit].dbo.ADS_EVENT_CATEGORY_STR ec on
					et.Event_Category_ID = ec.Event_Category_ID and
					ec.[Language] = 'EN'
			where
				et.Event_Type_ID = e.Event_Type_ID
		) ec
		outer apply				--event type
		(
			select top 1
				Event_Type_Name as EventType
			from
				[db-au-bobjaudit].dbo.ADS_EVENT_TYPE_STR
			where
				Event_Type_ID = e.Event_Type_ID and
				[Language] = 'EN'
		) et	
	where
		e.Start_Time >= [db-au-stage].dbo.xfn_ConvertLocalToUTC(@rptStartDate,'AUS EASTERN STANDARD TIME') and
		e.Start_Time < [db-au-stage].dbo.xfn_ConvertLocalToUTC(dateadd(d,1,@rptEndDate),'AUS EASTERN STANDARD TIME') 

		
	if object_id('[db-au-cmdwh].dbo.usrBobjAuditEvent') is null
	begin
		create table [db-au-cmdwh].dbo.usrBobjAuditEvent
		(
			BIRowID bigint not null identity(1,1),
			[Cluster] [nvarchar](255) NULL,
			[LastPollTime] [datetime] NULL,
			[ServerName] [varchar](255) NULL,
			[ServerType] [nvarchar](255) NULL,
			[ServiceType] [nvarchar](255) NULL,
			[ApplicationType] [nvarchar](255) NULL,
			[Version] [varchar](64) NULL,
			[State] [int] NULL,
			[PotentiallyIncompleteData] [varchar](3) NOT NULL,
			[RetrievedEventsCompletedBy] [datetime] NULL,
			[EventID] [varchar](64) NULL,
			[StartTime] [datetime] NULL,
			[DurationMS] [int] NULL,
			[DurationSec] [float] NULL,
			[UserName] [nvarchar](255) NULL,
			[ObjectID] [varchar](64) NULL,
			[ObjectName] [nvarchar](255) NULL,
			[ObjectFolderPath] [nvarchar](255) NULL,
			[TopFolderName] [nvarchar](255) NULL,
			[TopFolderID] [varchar](64) NULL,
			[FolderID] [varchar](64) NULL,
			[ClientType] [nvarchar](255) NULL,
			[EventCategoryType] [nvarchar](255) NULL,
			[EventType] [nvarchar](255) NULL,
			[Status] [nvarchar](255) NULL,
			[ObjectType] [nvarchar](255) NULL,
			[StartTimeUTC] [datetime] NULL,
			[EventDetailID] [int] NULL,
			[EventDetail] [nvarchar](256) NULL,
			[EventDetailType] [nvarchar](255) NULL,
			[EventDetailBunch] [int] NULL,
			[StartDate] [datetime] null,
			[isObject] [int] null,
			[hasUser] [int] null,
			[isReportable] [int] null,
			[Country] [nvarchar](20) null,
			[BusinessLine] [nvarchar](50) null,
			[Department] [nvarchar](200) null
		) 
		create clustered index idx_usrBobjAuditEvent_BIRowID on [db-au-cmdwh].dbo.usrBobjAuditEvent(BIRowID)
		create nonclustered index idx_usrBobjAuditEvent_StartTime on [db-au-cmdwh].dbo.usrBobjAuditEvent(StartTime)
		create nonclustered index idx_usrBobjAuditEvent_StartDate on [db-au-cmdwh].dbo.usrBobjAuditEvent(StartDate)
		create nonclustered index idx_usrBobjAuditEvent_UserName on [db-au-cmdwh].dbo.usrBobjAuditEvent(UserName)
		create nonclustered index idx_usrBobjAuditEvent_ObjectName on [db-au-cmdwh].dbo.usrBobjAuditEvent(ObjectName)
		create nonclustered index idx_usrBobjAuditEvent_ClientType on [db-au-cmdwh].dbo.usrBobjAuditEvent(ClientType)
		create nonclustered index idx_usrBobjAuditEvent_EventCategoryType on [db-au-cmdwh].dbo.usrBobjAuditEvent(EventCategoryType)
		create nonclustered index idx_usrBobjAuditEvent_EventType on [db-au-cmdwh].dbo.usrBobjAuditEvent(EventType)
		create nonclustered index idx_usrBobjAuditEvent_ObjectType on [db-au-cmdwh].dbo.usrBobjAuditEvent(ObjectType)
	end
	else
	begin
		delete a
		from		
			[db-au-cmdwh].dbo.usrBobjAuditEvent a
			inner join #BobjAuditEvent b on
				a.EventID = b.EventID and
				a.StartTime >= @rptStartDate and
				a.StartTime < dateadd(d,1,@rptEndDate)
	end


   begin transaction

    begin try
    
        insert into [db-au-cmdwh].dbo.usrBobjAuditEvent
        (
			[Cluster],
			[LastPollTime],
			[ServerName],
			[ServerType],
			[ServiceType],
			[ApplicationType],
			[Version],
			[State],
			[PotentiallyIncompleteData],
			[RetrievedEventsCompletedBy],
			[EventID],
			[StartTime],
			[DurationMS],
			[DurationSec],
			[UserName],
			[ObjectID],
			[ObjectName],
			[ObjectFolderPath],
			[TopFolderName],
			[TopFolderID],
			[FolderID],
			[ClientType],
			[EventCategoryType],
			[EventType],
			[Status],
			[ObjectType],
			[StartTimeUTC],
			[EventDetailID],
			[EventDetail],
			[EventDetailType],
			[EventDetailBunch],
			[StartDate],
			[isObject],
			[hasUser],
			[isReportable],
			[Country],
			[BusinessLine],
			[Department]
        )
        select 
			[Cluster],
			[LastPollTime],
			[ServerName],
			[ServerType],
			[ServiceType],
			[ApplicationType],
			[Version],
			[State],
			[PotentiallyIncompleteData],
			[RetrievedEventsCompletedBy],
			[EventID],
			[StartTime],
			[DurationMS],
			[DurationSec],
			[UserName],
			[ObjectID],
			[ObjectName],
			[ObjectFolderPath],
			[TopFolderName],
			[TopFolderID],
			[FolderID],
			[ClientType],
			[EventCategoryType],
			[EventType],
			[Status],
			[ObjectType],
			[StartTimeUTC],
			[EventDetailID],
			[EventDetail],
			[EventDetailType],
			[EventDetailBunch],
			convert(datetime,convert(varchar(10),StartTime,120)),
			[isObject],
			[hasUser],
			[isReportable],
			[Country],
			[BusinessLine],
			[Department]
        from
            #BobjAuditEvent
	end try
    
    begin catch
    
        if @@trancount > 0
            rollback transaction
            
        exec syssp_genericerrorhandler 
            @SourceInfo = 'BusinessObjects Audit Events refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
