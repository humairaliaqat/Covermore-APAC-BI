USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_Timeline]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [opsupport].[rptsp_EnterpriseSearch_Timeline]
    @Customer EVSearch readonly

as
begin

    --credit card base products
    if object_id('tempdb..#basepolicies') is not null
        drop table #basepolicies

    create table #basepolicies
        (
            ProductCode varchar(50)
        )

    insert into #basepolicies
    (
        ProductCode
    )
    select 
        Item
    from
        [db-au-cmdwh].dbo.fn_DelimitedSplit8K('BWB,CBB', ',')


    --build and cache interaction timeline
    if object_id('tempdb..#timeline') is not null
        drop table #timeline

    create table #timeline
        (
            CustomerID bigint,
            [When] date,
            [What] varchar(14),
            [Detail] nvarchar(70),
            [Where] nvarchar(max),
            Tooltip varchar(4000),
            ReferenceID varchar(100),
            [Value] float,
            [Transcript] nvarchar(4000)
        )

    --policy related interactions
    if object_id('tempdb..#tlpolicy') is not null
        drop table #tlpolicy

    select 
        ec.CustomerID,
        p.PolicyKey,
        p.PolicyNumber,
        
        convert(date, p.IssueDate) IssueWhen,
        'Bought Policy' IssueWhat,
        p.PolicyNumber IssueDetail,
        'Australia' IssueWhere,
        '' IssueTooltip,

        convert(date, p.CancelledDate) CancelWhen,
        'Cancel Policy' CancelWhat,
        p.PolicyNumber CancelDetail,
        'Australia' CancelWhere,
        '' CancelTooltip,

        convert(date, p.TripStart) DepartWhen,
        'Departing' DepartWhat,
        p.PolicyNumber DepartDetail,
        PrimaryCountry DepartWhere,
        '' DepartTooltip,

        convert(date, p.TripEnd) ReturnWhen,
        'Returning' ReturnWhat,
        p.PolicyNumber ReturnDetail,
        PrimaryCountry ReturnWhere,
        '' ReturnTooltip,

        PolicyTranscript,
        ProductCode

    into #tlpolicy
    from
        [db-au-cmdwh].dbo.entCustomer ec with(nolock)
        outer apply
        (
            select
                p.PolicyKey,
                p.PolicyNumber,
                p.PrimaryCountry,
                convert(date, p.IssueDate) IssueDate,
                p.TripStart,
                p.TripEnd,
                p.CancelledDate,
                p.ProductCode,

                (
                    select
                        o.CountryKey Domain,
                        o.CompanyKey Business,
                        o.GroupName,
                        case
                            when p.TripStart <= convert(date, getdate()) and p.TripEnd >= convert(date, getdate()) then 'On trip'
                            when p.TripEnd < convert(date, getdate()) then 'Expired'
                            when p.StatusDescription <> 'Active' then 'Cancelled'
                            else 'Active'
                        end [Status],
                        p.TripType,
                        p.PrimaryCountry Destination,
                        p.TripStart,
                        p.TripEnd,
                        ptv.TravellerCount,
                        isnull(cl.ClaimCount, 0) ClaimCount
                    for json path, without_array_wrapper
                ) PolicyTranscript

            from
                [db-au-cmdwh].dbo.penPolicy p with(nolock)
                inner join [db-au-cmdwh].[dbo].[penOutlet] o with(nolock) on
                    o.OutletAlphaKey = p.OutletAlphaKey and
                    o.OutletStatus = 'Current'
                cross apply
                (
                    select 
                        sum(1) TravellerCount
                    from
                        [db-au-cmdwh].[dbo].[penPolicyTraveller] ptv with(nolock)
                    where
                        ptv.PolicyKey = p.PolicyKey   
                ) ptv
                outer apply
                (
                    select 
                        count(cl.ClaimKey) ClaimCount
                    from
                        [db-au-cmdwh].[dbo].[penPolicyTransaction] pt with(nolock)
                        inner join [db-au-cmdwh].[dbo].[clmClaim] cl on
                            cl.PolicyTransactionKey = pt.PolicyTransactionKey
                    where
                        pt.PolicyKey = p.PolicyKey
                ) cl

            where
                p.PolicyKey in
                (
                    select 
                        PolicyKey
                    from
                        [db-au-cmdwh].dbo.entPolicy ep with(nolock)
                    where
                        ep.CustomerID = ec.CustomerID
                )
        ) p
    where
        ec.CustomerID in
        (
            select 
                CustomerID 
            from 
                @Customer
        )

    --build link from policy interaction to other transactions
    if object_id('tempdb..#policytransaction') is not null
        drop table #policytransaction

    select 
        p.CustomerID,
        p.PolicyNumber,
        pt.PolicyKey,
        pt.PolicyTransactionKey,
        p.ReturnWhen,
        o.ContactPhone,
        o.OutletName,
        pt.NewPolicyCount,
        pt.GrossPremium,
        p.ProductCode
    into #policytransaction
    from
        #tlpolicy p
        inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
            pt.PolicyKey = p.PolicyKey
        inner join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
            o.OutletStatus = 'Current' and
            o.OutletAlphaKey = pt.OutletAlphaKey 

    --claim related 
    if object_id('tempdb..#claim') is not null
        drop table #claim

    select 
        pt.CustomerID,

        convert(date, ce.EventDate) EventWhen,
        'Claim Event' EventWhat,
        convert(varchar(50), cl.ClaimNo) EventDetail,
        ce.EventCountryName EventWhere,
        '' EventTooltip,

        convert(date, cl.CreateDate) ClaimWhen,
        'Make a claim' ClaimWhat,
        convert(varchar(50), cl.CLaimNo) ClaimDetail,
        case
            when cl.CreateDate > pt.ReturnWhen then 'Australia'
            when cl.OnlineClaim = 1 then ce.EventCountryName
            else 'Australia' 
        end ClaimWhere,
        '' ClaimTooltip,

        isnull(ci.ClaimValue, 0) ClaimValue,
        cl.ClaimKey,

        'Event date: ' + isnull(convert(varchar(20), ce.EventDate, 106), '') + char(10) + 
        'Location:' + char(10) + cf.EventLocation + char(10) + char(10) +
        left('Description:' + char(10) + cf.EventDescription, 4000) EventTranscript,

        (
            select
                pt.PolicyNumber,
                cl.CreateDate,
                cf.EventCountryName,
                pcn.PrimaryClaimant,
                ao.AssessmentOutcome,
                ci.Paid,
                ci.Estimate,
                ccl.Details,
                left(cf.EventDescription, 3600) EventDescription
            for json path, without_array_wrapper
        )
        ClaimTranscript

    into #claim
    from
        #policytransaction pt
        inner join [db-au-cmdwh].dbo.clmClaim cl with(nolock) on
            cl.PolicyTransactionKey = pt.PolicyTransactionKey
        left join [db-au-cmdwh].dbo.clmClaimFlags cf with(nolock) on
            cf.ClaimKey = cl.ClaimKey
        inner join [db-au-cmdwh].dbo.clmEvent ce with(nolock) on
            ce.ClaimKey = cl.ClaimKey
        outer apply
        (
            select 
                sum(ci.IncurredDelta) ClaimValue,
                sum(ci.PaymentDelta) Paid,
                sum(ci.EstimateDelta) Estimate
            from
                [db-au-cmdwh].dbo.vclmClaimIncurred ci with(nolock)
            where
                ci.ClaimKey = cl.ClaimKey
        ) ci
        outer apply
        (
            select top 1 
                cn.Firstname + ' ' + cn.Surname PrimaryClaimant
            from
                [db-au-cmdwh].dbo.clmName cn with(nolock)
                outer apply
                (
                    select
                        sum(cp.PaymentAmount) Paid
                    from
                        [db-au-cmdwh].dbo.clmPayment cp with(nolock)
                    where
                        cp.ClaimKey = cn.ClaimKey and
                        cp.PayeeKey = cn.NameKey and
                        cp.PaymentStatus in ('APPR', 'PAID')
                ) cp
            where
                cn.ClaimKey = cl.ClaimKey and
                isnull(cn.isThirdParty, 0) = 0
            order by
                cp.Paid desc,
                cn.isPrimary desc
                
        ) pcn
        outer apply
        (
            select top 1 
                ao.AssessmentOutcome
            from
                [db-au-cmdwh].[dbo].[vClaimAssessmentOutcome] ao with(nolock)
            where
                ao.ClaimKey = cl.ClaimKey
        ) ao
        outer apply
        (
            select top 1 
                ccl.Details
            from
                [db-au-cmdwh].[dbo].[vEnterpriseClaimClassification] ccl with(nolock)
            where
                ccl.ClaimKey = cl.ClaimKey
        ) ccl
    where
        (
            pt.ProductCode not in (select ProductCode from #basepolicies) --non credit card base policies
            or
            --for credit card base policies, need to have direct link
            exists
            (
                select
                    null
                from
                    [db-au-cmdwh].dbo.entPolicy r
                where
                    r.ClaimKey = cl.ClaimKey and
                    r.CustomerID = pt.CustomerID
            )
        )


    --calls related interactions
    if object_id('tempdb..#calls') is not null
        drop table #calls

    select
        pt.CustomerID,
        pt.PolicyKey,
        convert(date, cmd.LocalStartTime) CallWhen,
        convert(
            varchar(250),
            case
                when charindex(cmd.Phone, pt.ContactPhone) > 1 then 'Agency Call'
                when charindex(pt.ContactPhone, cmd.Phone) > 1 then 'Agency Call'
                else 'Make a call'
            end 
        ) CallWhat,
        convert(
            varchar(250),
            case
                when charindex(cmd.Phone, pt.ContactPhone) > 1 then pt.OutletName
                when charindex(pt.ContactPhone, cmd.Phone) > 1 then pt.OutletName
                else cmd.Phone 
            end 
        ) CallDetail,
        convert(varchar(250), cmd.MetaDataID) CallWhere,
        convert(varchar(4000), isnull(cc.CallComment, '')) CallToolTip,

        cmd.MetaDataID CallID,
        cmd.Duration CallDuration,
        convert(varchar(100), cmd.MetaDataID) SessionKey,
        cast(null as varchar(4000)) Transcript

    into #calls
    from
        #policytransaction pt
        inner join [db-au-cmdwh].dbo.cisCallMetaData cmd with(nolock) on
            cmd.PolicyTransactionKey = pt.PolicyTransactionKey
        outer apply
        (
            select top 1 
                CallComment
            from
                [db-au-cmdwh].dbo.penPolicyAdminCallComment pac with(nolock)
            where
                pac.PolicyKey = pt.PolicyKey and
                pac.CallDate > cmd.LocalStartTime and
                pac.CallDate < dateadd(day, 1,  convert(date, cmd.LocalStartTime))
            order by
                pac.CallDate
        ) cc
    where
        (
            pt.ProductCode not in (select ProductCode from #basepolicies) --non credit card base policies
            or
            --for credit card base policies, need to have direct link
            exists
            (
                select
                    null
                from
                    [db-au-cmdwh].dbo.entPhone r
                where
                    r.CustomerID = pt.CustomerID and
                    r.PhoneNumber = cmd.ForcedAUPhone
            )
        )


    insert into #calls
    select 
        pt.CustomerID,
        pac.PolicyKey,
        convert(date, pac.CallDate) CallWhen,
        'Call Comment' CallWhat,
        'Policy note' CallDetail,
        '' CallWhere,
        isnull(left(pac.CallComment, 4000), '') CallToolTip,

        0 CallID,
        0 CallDuration,
        pac.CallCommentKey,
        
        left(
            'Call date: ' + convert(varchar(20), CallDate, 113) + char(10) +
            'Reason: ' + CallReason + char(10) +
            'Comment: ' + char(10) +
            CallComment, 
            4000
        ) Transcript

    from
        [db-au-cmdwh].dbo.penPolicyAdminCallComment pac with(nolock)
        cross apply
        (
            select distinct
                CustomerID
            from
                #policytransaction pt
            where
                pt.PolicyKey = pac.PolicyKey and
                pt.ProductCode not in (select ProductCode from #basepolicies)
        ) pt
    where
        not exists
        (
            select 
                null
            from
                #calls r
            where
                r.PolicyKey = pac.PolicyKey and
                r.CallWhen = convert(date, pac.CallDate)
        )

    insert into #calls
    select
        ep.CustomerID,
        null PolicyKey,
        convert(date, cmd.LocalStartTime) CallWhen,
        'Make a call' CallWhat,
        cmd.ForcedAUPhone CallDetail,
        convert(varchar(250), cmd.MetaDataID) CallWhere,
        '' CallToolTip,

        cmd.MetaDataID CallID,
        cmd.Duration CallDuration,
        convert(varchar(100), cmd.MetaDataID) SessionKey,
        '' Transcript
    from
        [db-au-cmdwh].dbo.cisCallMetaData cmd with(nolock)
        cross apply
        (
            select distinct
                ep.CustomerID
            from
                [db-au-cmdwh].dbo.entPhone ep with(nolock)
            where
                ep.CustomerID in
                (
                    select 
                        CustomerID 
                    from 
                        @Customer
                ) and
                ep.PhoneNumber = cmd.ForcedAUPhone

        ) ep
    where
        cmd.MetaDataID not in
        (
            select 
                CallID
            from
                #calls
        ) 

    insert into #calls
    select
        CustomerID,
        null PolicyKey,
        convert(date, lc.StartTime) CallWhen,
        'Make a call' CallWhat,
        case
            when ChatType = 'chat' then 'Live chat' 
            when ChatType = 'ticket' then 'Offline message'
            else 'Missed live chat'
        end CallDetail,
        convert(varchar(250), isnull(lc.Country, lc.City)) CallWhere,
        convert
        (
            nvarchar(4000),
            (
                select 
                    lct.Tags + ' '
                from
                    [db-au-cmdwh].dbo.lcLiveChatTags lct with(nolock)
                where
                    lct.ChatID = lc.ChatID
                for xml path('')
            ) 
        ) CallToolTip,

        lc.BIRowID CallID,
        lc.Duration CallDuration,
        lc.ChatID,
        left
        (
            (
                select 
                    convert(varchar(20), EventTime, 113) + ' ' + 
                    isnull(Author, '') + char(9) + 
                    '(' + isnull(EventType, '') + ') ' +
                    replace(isnull(EventText, ''), '\n', char(10)) + char(10)
                from
                    [db-au-cmdwh].dbo.lcLiveChatEvents lce
                where
                    lce.ChatID = lc.ChatID
                order by
                    EventTime
                for xml path('')
            ),
            4000
        ) Transcript

    from
        [db-au-cmdwh].dbo.lcLiveChat lc with(nolock)
    where
        lc.CustomerID in
        (
            select 
                CallID
            from
                #calls
        ) 

    --emc related interactions
    if object_id('tempdb..#emc') is not null
        drop table #emc

    select 
        ea.CustomerID,
        e.ApplicationID,
        e.AssessedDate,
        m.Condition,
        case
            when ConditionStatus = 'Approved' then ea.ApplicationID
            else null
        end ApprovedID,
        case
            when ConditionStatus <> 'Approved' then ea.ApplicationID
            else 0
        end DeniedID,
        MedicalScore,
        e.ApplicationKey
    into #emc
    from
        [db-au-cmdwh].dbo.emcApplicants ea with(nolock)
        inner join [db-au-cmdwh].dbo.emcApplications e with(nolock) on
            e.ApplicationKey = ea.ApplicationKey
        inner join [db-au-cmdwh].dbo.emcMedical m with(nolock) on
            m.ApplicationKey = ea.ApplicationKey
    where
        ea.CustomerID in
        (
            select 
                CustomerID 
            from 
                @Customer
        )
   
    --build the timeline
    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip],
        [Transcript]
    )
    select 
        [CustomerID],
        IssueWhen [When],
        IssueWhat [What],
        IssueDetail [Detail],
        IssueWhere [Where],
        left(IssueTooltip, 4000) Tooltip,
        left(PolicyTranscript, 4000)
    from
        #tlpolicy

    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip]
    )
    select 
        [CustomerID],
        CancelWhen [When],
        CancelWhat [What],
        CancelDetail [Detail],
        CancelWhere [Where],
        left(CancelTooltip, 4000) Tooltip
    from
        #tlpolicy
    where
        CancelWhen is not null

    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip]
    )
    select 
        [CustomerID],
        DepartWhen [When],
        DepartWhat [What],
        DepartDetail [Detail],
        DepartWhere [Where],
        left(DepartTooltip, 4000) Tooltip
    from
        #tlpolicy
    where
        CancelWhen is null or
        CancelWhen > DepartWhen

    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip]
    )
    select 
        [CustomerID],
        ReturnWhen [When],
        ReturnWhat [What],
        ReturnDetail [Detail],
        ReturnWhere [Where],
        left(ReturnTooltip, 4000) Tooltip
    from
        #tlpolicy
    where
        ReturnWhen < getdate() and
        (
            CancelWhen is null or
            CancelWhen > ReturnWhen
        )

    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip],
        [ReferenceID],
        [Transcript]
    )
    select 
        [CustomerID],
        EventWhen [When],
        EventWhat [What],
        EventDetail [Detail],
        EventWhere [Where],
        left(EventTooltip, 4000) Tooltip,
        ClaimKey,
        left(EventTranscript, 4000)
    from
        #claim
    
    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip],
        [Transcript]
    )
    select 
        [CustomerID],
        ClaimWhen [When],
        ClaimWhat [What],
        ClaimDetail [Detail],
        ClaimWhere [Where],
        left(ClaimTooltip, 4000) Tooltip,
        left(ClaimTranscript, 4000)
    from
        #claim

    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip],
        [ReferenceID],
        [Transcript]
    )
    select 
        [CustomerID],
        CallWhen [When],
        CallWhat [What],
        CallDetail [Detail],
        CallWhere [Where],
        left(CallTooltip, 4000) Tooltip,
        SessionKey,
        left(Transcript, 4000)
    from
        #calls t

    --e5 related interactions
    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip]
    )
    select
        cl.CustomerID,
        convert(date, w.CreationDate) e5When,
        case
            when w.WorkType = 'Complaints' then 'E5 Complaint'
            when w.WorkType = 'Correspondence' then 'E5 Corro'
            when w.WorkType = 'Phone Call' then 'E5 Phone'
        end e5What,
        convert(varchar(50), w.Reference) e5Detail,
        '' e5Where,
        '' e5Tooltip
    from
        [db-au-cmdwh].[dbo].e5Work w with(nolock)
        cross apply
        (
            select distinct
                cl.CustomerID
            from
                #claim cl
            where
                cl.ClaimKey = w.ClaimKey
        ) cl
    where
        w.WorkType in ('Complaints', 'Correspondence', 'Phone Call') and
        w.ClaimKey in
        (
            select 
                ClaimKey
            from
                #claim cl
        )

    --carebase related interactions
    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip],
        [ReferenceID],
        [Transcript]
    )
    select 
        cc.CustomerID,
        convert(date, cc.OpenDate) cbWhen,
        'MA Case' cbWhat,
        convert(varchar(50), cc.CaseNo) cbDetail,
        cc.Country cbWhere,
        '' cbTooltip,
        cc.CaseKey,

        left
        (
            'Date: ' + convert(varchar(20), cc.OpenDate, 113) + ' ' + char(10) +
            'Type: ' + cc.CaseType + ' ' + cc.Protocol + char(10) +
			'Incident: ' + isnull(cc.IncidentType, '') + char(10) +
			'Risk: ' + isnull(cc.RiskReason, '') + ' (' + isnull(cc.RiskLevel, '') + ')' + char(10) +
			'UW Cover: ' + isnull(cc.UWCoverStatus, '') + ' E: ' + convert(varchar, isnull(cc.TotalEstimate, 0)) + char(10) +
            'Notes: ' + char(10) +
            isnull(cn.Notes, ''),
            4000
        ) Transcript

    from
        [db-au-cmdwh].[dbo].cbCase cc with(nolock)
		outer apply
		(
			select top 1 
				cn.Notes
			from
				[db-au-cmdwh].[dbo].cbNote cn
			where
				cn.CaseKey = cc.CaseKey and
				cn.NoteCOde = 'CN'
			order by
				cn.CreateDate 
		) cn     
	where
        cc.CustomerID in
        (
            select 
                CustomerID 
            from 
                @Customer
        )


    --carebase related interactions
    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip],
        [ReferenceID],
        [Transcript]
    )
    select 
        pt.CustomerID,
        convert(date, cn.NoteTime) cbWhen,
        case
            when cn.NoteCode = 'TY' then 'MA Thanks'
            when cn.NoteCode = 'CS' then 'MA Complaints'
            else 'MA General' 
        end cbWhat,
        convert(varchar(50), cp.CaseNo) cbDetail,
        'Australia' cbWhere,
        '' cbTooltip,
        NoteKey,

        left
        (
            'Date: ' + convert(varchar(20), NoteTime, 113) + ' ' + char(10) +
            'Type: ' + NoteType + char(10) +
            'Notes: ' + char(10) +
            Notes, 
            4000
        ) Transcript

    from
        [db-au-cmdwh].[dbo].cbPolicy cp with(nolock)
        inner join [db-au-cmdwh].[dbo].cbCase cc with(nolock) on
            cc.CaseKey = cp.CaseKey
        inner join [db-au-cmdwh].[dbo].cbNote cn with(nolock) on
            cn.CaseKey = cp.CaseKey and
            cn.NoteCode in ('EV', 'CB', 'TY', 'ZZ', 'CS', 'CN')
        cross apply
        (
            select distinct
                CustomerID
            from
                #policytransaction pt
            where
                pt.PolicyTransactionKey = cp.PolicyTransactionKey and
                pt.ProductCode not in (select ProductCode from #basepolicies)
        ) pt
    where
        cp.PolicyTransactionKey in
        (
            select 
                PolicyTransactionKey
            from
                #policytransaction pt
            where
                pt.ProductCode not in (select ProductCode from #basepolicies)
        )



    insert into #timeline 
    (
        [CustomerID],
        [When],
        [What],
        [Detail],
        [Where],
        [Tooltip],
        ReferenceID,
        [Transcript]
    )
    select distinct
        CustomerID,
        convert(date, AssessedDate) EMCWhen,
        'EMC Assessment' EMCWhat,
        convert(varchar(50), ApplicationID) EMCDetail,
        'Australia' EMCWhere,
        '' EMCTooltip,
        ApplicationKey,

        left
        (
            (
                select 
                    AlphaCode + ' ' + OutletName + char(10) +
                    ContactStreet + ' ' + ContactSuburb + ' ' + ContactState
                from
                    [db-au-cmdwh].dbo.emcApplications ea with(nolock)
                    left join [db-au-cmdwh].dbo.penOutlet o on
                        o.OutletAlphaKey = ea.OutletAlphaKey and
                        o.OutletStatus = 'Current'
                where
                    ea.ApplicationKey = e.ApplicationKey
            ) + char(10) + char(10) +
            (
                select 
                    'Condition: ' + m.Condition + ' (' + m.ConditionStatus collate database_default + ')' + char(10) +
                    'Answers: ' + char(10) +
                    (
                        select
                            mq.Question + ' ' +
                            mq.Answer + char(10)
                        from
                            [db-au-cmdwh].dbo.emcMedicalQuestions mq with(nolock)
                        where
                            mq.MedicalKey = m.MedicalKey
                        order by 
                            mq.QuestionID
                        for xml path('')
                    ) + char(10)
                from
                    [db-au-cmdwh].dbo.emcMedical m with(nolock)
                where
                    m.ApplicationKey = e.ApplicationKey
                order by
                    m.Condition
                for xml path('')
            ),
            4000
        ) Transcript
    from
        #emc e


    --dummy timeline for profile summary
    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'Premium',
        sum(GrossPremium)
    from
        #policytransaction
    group by
        [CustomerID]

    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'Policy Count',
        count(distinct PolicyKey)
    from
        #tlpolicy
    where
        CancelWhen is null
    group by
        [CustomerID]

    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'Claim Count',
        count(distinct ClaimKey)
    from
        #claim
    group by
        [CustomerID]
        
    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'Claim Value',
        sum(ClaimValue)
    from
        #claim
    group by
        [CustomerID]

    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'Call Count',
        count(distinct CallID)
    from
        #calls
    where
        CallID <> 0
    group by
        [CustomerID]

    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'Call Duration',
        sum(CallDuration / 1000.00)
    from
        #calls
    group by
        [CustomerID]

    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'EMC Assessment',
        count(distinct ApplicationID)
    from
        #emc
    group by
        [CustomerID]

    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Value]
    )
    select 
        [CustomerID],
        'Denied EMC',
        count(distinct DeniedID)
    from
        #emc
    group by
        [CustomerID]

    insert into #timeline 
    (
        [CustomerID],
        [What],
        [Detail],
        [Value]
    )
    select 
        [CustomerID],
        'EMC',
        Condition,
        max(MedicalScore)
    from
        #emc
    group by
        [CustomerID],
        Condition

    --cache timeline
    delete
    from
        [db-au-workspace].[opsupport].[ev_timeline]
    where
        [Who] in 
        (
            select 
                CustomerID 
            from 
                @Customer
        )

    insert into [db-au-workspace].[opsupport].[ev_timeline]
    (
        [Who],
        [When],
        [What],
        [Caption],
        [Where],
        [Detail],
        [Axis],
        [URL],
        [Tooltip],
        [Value],
        [ReferenceID],
        [Transcript]
    )
    select 
        CustomerID [Who],
        [When],
        [What],
        convert
        (
            nvarchar(4000),
            case
                when [What] = 'Bought Policy' then [Detail] + char(10) + 'policy issued'
                when [What] = 'Cancel Policy' then [Detail] + char(10) + 'policy cancelled'
                when [What] = 'Departing' then 'travelled to' + char(10) + [db-au-cmdwh].[dbo].fn_ProperCase([Where])
                when [What] = 'Returning' then 'returned from' + char(10) + [db-au-cmdwh].[dbo].fn_ProperCase([Where])
                when [What] = 'Claim Event' then [Detail] + char(10) + ' event at ' + [db-au-cmdwh].[dbo].fn_ProperCase([Where]) 
                when [What] = 'Make a claim' then [Detail] + char(10) + 'claim registered'
                when [What] = 'Agency call' then ltrim(rtrim([Detail])) + ' called'
                when [What] = 'Make a call' and [Detail] = 'Live Chat' then 'Live Chat'
                when [What] = 'Make a call' and [Detail] = 'Offline message' then 'Offline message'
                when [What] = 'Make a call' and [Detail] = 'Missed live chat' then 'Missed live chat'
                when [What] = 'Make a call' then 'called from ' + [db-au-cmdwh].[dbo].fn_FormatPhone([Detail])
                when [What] = 'Call comment' then isnull([Detail], '')
                when [What] = 'EMC Assessment' then [Detail] + ' emc assessed'
                when [What] = 'MA General' then [Detail] + ' assistance contact'
                when [What] = 'MA Thanks' then [Detail] + ' thank you note'
                when [What] = 'MA Complaints' then [Detail] + ' complaint'
                when [What] = 'E5 Complaint' then [Detail] + ' complaint'
                when [What] = 'E5 Corro' then [Detail] + ' claim corro'
                when [What] = 'E5 Phone' then [Detail] + ' claim call'


                --when [What] = 'Bought Policy' then [Detail]
                --when [What] = 'Departing' then lower([Where])
                --when [What] = 'Claim Event' then lower([Where]) 
                --when [What] = 'Make a call' then 'called from ' + [Detail]
                else ''
            end 
        ) [Caption],
        [Where],
        [Detail],
        convert
        (
            numeric(3,2),
            case
                --when [What] = 'Bought Policy' then 1
                --when [What] = 'Departing' then 1
                --when [What] = 'Returning' then 1
                --when [What] = 'Claim Event' then -1
                --when [What] = 'Make a claim' then -1
                --else 0

                when [What] = 'Bought Policy' then 0.25
                when [What] = 'Cancel Policy' then 0.3
                when [What] = 'Departing' then 0.5
                when [What] = 'Returning' then 0.15
                when [What] = 'Claim Event' then -1
                when [What] = 'Make a claim' then -0.5
                when [What] = 'EMC Assessment' then 0.25
                else 0
            end 
        ) [Axis],
        convert
        (
            nvarchar(max),
            case
                when [What] = 'Bought Policy' then 'https://crm.covermore.com/PolicyAdmin/PolicySummary?PolicyNumber=' + [Detail]
                when [What] = 'Make a claim' then 'https://crm.covermore.com/PolicyAdminMvc/ClaimsSummary/Display?ClaimsNo=' + [Detail]
                when [What] = 'Make a call' and [Detail] <> 'Live Chat' then 'https://bi.covermore.com/EnterpriseView/CISCO/' + [Where] + '.wav'
                when [What] = 'Agency call' then 'https://bi.covermore.com/EnterpriseView/CISCO/' + [Where] + '.wav'

                else 'about:blank'
            end 
        ) [URL],
        isnull(convert(nvarchar(4000), Tooltip), '') [Tooltip],
        convert(numeric(20,2), isnull(Value, 0)) Value,
        [ReferenceID],
        [Transcript]
    from
        #timeline t
    where
        CustomerID in 
        (
            select 
                CustomerID 
            from 
                @Customer
        )

end
GO
