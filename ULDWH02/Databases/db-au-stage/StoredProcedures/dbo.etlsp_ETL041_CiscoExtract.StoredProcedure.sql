USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoExtract]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL041_CiscoExtract]
as
begin

    --2010326, LL, cisco data gets purged. this is to keep a copy on our side
	--20190611 Column rna Added to [db-au-stage].dbo.cisco_agentconnectiondetail by Ratnesh on 20190611 to fix insert failure

    if object_id('[db-au-stage].dbo.[cisco_resource]') is null
    begin

        create table [db-au-stage].[dbo].[cisco_resource]
        (
            [resourceid] int not null,
            [profileid] int not null,
            [resourceloginid] varchar(50) not null,
            [resourcename] varchar(50) not null,
            [resourcegroupid] int null,
            [resourcetype] smallint not null,
            [active] bit not null,
            [autoavail] bit not null,
            [extension] varchar(50) not null,
            [orderinrg] int null,
            [dateinactive] datetime2 null,
            [resourceskillmapid] int not null,
            [assignedteamid] int not null,
            [resourcefirstname] varchar(50) not null,
            [resourcelastname] varchar(50) not null,
            [resourcealias] varchar(50) null
        )

        create unique clustered index cidx_cisco_resource on [db-au-stage].dbo.[cisco_resource](resourceid)

    end

    truncate table [db-au-stage].dbo.[cisco_resource]

    insert into [db-au-stage].dbo.[cisco_resource] with(tablock)
    select 
        *
    from 
        openquery
        (
            CISCO,
            '
            select *
            from 
                resource
            for read only
            '
        ) a


    if object_id('[db-au-stage].dbo.cisco_team') is null
    begin

        create table [db-au-stage].[dbo].[cisco_team]
        (
            [teamid] int not null,
            [profileid] int not null,
            [teamname] varchar(50) not null,
            [active] bit not null,
            [dateinactive] datetime2 null
        )

        create unique clustered index cidx_cisco_team on [db-au-stage].dbo.cisco_team(teamid)

    end

    truncate table [db-au-stage].dbo.cisco_team

    insert into [db-au-stage].dbo.[cisco_team] with(tablock)
    select 
        *
    from 
        openquery
        (
            CISCO,
            '
            select *
            from 
                team
            for read only
            '
        ) a

    if object_id('[db-au-stage].dbo.[cisco_supervisor]') is null
    begin
    
        create table [db-au-stage].[dbo].[cisco_supervisor]
        (
            [recordid] int not null,
            [resourceloginid] varchar(50) not null,
            [managedteamid] int not null,
            [profileid] int not null,
            [supervisortype] smallint not null,
            [active] bit not null,
            [dateinactive] datetime2 null
        )

        create unique clustered index cidx_cisco_supervisor on [db-au-stage].dbo.[cisco_supervisor](recordid)

    end        

    truncate table [db-au-stage].dbo.[cisco_supervisor]

    insert into [db-au-stage].dbo.[cisco_supervisor] with(tablock)
    select 
        *
    from 
        openquery
        (
            CISCO,
            '
            select *
            from 
                supervisor
            for read only
            '
        ) a


    if object_id('[db-au-stage].dbo.cisco_contactservicequeue') is null
    begin

        create table [db-au-stage].[dbo].[cisco_contactservicequeue]
        (
            [contactservicequeueid] int not null,
            [profileid] int not null,
            [csqname] varchar(50) not null,
            [resourcepooltype] smallint not null,
            [resourcegroupid] int null,
            [selectioncriteria] varchar(30) not null,
            [skillgroupid] int null,
            [servicelevel] int not null,
            [servicelevelpercentage] smallint not null,
            [active] bit not null,
            [autowork] bit not null,
            [dateinactive] datetime2 null,
            [queuealgorithm] varchar(30) not null,
            [recordid] int not null,
            [orderlist] int null,
            [wrapuptime] smallint null,
            [prompt] varchar(256) not null,
            [privatedata] image null,
            [queuetype] smallint not null,
            [queuetypename] varchar(30) null,
            [accountuserid] varchar(254) null,
            [accountpassword] varchar(255) null,
            [channelproviderid] int null,
            [reviewqueueid] int null,
            [routingtype] varchar(30) null,
            [foldername] varchar(255) null,
            [pollinginterval] int null,
            [snapshotage] int null,
            [feedid] varchar(30) null
        )

        create unique clustered index cidx_cisco_contactservicequeue on [db-au-stage].dbo.[cisco_contactservicequeue](recordid,profileid)

    end

    truncate table [db-au-stage].dbo.cisco_contactservicequeue

    insert into [db-au-stage].dbo.cisco_contactservicequeue with(tablock)
    select 
        *
    from 
        openquery
        (
            CISCO,
            '
            select *
            from 
                contactservicequeue
            for read only
            '
        ) a
    


    --facts
    if object_id('[db-au-stage].dbo.cisco_agentconnectiondetail_tmp') is not null
        drop table [db-au-stage].dbo.cisco_agentconnectiondetail_tmp

    select 
        *
    into [db-au-stage].dbo.cisco_agentconnectiondetail_tmp
    from 
        openquery
        (
            CISCO,
            '
            select *
            from 
                agentconnectiondetail
            for read only
            '
        ) a


    if object_id('[db-au-stage].dbo.[cisco_agentconnectiondetail]') is null
    begin

        create table [db-au-stage].[dbo].[cisco_agentconnectiondetail]
        (
            [BIRowID] bigint not null identity(1,1),
            [sessionid] numeric(18,0) not null,
            [sessionseqnum] smallint not null,
            [nodeid] smallint not null,
            [profileid] int not null,
            [resourceid] int not null,
            [startdatetime] datetime2 not null,
            [enddatetime] datetime2 not null,
            [qindex] smallint not null,
            [gmtoffset] smallint not null,
            [ringtime] smallint null,
            [talktime] smallint null,
            [holdtime] smallint null,
            [worktime] smallint null,
            [callwrapupdata] varchar(40) null,
            [callresult] smallint null,
            [dialinglistid] int null,
			[rna] int null--Added by Ratnesh on 20190611 to fix insert failure
        )

        create unique clustered index cidx_cisco_agentconnectiondetail on [db-au-stage].[dbo].[cisco_agentconnectiondetail](BIRowID)
        create index idx on [db-au-stage].dbo.cisco_agentconnectiondetail
        (
            sessionid,
            sessionseqnum,
            nodeid,
            profileid,
            resourceid,
            startdatetime,
            enddatetime,
            qindex
        )

    end

    insert into [db-au-stage].dbo.cisco_agentconnectiondetail with(tablock)
    (
        [sessionid],
        [sessionseqnum],
        [nodeid],
        [profileid],
        [resourceid],
        [startdatetime],
        [enddatetime],
        [qindex],
        [gmtoffset],
        [ringtime],
        [talktime],
        [holdtime],
        [worktime],
        [callwrapupdata],
        [callresult],
        [dialinglistid],
		[rna]
    )
    select
        *
    from
        [db-au-stage].dbo.cisco_agentconnectiondetail_tmp t
    where
        not exists
        (
            select 
                null
            from
                [db-au-stage].dbo.cisco_agentconnectiondetail r
            where
                r.sessionid = t.sessionid and
                r.sessionseqnum = t.sessionseqnum and
                r.nodeid = t.nodeid and
                r.profileid = t.profileid and
                r.resourceid = t.resourceid and
                r.startdatetime = t.startdatetime and
                r.enddatetime = t.enddatetime and
                r.qindex = t.qindex
        )



    if object_id('[db-au-stage].dbo.cisco_contactcalldetail_tmp') is not null
        drop table [db-au-stage].dbo.cisco_contactcalldetail_tmp

    select 
        *
    into [db-au-stage].dbo.cisco_contactcalldetail_tmp
    from 
        openquery
        (
            CISCO,
            '
            select *
            from 
                contactcalldetail
            for read only
            '
        ) a



    if object_id('[db-au-stage].dbo.[cisco_contactcalldetail]') is null
    begin

        create table [db-au-stage].[dbo].[cisco_contactcalldetail]
        (
            [BIRowID] bigint not null identity(1,1),
            [sessionid] numeric(18,0) not null,
            [sessionseqnum] smallint not null,
            [nodeid] smallint not null,
            [profileid] int not null,
            [contacttype] smallint not null,
            [contactdisposition] smallint not null,
            [dispositionreason] varchar(100) null,
            [originatortype] smallint not null,
            [originatorid] int null,
            [originatordn] varchar(30) null,
            [destinationtype] smallint null,
            [destinationid] int null,
            [destinationdn] varchar(30) null,
            [startdatetime] datetime2 not null,
            [enddatetime] datetime2 not null,
            [gmtoffset] smallint not null,
            [callednumber] varchar(30) null,
            [origcallednumber] varchar(30) null,
            [applicationtaskid] numeric(18,0) null,
            [applicationid] int null,
            [applicationname] varchar(30) null,
            [connecttime] smallint null,
            [customvariable1] varchar(40) null,
            [customvariable2] varchar(40) null,
            [customvariable3] varchar(40) null,
            [customvariable4] varchar(40) null,
            [customvariable5] varchar(40) null,
            [customvariable6] varchar(40) null,
            [customvariable7] varchar(40) null,
            [customvariable8] varchar(40) null,
            [customvariable9] varchar(40) null,
            [customvariable10] varchar(40) null,
            [accountnumber] varchar(40) null,
            [callerentereddigits] varchar(40) null,
            [badcalltag] char(1) null,
            [transfer] bit null,
            [redirect] bit null,
            [conference] bit null,
            [flowout] bit null,
            [metservicelevel] bit null,
            [campaignid] int null,
            [origprotocolcallref] varchar(32) null,
            [destprotocolcallref] varchar(32) null,
            [callresult] smallint null,
            [dialinglistid] int null
        )

        create unique clustered index cidx_cisco_agentconnectiondetail on [db-au-stage].[dbo].[cisco_contactcalldetail](BIRowID)
        create index idx on [db-au-stage].dbo.[cisco_contactcalldetail]
        (
            sessionid,
            sessionseqnum,
            nodeid,
            profileid,
            startdatetime,
            enddatetime,
            callednumber
        )

    end

    insert into [db-au-stage].dbo.[cisco_contactcalldetail] with(tablock)
    (
        sessionid,
        sessionseqnum,
        nodeid,
        profileid,
        contacttype,
        contactdisposition,
        dispositionreason,
        originatortype,
        originatorid,
        originatordn,
        destinationtype,
        destinationid,
        destinationdn,
        startdatetime,
        enddatetime,
        gmtoffset,
        callednumber,
        origcallednumber,
        applicationtaskid,
        applicationid,
        applicationname,
        connecttime,
        customvariable1,
        customvariable2,
        customvariable3,
        customvariable4,
        customvariable5,
        customvariable6,
        customvariable7,
        customvariable8,
        customvariable9,
        customvariable10,
        accountnumber,
        callerentereddigits,
        badcalltag,
        transfer,
        redirect,
        conference,
        flowout,
        metservicelevel,
        campaignid,
        origprotocolcallref,
        destprotocolcallref,
        callresult,
        dialinglistid
    )
    select *
    from
        [db-au-stage].dbo.cisco_contactcalldetail_tmp t
    where
        not exists
        (
            select 
                null
            from
                [db-au-stage].dbo.cisco_contactcalldetail r
            where
                r.sessionid = t.sessionid and
                r.sessionseqnum = t.sessionseqnum and
                r.nodeid = t.nodeid and
                r.profileid = t.profileid and
                r.startdatetime = t.startdatetime and
                r.enddatetime = t.enddatetime and
                r.callednumber = t.callednumber
        )



    if object_id('[db-au-stage].dbo.cisco_contactqueuedetail_tmp') is not null
        drop table [db-au-stage].dbo.cisco_contactqueuedetail_tmp


    select --top 100
        *
    into [db-au-stage].dbo.cisco_contactqueuedetail_tmp
    from 
        openquery
        (
            CISCO,
            '
            select *
            from 
                contactqueuedetail
            for read only
            '
        ) a


    if object_id('[db-au-stage].dbo.[cisco_contactqueuedetail]') is null
    begin

        create table [db-au-stage].[dbo].[cisco_contactqueuedetail]
        (
            [BIRowID] bigint not null identity(1,1),
            [sessionid] numeric(18,0) not null,
            [sessionseqnum] smallint not null,
            [profileid] int not null,
            [nodeid] smallint not null,
            [targetid] int not null,
            [targettype] smallint not null,
            [qindex] smallint not null,
            [queueorder] smallint not null,
            [disposition] smallint null,
            [metservicelevel] bit null,
            [queuetime] smallint null
        )

        create unique clustered index cidx_cisco_contactqueuedetail on [db-au-stage].[dbo].[cisco_contactqueuedetail](BIRowID)
        create index idx on [db-au-stage].dbo.[cisco_contactqueuedetail]
        (
            sessionid,
            sessionseqnum,
            nodeid,
            profileid,
            targetid,
            qindex
        )

    end


    insert into [db-au-stage].dbo.cisco_contactqueuedetail with(tablock)
    (
        [sessionid],
        [sessionseqnum],
        [profileid],
        [nodeid],
        [targetid],
        [targettype],
        [qindex],
        [queueorder],
        [disposition],
        [metservicelevel],
        [queuetime]
    )
    select *
    from
        [db-au-stage].dbo.cisco_contactqueuedetail_tmp t
    where
        not exists
        (
            select 
                null
            from
                [db-au-stage].dbo.cisco_contactqueuedetail r
            where
                r.sessionid = t.sessionid and
                r.sessionseqnum = t.sessionseqnum and
                r.nodeid = t.nodeid and
                r.profileid = t.profileid and
                r.targetid = t.targetid and
                r.qindex = t.qindex
        )

end
GO
