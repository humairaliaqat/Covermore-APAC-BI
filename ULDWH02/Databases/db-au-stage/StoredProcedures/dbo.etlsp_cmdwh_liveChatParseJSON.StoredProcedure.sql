USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_liveChatParseJSON]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_liveChatParseJSON]
as
begin

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

	begin try
	
		exec syssp_getrunningbatch
			@SubjectArea = 'Live Chat',
			@BatchID = @batchid out,
			@StartDate = @start out,
			@EndDate = @end out
			
	end try
	
	begin catch
		
		set @batchid = -1
	
	end catch

    select
        @name = object_name(@@procid)
	
    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    --prepare json table 
    if object_id('tempdb..#livechat_json') is not null
        drop table #livechat_json

    create table #livechat_json
    (
        chatid varchar(50),
        chatstring varchar(max),
        datatype varchar(max)
    )

    insert into #livechat_json
    (
        chatid,
        chatstring,
        datatype
    )
    select --top 3000
        ChatID,
        ChatJSON,
        DataType
    from
        [db-au-cmdwh]..lcLiveChatRaw
    where
        BatchID = @batchid 

    --chat details
    if object_id('[db-au-cmdwh]..lcLiveChat') is null
    begin

        create table [db-au-cmdwh]..lcLiveChat
        (
            [BIRowID] bigint not null identity(1,1),
            [ChatID] [nvarchar](50) null,
            [ChatType] [nvarchar](30) null,
            [Rate] [nvarchar](50) null,
            [Duration] int null,
            [StartURL] [varchar](max) null,
            [Referrer] [varchar](max) null,
            [IsPending] bit null,
            [Engagement] [nvarchar](50) null,
            [StartTime] [datetime] null,
            [EndTime] [datetime] null,
            [CustomerName] [nvarchar](max) null,
            [Email] [nvarchar](max) null,
            [IP] [varchar](100) null,
            [City] [nvarchar](max) null,
            [Region] [nvarchar](max) null,
            [Country] [nvarchar](max) null,
            [TimeZone] [nvarchar](100) null,
            [CustomerID] [bigint] null,
            [Mobile] varchar(20) null,
            [PolicyNumber] varchar(50) null,
            [ClaimNumber] varchar(50) null,
            [BatchID] int
        ) 

        create unique clustered index cid on [db-au-cmdwh]..lcLiveChat(BIRowID)
        create nonclustered index idx_chatid on [db-au-cmdwh]..lcLiveChat(ChatID)
        create nonclustered index idx_date on [db-au-cmdwh]..lcLiveChat(StartTime)
        create nonclustered index idx_customer on [db-au-cmdwh]..lcLiveChat(CustomerID) include(ChatID,ChatType,StartTime,Duration,Rate,IP,Country)

    end

    if object_id('tempdb..#livechat') is not null
        drop table #livechat

    select 
        t.ChatID,
        replace(t.chattype, '"', '') ChatType,
        replace(t.rate, '"', '') Rate,
        try_convert(int, t.Duration) Duration,
        replace(t.chat_start_url, '"', '') StartURL,
        replace(convert(varchar(max), t.referrer), '"', '') Referrer,
        case
            when t.pending = 'false' then 0
            else 1
        end IsPending,
        replace(t.engagement, '"', '') Engagement,
        case
            when t.chattype = '"missed_chat"' then [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(try_convert(datetime, replace(t.started, '"', '')), 'AUS Eastern Standard Time')
            else [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(dateadd(second, try_convert(bigint, t.started_timestamp), '1970-01-01 00:00:00.000'), 'AUS Eastern Standard Time')
        end StartTime,
        [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(dateadd(second, try_convert(bigint, t.ended_timestamp), '1970-01-01 00:00:00.000'), 'AUS Eastern Standard Time') EndTime,
        replace(t.name, '"', '') CustomerName,
        replace(t.email, '"', '') Email,
        replace(t.ip, '"', '') IP,
        replace(t.city, '"', '') City,
        replace(t.region, '"', '') Region,
        replace(t.country, '"', '') Country,
        replace(t.timezone, '"', '') TimeZone
    into #livechat
    from
        (
            select 
                chatid,
                json_value(t.chatstring, '$.type') "chattype",
                json_value(t.chatstring, '$.rate') "rate",
                json_value(t.chatstring, '$.duration') "duration",
                json_value(t.chatstring, '$.chat_start_url') "chat_start_url",
                json_value(t.chatstring, '$.referrer') "referrer",
                json_value(t.chatstring, '$.pending') "pending",
                json_value(t.chatstring, '$.engagement') "engagement",
                case
                    when json_value(t.chatstring, '$.type') = '"chat"' then json_value(t.chatstring, '$.started')
                    else json_value(t.chatstring, '$.time')
                end "started",
                json_value(t.chatstring, '$.ended') "ended",
                json_value(t.chatstring, '$.started_timestamp') "started_timestamp",
                json_value(t.chatstring, '$.ended_timestamp') "ended_timestamp",
                json_value(t.chatstring, '$.visitor_name') "name",
                json_value(t.chatstring, '$.visitor.email') "email",
                json_value(t.chatstring, '$.visitor.ip') "ip",
                json_value(t.chatstring, '$.visitor.city') "city",
                json_value(t.chatstring, '$.visitor.region') "region",
                json_value(t.chatstring, '$.visitor.country') "country",
                json_value(t.chatstring, '$.visitor.timezone') "timezone"
            from
                #livechat_json t
            where
                datatype = 'chat'

            union all

            select
                chatid,
                'ticket' "chattype",
                json_value(t.chatstring, '$.rate') "rate",
                json_value(t.chatstring, '$.duration') "duration",
                json_value(t.chatstring, '$.source.url') "chat_start_url",
                json_value(t.chatstring, '$.referrer') "referrer",
                case
                    when json_value(t.chatstring, '$.status') <> '"solved"' then '1'
                    else '0'
                end "pending",
                null "engagement",
                json_value(t.chatstring, '$.date') "started",
                json_value(t.chatstring, '$.modified') "ended",
                null "started_timestamp",
                null "ended_timestamp",
                json_value(t.chatstring, '$.requester.name') "name",
                json_value(t.chatstring, '$.requester.email') "email",
                json_value(t.chatstring, '$.requester.ip') "ip",
                null "city",
                null "region",
                null "country",
                json_value(t.chatstring, '$.requester.utc_offset') "timezone"
            from
                #livechat_json t
            where
                datatype = 'ticket'
        ) t


    delete
    from
        [db-au-cmdwh]..lcLiveChat
    where
        ChatID in
        (
            select 
                ChatID
            from
                #livechat
        )

    insert into [db-au-cmdwh]..lcLiveChat
    (
        [ChatID],
        [ChatType],
        [Rate],
        [Duration],
        [StartURL],
        [Referrer],
        [IsPending],
        [Engagement],
        [StartTime],
        [EndTime],
        [CustomerName],
        [Email],
        [IP],
        [City],
        [Region],
        [Country],
        [TimeZone],
        [BatchID]
    )
    select 
        [ChatID],
        [ChatType],
        [Rate],
        [Duration],
        [StartURL],
        [Referrer],
        [IsPending],
        [Engagement],
        [StartTime],
        [EndTime],
        [CustomerName],
        [Email],
        [IP],
        [City],
        [Region],
        [Country],
        [TimeZone],
        @batchid
    from
        #livechat


    
    --agents
    if object_id('[db-au-cmdwh]..lcLiveChatAgent') is null
    begin

        create table [db-au-cmdwh]..lcLiveChatAgent
        (
            [BIRowID] bigint not null identity(1,1),
            [ChatID] [nvarchar](50) null,
            [Agent] [nvarchar](max) null,
            [AgentEmail] [nvarchar](max) null,
            [isSupervisor] [varchar](100) null,
            [BatchID] int
        ) 

        create unique clustered index cid on [db-au-cmdwh]..lcLiveChatAgent(BIRowID)
        create nonclustered index idx_chatid on [db-au-cmdwh]..lcLiveChatAgent(ChatID)

    end

    if object_id('tempdb..#livechatagents') is not null
        drop table #livechatagents

    select 
        t.ChatID,
        replace(t.agentname, '"', '') Agent,
        replace(t.agentemail, '"', '') AgentEmail,
        convert(bit, isSupervisor) isSupervisor
    into #livechatagents
    from
        (
            select 
                chatid,
                json_value(r.value, '$.display_name') "agentname",
                json_value(r.value, '$.email') "agentemail",
                0 "isSupervisor"
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.agents') r
            where
                datatype = 'chat'

            union all

            select 
                chatid,
                json_value(r.value, '$.display_name') "agentname",
                json_value(r.value, '$.email') "agentemail",
                1 "isSupervisor"
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.supervisors') r
            where
                datatype = 'chat'

            union all

            select 
                chatid,
                json_value(r.value, '$.author.name') "agentname",
                json_value(r.value, '$.author.id') "agentemail",
                0 "isSupervisor"
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.events') r
            where
                datatype = 'ticket'
        ) t    

    delete
    from
        [db-au-cmdwh]..lcLiveChatAgent
    where
        ChatID in
        (
            select 
                ChatID
            from
                #livechatagents
        )

    insert into [db-au-cmdwh]..lcLiveChatAgent
    (
        ChatID,
        Agent,
        AgentEmail,
        isSupervisor,
        BatchID
    )
    select
        ChatID,
        Agent,
        AgentEmail,
        isSupervisor,
        @batchid
    from
        #livechatagents


    --tags
    if object_id('[db-au-cmdwh]..lcLiveChatTags') is null
    begin

        create table [db-au-cmdwh]..lcLiveChatTags
        (
            [BIRowID] bigint not null identity(1,1),
            [ChatID] [nvarchar](50) null,
            [Tags] [nvarchar](200) null,
            [BatchID] int
        ) 

        create unique clustered index cid on [db-au-cmdwh]..lcLiveChatTags(BIRowID)
        create nonclustered index idx_chatid on [db-au-cmdwh]..lcLiveChatTags(ChatID) include (Tags)
        create nonclustered index idx_tags on [db-au-cmdwh]..lcLiveChatTags(Tags) include (ChatID)

    end

    if object_id('tempdb..#livechattags') is not null
        drop table #livechattags

    select
        t.ChatID,
        replace(t.tags, '"', '') Tags
    into #livechattags
    from
        (
            select 
                chatid,
                r.value tags
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.tags') r

            union all

            select 
                chatid,
                json_value(t.chatstring, '$.subject') tags
            from
                #livechat_json t
            where
                datatype = 'ticket'
        ) t

    delete
    from
        [db-au-cmdwh]..lcLiveChatTags
    where
        ChatID in
        (
            select 
                ChatID
            from
                #livechattags
        )

    insert into [db-au-cmdwh]..lcLiveChatTags
    (
        ChatID,
        Tags,
        BatchID
    )
    select 
        ChatID,
        Tags,
        @batchid
    from
        #livechattags


    --survey
    if object_id('[db-au-cmdwh]..lcLiveChatSurvey') is null
    begin

        create table [db-au-cmdwh]..lcLiveChatSurvey
        (
            [BIRowID] bigint not null identity(1,1),
            [ChatID] [nvarchar](50) null,
            [SurveyType] [varchar](10) null,
            [Question] [nvarchar](255) null,
            [Answer] [nvarchar](2048) null,
            [BatchID] int
        ) 

        create unique clustered index cid on [db-au-cmdwh]..lcLiveChatSurvey(BIRowID)
        create nonclustered index idx_chatid on [db-au-cmdwh]..lcLiveChatSurvey(ChatID) 

    end

    if object_id('tempdb..#livechatsurvey') is not null
        drop table #livechatsurvey

    select
        t.ChatID,
        t.type SurveyType,
        replace(replace(t.question, '"', ''), ':', '') Question,
        replace(replace(convert(nvarchar(max), t.answer), '"', ''), ':', '') Answer
    into #livechatsurvey
    from
        (
            select 
                chatid,
                'Pre' "type",
                json_value(r.value, '$.key') question,
                json_value(r.value, '$.value') answer
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.prechat_survey') r

            union all

            select 
                chatid,
                'Post' "type",
                json_value(r.value, '$.key') question,
                json_value(r.value, '$.value') answer
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.postchat_survey') r
        ) t

    delete
    from
        [db-au-cmdwh]..lcLiveChatSurvey
    where
        ChatID in
        (
            select 
                ChatID
            from
                #livechatsurvey
        )

    insert into [db-au-cmdwh]..lcLiveChatSurvey
    (
        ChatID,
        SurveyType,
        Question,
        Answer,
        BatchID
    )
    select
        ChatID,
        SurveyType,
        Question,
        Answer,
        @batchid
    from
        #livechatsurvey


    --events
    if object_id('[db-au-cmdwh]..lcLiveChatEvents') is null
    begin

        create table [db-au-cmdwh]..lcLiveChatEvents
        (
            [BIRowID] bigint not null identity(1,1),
            [ChatID] [nvarchar](50) null,
            [EventTime] datetime null,
            [Author] [nvarchar](max) null,
            [AgentID] [nvarchar](max) null,
            [AuthorType] [varchar](30) null,
            [EventType] [nvarchar](255) null,
            [EventText] [nvarchar](max) null,
            [BatchID] int
        ) 

        create unique clustered index cid on [db-au-cmdwh]..lcLiveChatEvents(BIRowID)
        create nonclustered index idx_chatid on [db-au-cmdwh]..lcLiveChatEvents(ChatID) 

    end

    if object_id('tempdb..#livechatevents') is not null
        drop table #livechatevents

    select
        t.ChatID,
        [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(dateadd(second, try_convert(bigint, t.timestamp), '1970-01-01 00:00:00.000'), 'AUS Eastern Standard Time') EventTime,
        replace(t.author, '"', '') Author,
        replace(t.agent_id, '"', '') AgentID,
        replace(t.user_type, '"', '') AuthorType,
        replace(t.type, '"', '') EventType,
        replace(convert(nvarchar(max), t.text), '"', '') EventText
    into #livechatevents
    from
        (
            select 
                chatid,
                json_value(r.value, '$.timestamp') "timestamp",
                json_value(r.value, '$.author_name') "author",
                json_value(r.value, '$.text') "text",
                json_value(r.value, '$.agent_id') "agent_id",
                json_value(r.value, '$.user_type') "user_type",
                json_value(r.value, '$.type') "type"
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.events') r
            where
                datatype = 'chat'

            union all

            select 
                chatid,
                json_value(r.value, '$.date.timestamp') "timestamp",
                json_value(r.value, '$.author.name') "author",
                case
                    when json_value(r.value, '$.type') = '"status_changed"' then json_value(r.value, '$.current')
                    when json_value(r.value, '$.type') = '"assignee_changed"' then json_value(r.value, '$.to.id')
                    else json_value(r.value, '$.message')
                end "text",
                json_value(r.value, '$.author.id') "agent_id",
                json_value(r.value, '$.author.type') "user_type",
                json_value(r.value, '$.type') "type"
            from
                #livechat_json t
                cross apply openjson(t.chatstring, '$.events') r
            where
                datatype = 'ticket'
        ) t

    delete
    from
        [db-au-cmdwh]..lcLiveChatEvents
    where
        ChatID in
        (
            select 
                ChatID
            from
                #livechatevents
        )

    insert into [db-au-cmdwh]..lcLiveChatEvents
    (
        ChatID,
        EventTime,
        Author,
        AgentID,
        AuthorType,
        EventType,
        EventText,
        BatchID
    )
    select
        ChatID,
        EventTime,
        Author,
        AgentID,
        AuthorType,
        EventType,
        EventText,
        @batchid
    from
        #livechatevents






    --mobile phone
    update lc
    set
        lc.Mobile = ph.Phone
    from
        [db-au-cmdwh]..lcLiveChat lc
        cross apply
        (
            select top 1 
                case
                    when EventText like '%614[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' then substring(lce.EventText, patindex('%614[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', lce.EventText), 11) 
                    else '61' + substring(lce.EventText, patindex('%04[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', lce.EventText) + 1, 9) 
                end Phone
            from
                [db-au-cmdwh]..lcLiveChatEvents lce
            where
                lce.ChatID = lc.ChatID and
                lce.EventType = 'message' and
                (
                    lce.EventText like '%04[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' or
                    lce.EventText like '%614[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'
                )
        ) ph
    where
        lc.BatchID = @batchid


    --policy
    update lc
    set
        lc.PolicyNumber = r.Policy
    --select
    --    lc.ChatID,
    --    r.*
    from
        [db-au-cmdwh]..lcLiveChat lc
        cross apply
        (
            select top 1 
                case
                    when EventText like '%[7-8][1-3][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' then substring(lce.EventText, patindex('%[7-8][1-3][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', lce.EventText), 12) 
                    when EventText like '% [5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' then substring(lce.EventText, patindex('% [5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', lce.EventText) + 1, 8) 
                    when EventText like '[5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^0-9]%' then substring(lce.EventText, patindex('[5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^0-9]%', lce.EventText), 8) 
                    else ''
                end Policy,
                EventText
            from
                [db-au-cmdwh]..lcLiveChatEvents lce
            where
                lce.ChatID = lc.ChatID and
                lce.EventType = 'message' and
                (
                    lce.EventText like '%[7-8][1-3][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^0-9]%' or
                    lce.EventText like '% [5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^0-9]%' or
                    lce.EventText like '[5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^0-9]%'
                )
        ) r
    where
        lc.BatchID = @batchid

    --claim
    update lc
    set
        lc.ClaimNumber = r.Claim
    --select
    --    lc.ChatID,
    --    r.*
    from
        [db-au-cmdwh]..lcLiveChat lc
        cross apply
        (
            select top 1 
                case
                    when EventText like '%[^0-9]1[0-1][0-9][0-9][0-9][0-9][0-9][^0-9]%' then substring(lce.EventText, patindex('%1[0-1][0-9][0-9][0-9][0-9][0-9][^0-9]%', lce.EventText), 7) 
                    when EventText like '%[^0-9][5-9][0-9][0-9][0-9][0-9][0-9][^0-9]%' then substring(lce.EventText, patindex('%[5-9][0-9][0-9][0-9][0-9][0-9][^0-9]%', lce.EventText), 6) 
                    else ''
                end Claim,
                EventText
            from
                [db-au-cmdwh]..lcLiveChatEvents lce
            where
                lce.ChatID = lc.ChatID and
                lce.EventType = 'message' and
                (
                    lce.EventText like '%[^0-9]1[0-1][0-9][0-9][0-9][0-9][0-9][^0-9]%' or
                    lce.EventText like '%[^0-9][5-9][0-9][0-9][0-9][0-9][0-9][^0-9]%'
                )
        ) r
    where
        lc.BatchID = @batchid




    --update customer id
    update lc
    set
        lc.CustomerID = ec.CustomerID
    --select 
    --    lc.ChatID,    
    --    lc.CustomerName,
    --    lc.Email,
    --    lc.Mobile,
    --    lc.PolicyNumber,
    --    lc.ClaimNumber,
    --    ec.CUstomerName
    from
        [db-au-cmdwh]..lcLiveChat lc
        cross apply
        (
            select top 1 
                PolicyKey
            from
                [db-au-cmdwh]..penPolicy p with(nolock)
            where
                p.CountryKey = 'AU' and
                p.PolicyNumber = lc.PolicyNumber
        ) p
        cross apply
        (
            select top 1
                ec.CUstomerName,
                ec.CustomerID
            from
                [db-au-cmdwh]..entCustomer ec with(nolock)
                inner join [db-au-cmdwh]..entPolicy ep with(nolock) on
                    ep.CustomerID = ec.CustomerID
            where
                ep.PolicyKey = p.PolicyKey
            order by
                case
                    when soundex(ec.CUstomerName) = soundex(lc.CustomerName) then -2
                    when left(soundex(ec.CUstomerName), 2) = left(soundex(lc.CustomerName), 2) then -1
                    else ec.CustomerID
                end
        ) ec
    where
        PolicyNumber is not null and
        lc.BatchID = @batchid

    update lc
    set
        lc.CustomerID = ec.CustomerID
    --select 
    --    lc.ChatID,    
    --    lc.CustomerName,
    --    lc.Email,
    --    lc.Mobile,
    --    lc.PolicyNumber,
    --    lc.ClaimNumber,
    --    ec.CUstomerName
    from
        [db-au-cmdwh]..lcLiveChat lc
        cross apply
        (
            select top 1 
                pt.PolicyKey
            from
                [db-au-cmdwh]..clmClaim cl with(nolock)
                inner join [db-au-cmdwh]..penPolicyTransSummary pt with(nolock) on
                    pt.PolicyTransactionKey = cl.PolicyTransactionKey
            where
                cl.CountryKey = 'AU' and
                cl.ClaimNo = try_convert(int, lc.ClaimNumber)
        ) p
        cross apply
        (
            select top 1
                ec.CUstomerName,
                ec.CustomerID
            from
                [db-au-cmdwh]..entCustomer ec
                inner join [db-au-cmdwh]..entPolicy ep on
                    ep.CustomerID = ec.CustomerID
            where
                ep.PolicyKey = p.PolicyKey
            order by
                case
                    when soundex(ec.CUstomerName) = soundex(lc.CustomerName) then -2
                    when left(soundex(ec.CUstomerName), 2) = left(soundex(lc.CustomerName), 2) then -1
                    else ec.CustomerID
                end
        ) ec
    where
        lc.CustomerID is null and
        lc.ClaimNumber is not null and
        lc.BatchID = @batchid


    update t
    set
        t.CustomerID = coalesce(ec1.CustomerID, ec2.CustomerID, ec3.CustomerID)
    --select 
    --    ChatID,
    --    t.CustomerName,
    --    Email,
    --    ec1.*,
    --    ec2.*,
    --    ec3.*
    from
        [db-au-cmdwh]..lcLiveChat t
        outer apply
        (
            select top 1 
                CustomerID
                --,
                --CustomerName
            from
                [db-au-cmdwh]..entCustomer ec
            where
                ec.CurrentEmail = t.Email and
                ec.CUstomerName like t.CustomerName + '%'
        ) ec1
        outer apply
        (
            select top 1 
                CustomerID
                --,
                --CustomerName
            from
                [db-au-cmdwh]..entCustomer ec
            where
                ec1.CustomerID is null and
                ec.CurrentEmail = t.Email and
                soundex(ec.CUstomerName) = soundex(t.CustomerName)
        ) ec2
        outer apply
        (
            select 
                ec.CustomerID
                --,
                --CustomerName
            from
                [db-au-cmdwh]..entEmail e
                inner join [db-au-cmdwh]..entCustomer ec on
                    ec.CustomerID = e.CustomerID
            where
                ec1.CustomerID is null and
                ec2.CustomerID is null and
                e.EmailAddress = t.Email and
                not exists
                (
                    select 
                        null
                    from
                        [db-au-cmdwh]..entEmail r
                    where
                        r.EmailAddress = e.EmailAddress and
                        r.CustomerID <> e.CustomerID
                )
        ) ec3
    where
        t.CustomerID is null and
        Email is not null and
        Email not like 'test%' and
        BatchID = @batchid

    update lc
    set
        lc.CustomerID = ec.CustomerID
    --select 
    --    lc.ChatID,    
    --    lc.CustomerName,
    --    lc.Email,
    --    lc.Mobile,
    --    lc.PolicyNumber,
    --    lc.ClaimNumber,
    --    ec.CUstomerName
    from
        [db-au-cmdwh]..lcLiveChat lc
        cross apply
        (
            select top 3
                ec.CUstomerName,
                ec.CustomerID
            from
                [db-au-cmdwh]..entCustomer ec with(nolock)
                inner join [db-au-cmdwh]..entPhone ep with(nolock) on
                    ep.CustomerID = ec.CustomerID
            where
                ep.PhoneNumber = lc.Mobile
            order by
                case
                    when soundex(ec.CUstomerName) = soundex(lc.CustomerName) then -2
                    when left(soundex(ec.CUstomerName), 2) = left(soundex(lc.CustomerName), 2) then -1
                    else ec.CustomerID
                end
        ) ec
    where
        lc.CustomerID is null and
        lc.Mobile is not null

end

GO
