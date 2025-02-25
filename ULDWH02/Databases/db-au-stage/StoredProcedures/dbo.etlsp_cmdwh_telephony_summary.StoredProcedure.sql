USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_telephony_summary]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_telephony_summary]
    @StartDate date,
    @EndDate date
    
as
begin

    set nocount on
    
    
    if object_id('[db-au-cmdwh].dbo.telActivity') is null
    begin
    
        create table [db-au-cmdwh].dbo.telActivity
        (
            BIRowID bigint not null identity(1,1),
            AgentName nvarchar(100),
            TeamName nvarchar(255),
            ActivityDate datetime,
            ActivityStartTime datetime,
            ActivityEndTime datetime,
            Activity nvarchar(255),
            ActualActivityTime float,
            ScheduledActivityTime float,
            ApprovedExceptionDuration float,
            UnapprovedExceptionDuration float,
            QualityScore int
        )
        
        create clustered index idx_telActivity_BIRowID on [db-au-cmdwh].dbo.telActivity (BIRowID)
        create nonclustered index idx_telActivity_Activity on [db-au-cmdwh].dbo.telActivity (ActivityDate,AgentName) include(TeamName,Activity,ActivityStartTime,ActualActivityTime,ScheduledActivityTime,ApprovedExceptionDuration,UnapprovedExceptionDuration,QualityScore)
        create nonclustered index idx_telActivity_ActivityTime on [db-au-cmdwh].dbo.telActivity (ActivityStartTime,AgentName) include(TeamName,Activity,ActivityDate,ActualActivityTime,ScheduledActivityTime,ApprovedExceptionDuration,UnapprovedExceptionDuration,QualityScore)
    
    end
    
    if object_id('[db-au-cmdwh].dbo.telCallData') is null
    begin
    
        create table [db-au-cmdwh].dbo.telCallData
        (
            BIRowID bigint not null identity(1,1),
            AgentName nvarchar(100),
            TeamName nvarchar(255),
            Company varchar(50),
            CSQName nvarchar(50),
            CallDate datetime,
            CallStartDateTime datetime,
            CallEndDateTime datetime,
            Disposition varchar(50),
            OriginatorNumber nvarchar(30),
            DestinationNumber nvarchar(30),
            CalledNumber nvarchar(30),
            OrigCalledNumber nvarchar(30),
            CallsPresented int,
            CallsHandled int,
            CallsAbandoned int,
            RingTime int,
            TalkTime int,
            HoldTime int,
            WorkTime int,
            WrapUpTime int,
            QueueTime int,
            MetServiceLevel int,
            Transfer int,
            Redirect int,
            Conference int,
            RNA int
        )
        
        create clustered index idx_telCallData_BIRowID on [db-au-cmdwh].dbo.telCallData (BIRowID)
        create nonclustered index idx_telCallData_Activity on [db-au-cmdwh].dbo.telCallData (CallDate,AgentName) include(TeamName,Company,CSQName,CallStartDateTime,CallEndDateTime,CallsPresented,CallsHandled,CallsAbandoned,RingTime,TalkTime,HoldTime,WorkTime,WrapUpTime,QueueTime,MetServiceLevel,Transfer,Redirect,Conference,RNA)
        create nonclustered index idx_telCallData_ActivityTime on [db-au-cmdwh].dbo.telCallData (CallStartDateTime,AgentName) include(TeamName,Company,CSQName,CallDate,CallEndDateTime,CallsPresented,CallsHandled,CallsAbandoned,RingTime,TalkTime,HoldTime,WorkTime,WrapUpTime,QueueTime,MetServiceLevel,Transfer,Redirect,Conference,RNA)
    
    end

    if object_id('[db-au-cmdwh].dbo.telSales') is null
    begin
		
        create table [db-au-cmdwh].dbo.telSales
        (
            BIRowID bigint not null identity(1,1),
            AgentName nvarchar(100),
            TeamName nvarchar(255),
            Company varchar(50),
            PolicyTransactionKey varchar(41) null,
            PolicyNumber varchar(50),
            PostingDate datetime,
            Premium money,
            SellPrice money,
            PolicyCount int
        )
        
        create clustered index idx_telSales_BIRowID on [db-au-cmdwh].dbo.telSales (BIRowID)
        create index idx_telSales_PolicyTransactionKey on [db-au-cmdwh].dbo.telSales (PolicyTransactionKey)
        create nonclustered index idx_telSales_Activity on [db-au-cmdwh].dbo.telSales (PostingDate,AgentName) include(TeamName,Premium,SellPrice,PolicyCount)
    
    end
    
    begin transaction
    
    delete 
    from 
        [db-au-cmdwh].dbo.telActivity
    where
        ActivityDate >= @StartDate and
        ActivityDate <  dateadd(day, 1, @EndDate)

    insert into [db-au-cmdwh].dbo.telActivity with(tablock)
    (
        AgentName,
        TeamName,
        ActivityDate,
        ActivityStartTime,
        ActivityEndTime,
        Activity,
        ActualActivityTime,
        ScheduledActivityTime,
        ApprovedExceptionDuration,
        UnapprovedExceptionDuration,
        QualityScore
    )
    select 
        AgentName,
        TeamName,
        ActivityDate,
        ActivityStartTime,
        ActivityEndTime,
        Activity,
        ActualActivityTime,
        ScheduledActivityTime,
        ApprovedExceptionDuration,
        UnapprovedExceptionDuration,
        QualityScore
    from
        [db-au-cmdwh]..vTelephonyActivities
    where
        ActivityStartTime >= @StartDate and
        ActivityStartTime <  dateadd(day, 1, @EndDate)

    insert into [db-au-cmdwh].dbo.telActivity with(tablock)
    (
        AgentName,
        TeamName,
        ActivityDate,
        ActivityStartTime,
        ActivityEndTime,
        Activity,
        ActualActivityTime,
        ScheduledActivityTime,
        ApprovedExceptionDuration,
        UnapprovedExceptionDuration,
        QualityScore
    )
    select 
        e.EmployeeName AgentName,
        isnull(o.OrganisationName, 'Unknown') TeamName,
        d.[Date] ActivityDate,
        d.[Date] ActivityStartTime,
        d.[Date] ActivityEndTime,
        'No Activity' Activity,
        0 ActualActivityTime,
        0 ScheduledActivityTime,
        0 ApprovedExceptionDuration,
        0 UnapprovedExceptionDuration,
        0 QualityScore
    from
        [db-au-cmdwh]..Calendar d
        inner join [db-au-cmdwh]..verEmployee e on
            1 = 1
        left join [db-au-cmdwh]..verTeam t on
            t.EmployeeKey = e.EmployeeKey and
            t.StartDate <= d.[Date] and 
            t.EndDate >= d.[Date]
        left join [db-au-cmdwh]..verOrganisation o on
            o.OrganisationKey = t.OrganisationKey
        left join [db-au-cmdwh]..telActivity a on
            a.ActivityDate = d.[Date] and
            a.AgentName = e.EmployeeName
    where
        e.EmployeeKey <> -1 and
        a.BIRowID is null and
        [Date] >= @StartDate and
        [Date] <  dateadd(day, 1, @EndDate)

    delete 
    from 
        [db-au-cmdwh].dbo.telCallData
    where
        CallDate >= @StartDate and
        CallDate <  dateadd(day, 1, @EndDate)

    insert into [db-au-cmdwh].dbo.telCallData
    (
        AgentName,
        TeamName,
        Company,
        CSQName,
        CallDate,
        CallStartDateTime,
        CallEndDateTime,
        Disposition,
        OriginatorNumber,
        DestinationNumber,
        CalledNumber,
        OrigCalledNumber,
        CallsPresented,
        CallsHandled,
        CallsAbandoned,
        RingTime,
        TalkTime,
        HoldTime,
        WorkTime,
        WrapUpTime,
        QueueTime,
        MetServiceLevel,
        Transfer,
        Redirect,
        Conference,
        RNA
    )
    select
        AgentName,
        Team,
        Company,
        CSQName,
        CallDate,
        CallStartDateTime,
        CallEndDateTime,
        Disposition,
        OriginatorNumber,
        DestinationNumber,
        CalledNumber,
        OrigCalledNumber,
        CallsPresented,
        CallsHandled,
        CallsAbandoned,
        RingTime,
        TalkTime,
        HoldTime,
        WorkTime,
        WrapUpTime,
        QueueTime,
        MetServiceLevel,
        Transfer,
        Redirect,
        Conference,
        RNA
    from
        [db-au-cmdwh].dbo.vTelephonyCallData
    where
        CallStartDateTime >= @StartDate and
        CallStartDateTime <  dateadd(day, 1, @EndDate)

    insert into [db-au-cmdwh].dbo.telCallData
    (
        AgentName,
        TeamName,
        Company,
        CSQName,
        CallDate,
        CallStartDateTime,
        CallEndDateTime,
        Disposition,
        OriginatorNumber,
        DestinationNumber,
        CalledNumber,
        OrigCalledNumber,
        CallsPresented,
        CallsHandled,
        CallsAbandoned,
        RingTime,
        TalkTime,
        HoldTime,
        WorkTime,
        WrapUpTime,
        QueueTime,
        MetServiceLevel,
        Transfer,
        Redirect,
        Conference,
        RNA
    )
    select
        e.EmployeeName AgentName,
        isnull(o.OrganisationName, 'Unknown') TeamName,
        'Unknown' Company,
        'Unknown' CSQName,
        d.[Date] CallDate,
        d.[Date] CallStartDateTime,
        d.[Date] CallEndDateTime,
        'Unknown' Disposition,
        'Unknown' OriginatorNumber,
        'Unknown' DestinationNumber,
        'Unknown' CalledNumber,
        'Unknown' OrigCalledNumber,
        0 CallsPresented,
        0 CallsHandled,
        0 CallsAbandoned,
        0 RingTime,
        0 TalkTime,
        0 HoldTime,
        0 WorkTime,
        0 WrapUpTime,
        0 QueueTime,
        0 MetServiceLevel,
        0 Transfer,
        0 Redirect,
        0 Conference,
        0 RNA
    from
        [db-au-cmdwh]..Calendar d
        inner join [db-au-cmdwh]..verEmployee e on
            1 = 1
        left join [db-au-cmdwh]..verTeam t on
            t.EmployeeKey = e.EmployeeKey and
            t.StartDate <= d.[Date] and 
            t.EndDate >= d.[Date]
        left join [db-au-cmdwh]..verOrganisation o on
            o.OrganisationKey = t.OrganisationKey
        left join [db-au-cmdwh].dbo.telCallData cd on
            cd.AgentName = e.EmployeeName and
            cd.CallDate = d.[Date]
    where
        e.EmployeeKey <> -1 and
        cd.BIRowID is null and
        d.[Date] >= @StartDate and
        d.[Date] <  dateadd(day, 1, @EndDate)

    delete 
    from 
        [db-au-cmdwh].dbo.telSales
    where
        PostingDate >= @StartDate and
        PostingDate <  dateadd(day, 1, @EndDate)


    insert into [db-au-cmdwh].dbo.telSales
    (
        AgentName,
        TeamName,
        Company,
        PolicyTransactionKey,
        PolicyNumber,
        PostingDate,
        Premium,
        SellPrice,
        PolicyCount
    )
    select 
        AgentName,
        TeamName,
        Company,
        PolicyTransactionKey,
        PolicyNumber,
        PostingDate,
        Premium,
        SellPrice,
        PolicyCount
    from
        [db-au-cmdwh]..vTelephonySales
    where
        PostingDate >= @StartDate and
        PostingDate <  dateadd(day, 1, @EndDate)
        
        
    if @@trancount > 0
        commit transaction
        

end


--truncate table [db-au-cmdwh]..telActivity
--truncate table [db-au-cmdwh]..telCallData
--truncate table [db-au-cmdwh]..telSales

--declare 
--    @start date,
--    @end date,
--    @err varchar(max)
    
--set @start = '2013-07-01'

--while @start < '2015-01-01'
--begin

--    set @end = dateadd(month, 1, @start)
--    set @end = dateadd(day, -1, @end)
    
    
--    exec [db-au-stage]..etlsp_cmdwh_telephony_summary
--        @StartDate = @start,
--        @EndDate = @end

--    set @err = convert(varchar(10), @start, 120) + char(9) + convert(varchar(20), getdate(), 120)
--    raiserror(@err, 1, 1) with nowait

--    set @start = dateadd(month, 1, @start)

--end
GO
