USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_EnterpriseTimeline]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec rptsp_EnterpriseTimeline 22765


CREATE procedure [dbo].[rptsp_EnterpriseTimeline]
    @CID varchar(max),
    @LogUser varchar(max) = ''

as
begin

declare @CustomerID bigint --= 1582293

set @CustomerID = try_convert(bigint, @CID)
    

    set nocount on


    --can't find this one yet, it keeps calling Katrine Hermansen
    if @CID = '22765' and @LogUser = '' 
    begin

        set @CID = '0'
        set @CustomerID = 0

    end

    if object_id('tempdb..#timeline') is not null
        drop table #timeline

    create table #timeline
        (
            [When] date,
            [What] varchar(14),
            [Detail] nvarchar(70),
            [Where] nvarchar(max),
            Tooltip varchar(4000),
            ReferenceID varchar(100),
            Value float
        )

    if rtrim(isnull(@CID, '')) <> '' and @CustomerID <> 0
    begin

        if object_id('entActionLog') is null
        begin
        
            create table entActionLog
            (
                BIRowID bigint not null identity(1,1),
                LogTime datetime,
                UserName varchar(max),
                Calls varchar(max),
                Reference varchar(max)
            )

            create unique clustered index cidx on entActionLog (BIRowID)

        end

        insert into entActionLog
        (
            LogTime,
            UserName,
            Calls,
            Reference
        )
        select
            getdate(),
            @LogUser,
            'rptsp_EnterpriseTimeline',
            @CID


        if object_id('tempdb..#policy') is not null
            drop table #policy

        select 
            PolicyKey,
        
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
            '' ReturnTooltip

        into #policy
        from
            penPolicy p with(nolock)
        where
            p.PolicyKey in
            (
                select 
                    PolicyKey
                from
                    entPolicy ep with(nolock)
                where
                    ep.CustomerID = @CustomerID
            )


        if object_id('tempdb..#policytransaction') is not null
            drop table #policytransaction

        select 
            pt.PolicyKey,
            pt.PolicyTransactionKey,
            p.ReturnWhen,
            o.ContactPhone,
            o.OutletName,
            pt.NewPolicyCount,
            pt.GrossPremium
        into #policytransaction
        from
            #policy p
            inner join penPolicyTransSummary pt with(nolock) on
                pt.PolicyKey = p.PolicyKey
            inner join penOutlet o with(nolock) on
                o.OutletStatus = 'Current' and
                o.OutletAlphaKey = pt.OutletAlphaKey 


        if object_id('tempdb..#claim') is not null
            drop table #claim

        select 
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
            cl.ClaimKey
        into #claim
        from
            #policytransaction pt
            inner join clmClaim cl with(nolock) on
                cl.PolicyTransactionKey = pt.PolicyTransactionKey
            inner join clmEvent ce with(nolock) on
                ce.ClaimKey = cl.ClaimKey
            outer apply
            (
                select 
                    sum(ci.IncurredDelta) ClaimValue
                from
                    vclmClaimIncurred ci with(nolock)
                where
                    ci.ClaimKey = cl.ClaimKey
            ) ci


        if object_id('tempdb..#calls') is not null
            drop table #calls

        select
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
            convert(varchar(max), isnull(cc.CallComment, '')) CallToolTip,

            cmd.MetaDataID CallID,
            cmd.Duration CallDuration,
            convert(varchar(100), cmd.MetaDataID) SessionKey
        into #calls
        from
            #policytransaction pt
            inner join cisCallMetaData cmd with(nolock) on
                cmd.PolicyTransactionKey = pt.PolicyTransactionKey
            outer apply
            (
                select top 1 
                    CallComment
                from
                    penPolicyAdminCallComment pac with(nolock)
                where
                    pac.PolicyKey = pt.PolicyKey and
                    pac.CallDate > cmd.LocalStartTime and
                    pac.CallDate < dateadd(day, 1,  convert(date, cmd.LocalStartTime))
                order by
                    pac.CallDate
            ) cc

        insert into #calls
        select 
            pac.PolicyKey,
            convert(date, pac.CallDate) CallWhen,
            'Call Comment' CallWhat,
            'Policy note' CallDetail,
            '' CallWhere,
            isnull(pac.CallComment, '') CallToolTip,

            0 CallID,
            0 CallDuration,
            pac.CallCommentKey
        from
            penPolicyAdminCallComment pac
        where
            pac.PolicyKey in
            (
                select
                    PolicyKey
                from
                    #policytransaction pt
            ) and
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
            null PolicyKey,
            convert(date, cmd.LocalStartTime) CallWhen,
            'Make a call' CallWhat,
            cmd.ForcedAUPhone CallDetail,
            convert(varchar(250), cmd.MetaDataID) CallWhere,
            '' CallToolTip,

            cmd.MetaDataID CallID,
            cmd.Duration CallDuration,
            convert(varchar(100), cmd.MetaDataID) SessionKey
        from
            cisCallMetaData cmd
        where
            cmd.ForcedAUPhone in
            (
                select 
                    ep.PhoneNumber
                from
                    entPhone ep
                where
                    ep.CustomerID = @CustomerID
            ) and
            cmd.MetaDataID not in
            (
                select 
                    CallID
                from
                    #calls
            ) 

        insert into #calls
        select
            null PolicyKey,
            convert(date, lc.StartTime) CallWhen,
            'Make a call' CallWhat,
            case
                when ChatType = 'chat' then 'Live chat' 
                when ChatType = 'ticket' then 'Offline message'
                else 'Missed live chat'
            end CallDetail,
            convert(varchar(250), isnull(lc.Country, lc.City)) CallWhere,
            (
                select 
                    lct.Tags + ' '
                from
                    lcLiveChatTags lct 
                where
                    lct.ChatID = lc.ChatID
                for xml path('')
            ) CallToolTip,

            lc.BIRowID CallID,
            lc.Duration CallDuration,
            lc.ChatID
        from
            lcLiveChat lc
        where
            lc.CustomerID = @CustomerID


        if object_id('tempdb..#emc') is not null
            drop table #emc

        select 
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
            emcApplicants ea with(nolock)
            inner join emcApplications e with(nolock) on
                e.ApplicationKey = ea.ApplicationKey
            inner join emcMedical m with(nolock) on
                m.ApplicationKey = ea.ApplicationKey
        where
            ea.CustomerID = @CustomerID
   



        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip]
        )
        select 
            IssueWhen [When],
            IssueWhat [What],
            IssueDetail [Detail],
            IssueWhere [Where],
            left(IssueTooltip, 4000) Tooltip
        from
            #policy

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip]
        )
        select 
            CancelWhen [When],
            CancelWhat [What],
            CancelDetail [Detail],
            CancelWhere [Where],
            left(CancelTooltip, 4000) Tooltip
        from
            #policy
        where
            CancelWhen is not null

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip]
        )
        select 
            DepartWhen [When],
            DepartWhat [What],
            DepartDetail [Detail],
            DepartWhere [Where],
            left(DepartTooltip, 4000) Tooltip
        from
            #policy
        where
            CancelWhen is null or
            CancelWhen > DepartWhen

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip]
        )
        select 
            ReturnWhen [When],
            ReturnWhat [What],
            ReturnDetail [Detail],
            ReturnWhere [Where],
            left(ReturnTooltip, 4000) Tooltip
        from
            #policy
        where
            ReturnWhen < getdate() and
            (
                CancelWhen is null or
                CancelWhen > ReturnWhen
            )

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip],
            [ReferenceID]
        )
        select 
            EventWhen [When],
            EventWhat [What],
            EventDetail [Detail],
            EventWhere [Where],
            left(EventTooltip, 4000) Tooltip,
            ClaimKey
        from
            #claim
    
        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip]
        )
        select 
            ClaimWhen [When],
            ClaimWhat [What],
            ClaimDetail [Detail],
            ClaimWhere [Where],
            left(ClaimTooltip, 4000) Tooltip
        from
            #claim

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip],
            [ReferenceID]
        )
        select 
            CallWhen [When],
            CallWhat [What],
            CallDetail [Detail],
            CallWhere [Where],
            left(CallTooltip, 4000) Tooltip,
            SessionKey
        from
            #calls t

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip]
        )
        select
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
            e5Work w with(nolock)
        where
            w.WorkType in ('Complaints', 'Correspondence', 'Phone Call') and
            w.ClaimKey in
            (
                select 
                    ClaimKey
                from
                    #claim
            )

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip],
            [ReferenceID]
        )
        select 
            convert(date, cn.NoteTime) cbWhen,
            case
                when cn.NoteCode = 'TY' then 'MA Thanks'
                when cn.NoteCode = 'CS' then 'MA Complaints'
                else 'MA General' 
            end cbWhat,
            convert(varchar(50), cp.CaseNo) cbDetail,
            'Australia' cbWhere,
            '' cbTooltip,
            NoteKey
        from
            cbPolicy cp with(nolock)
            inner join cbNote cn with(nolock) on
                cn.CaseKey = cp.CaseKey and
                cn.NoteCode in ('EV', 'CB', 'TY', 'ZZ', 'CS', 'CN')
        where
            cp.PolicyTransactionKey in
            (
                select 
                    PolicyTransactionKey
                from
                    #policytransaction
            )

        insert into #timeline 
        (
            [When],
            [What],
            [Detail],
            [Where],
            [Tooltip],
            ReferenceID
        )
        select distinct
            convert(date, AssessedDate) EMCWhen,
            'EMC Assessment' EMCWhat,
            convert(varchar(50), ApplicationID) EMCDetail,
            'Australia' EMCWhere,
            '' EMCTooltip,
            ApplicationKey
        from
            #emc


        --dummy timeline for profile summary
        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'Premium',
            sum(GrossPremium)
        from
            #policytransaction

        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'Policy Count',
            count(distinct PolicyKey)
        from
            #policy
        where
            CancelWhen is null

        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'Claim Count',
            count(distinct ClaimKey)
        from
            #claim
        
        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'Claim Value',
            sum(ClaimValue)
        from
            #claim

        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'Call Count',
            count(distinct CallID)
        from
            #calls
        where
            CallID <> 0

        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'Call Duration',
            CallDuration / 1000
        from
            #calls

        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'EMC Assessment',
            count(distinct ApplicationID)
        from
            #emc

        insert into #timeline 
        (
            [What],
            [Value]
        )
        select 
            'Denied EMC',
            count(distinct DeniedID)
        from
            #emc

        insert into #timeline 
        (
            [What],
            [Detail],
            [Value]
        )
        select 
            'EMC',
            Condition,
            max(MedicalScore)
        from
            #emc
        group by
            Condition

    end
    --drop table #test
    
    select 
        @CustomerID [Who],
        [When],
        [What],
        convert
        (
            nvarchar(4000),
            case
                when [What] = 'Bought Policy' then [Detail] + char(10) + 'policy issued'
                when [What] = 'Cancel Policy' then [Detail] + char(10) + 'policy cancelled'
                when [What] = 'Departing' then 'departed to' + char(10) + dbo.fn_ProperCase([Where])
                when [What] = 'Returning' then 'returned from' + char(10) + dbo.fn_ProperCase([Where])
                when [What] = 'Claim Event' then [Detail] + char(10) + ' event at ' + dbo.fn_ProperCase([Where]) 
                when [What] = 'Make a claim' then [Detail] + char(10) + 'claim registered'
                when [What] = 'Agency call' then ltrim(rtrim([Detail])) + ' called'
                when [What] = 'Make a call' and [Detail] = 'Live Chat' then 'Live Chat'
                when [What] = 'Make a call' and [Detail] = 'Offline message' then 'Offline message'
                when [What] = 'Make a call' and [Detail] = 'Missed live chat' then 'Missed live chat'
                when [What] = 'Make a call' then 'called from ' + dbo.fn_FormatPhone([Detail])
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
        isnull(convert(nvarchar(max), Tooltip), '') [Tooltip],
        convert(numeric(20,2), isnull(Value, 0)) Value,
        [ReferenceID]
    --into #test
    from
        #timeline t


end



--select *
--from
--    #calls
GO
