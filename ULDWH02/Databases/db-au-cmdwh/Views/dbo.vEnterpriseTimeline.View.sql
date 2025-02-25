USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vEnterpriseTimeline]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vEnterpriseTimeline] as
select distinct 
    [Who],
    [When],
    [What],
    case
        when [What] = 'Bought Policy' then [Detail] + char(10) + 'policy issued'
        when [What] = 'Cancel Policy' then [Detail] + char(10) + 'policy cancelled'
        when [What] = 'Departing' then 'departed to' + char(10) + dbo.fn_ProperCase([Where])
        when [What] = 'Returning' then 'returned from' + char(10) + dbo.fn_ProperCase([Where])
        when [What] = 'Claim Event' then [Detail] + char(10) + ' event at ' + dbo.fn_ProperCase([Where]) 
        when [What] = 'Make a claim' then [Detail] + char(10) + 'claim registered'
        when [What] = 'Agency call' then ltrim(rtrim([Detail])) + ' called'
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
    end [Caption],
    [Where],
    [Detail],
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
    end [Axis],
    case
        when [What] = 'Bought Policy' then 'https://crm.covermore.com/PolicyAdmin/PolicySummary?PolicyNumber=' + [Detail]
        when [What] = 'Make a claim' then 'https://crm.covermore.com/PolicyAdminMvc/ClaimsSummary/Display?ClaimsNo=' + [Detail]
        when [What] = 'Make a call' then 'https://bi.covermore.com/EnterpriseView/CISCO/' + [Where] + '.wav'
        when [What] = 'Agency call' then 'https://bi.covermore.com/EnterpriseView/CISCO/' + [Where] + '.wav'

        else 'about:blank'
    end [URL],
    isnull(Tooltip, '') [Tooltip]
from
    (
        --buy policy
        select 
            ep.CustomerID [Who],
            convert(date, p.IssueDate) [When],
            'Bought Policy' [What],
            p.PolicyNumber [Detail],
            'Australia' [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicy p with(nolock) on
                p.PolicyKey = ep.PolicyKey

        union --all

        --buy policy
        select 
            ep.CustomerID [Who],
            convert(date, p.CancelledDate) [When],
            'Cancel Policy' [What],
            p.PolicyNumber [Detail],
            'Australia' [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicy p with(nolock) on
                p.PolicyKey = ep.PolicyKey
        where
            p.CancelledDate is not null

        union --all

        --travel
        select 
            ep.CustomerID [Who],
            convert(date, p.TripStart) [When],
            'Departing' [What],
            p.PolicyNumber [Detail],
            PrimaryCountry [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicy p with(nolock) on
                p.PolicyKey = ep.PolicyKey
        where
            p.CancelledDate is null
            --p.StatusDescription = 'Active' or
            --p.CancelledDate >= convert(date, dateadd(day, 1, p.TripStart))

        union --all

        --travel
        select 
            ep.CustomerID [Who],
            convert(date, p.TripEnd) [When],
            'Returning' [What],
            p.PolicyNumber [Detail],
            PrimaryCountry [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicy p with(nolock) on
                p.PolicyKey = ep.PolicyKey
        where
            p.CancelledDate is null and
            p.CancelledDate < getdate()
            --p.StatusDescription = 'Active' or
            --p.CancelledDate >= convert(date, dateadd(day, 1, p.TripStart))

        union --all

        --event
        select 
            ep.CustomerID [Who],
            convert(date, ce.EventDate) [When],
            'Claim Event' [What],
            convert(varchar(50), cl.CLaimNo) [Detail],
            ce.EventCountryName [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicyTransSummary pt with(nolock) on
                pt.PolicyKey = ep.PolicyKey
            inner join clmClaim cl with(nolock) on
                cl.PolicyTransactionKey = pt.PolicyTransactionKey
            inner join clmEvent ce with(nolock) on
                ce.ClaimKey = cl.ClaimKey

        union --all

        --claim
        select 
            ep.CustomerID [Who],
            convert(date, cl.CreateDate) [When],
            'Make a claim' [What],
            convert(varchar(50), cl.CLaimNo) [Detail],
            case
                when cl.CreateDate > p.TripEnd then 'Australia'
                when cl.OnlineClaim = 1 then ce.EventCountryName
                else 'Australia' 
            end [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicy p with(nolock) on
                p.PolicyKey = ep.PolicyKey
            inner join penPolicyTransSummary pt with(nolock) on
                pt.PolicyKey = ep.PolicyKey
            inner join clmClaim cl with(nolock) on
                cl.PolicyTransactionKey = pt.PolicyTransactionKey
            inner join clmEvent ce with(nolock) on
                ce.ClaimKey = cl.ClaimKey

        union --all

        select
            ep.CustomerID [Who],
            convert(date, cmd.LocalStartTime) [When],
            case
                when charindex(cmd.Phone, o.ContactPhone) > 1 then 'Agency Call'
                when charindex(o.ContactPhone, cmd.Phone) > 1 then 'Agency Call'
                else 'Make a call'
            end [What],
            case
                when charindex(cmd.Phone, o.ContactPhone) > 1 then o.OutletName
                when charindex(o.ContactPhone, cmd.Phone) > 1 then o.OutletName
                else cmd.Phone 
            end [Detail],
            convert(varchar, cmd.MetaDataID) [Where],
            isnull(cc.CallComment, '') ToolTip
        from
            entPolicy ep with(nolock)
            inner join penPolicyTransSummary pt with(nolock) on
                pt.PolicyKey = ep.PolicyKey
            inner join [db-au-cmdwh]..cisCallMetaData cmd with(nolock) on
                cmd.PolicyTransactionKey = pt.PolicyTransactionKey
            outer apply
            (
                select top 1 
                    o.ContactPhone,
                    o.OutletName
                from
                    [db-au-cmdwh]..penOutlet o
                where
                    o.OutletStatus = 'Current' and
                    o.OutletAlphaKey = pt.OutletAlphaKey 
            ) o
            outer apply
            (
                select top 1 
                    CallComment
                from
                    penPolicyAdminCallComment pac with(nolock)
                where
                    pac.PolicyKey = ep.PolicyKey and
                    pac.CallDate > cmd.LocalStartTime and
                    pac.CallDate < dateadd(day, 1,  convert(date, cmd.LocalStartTime))
                order by
                    pac.CallDate
            ) cc

        union

        select 
            ep.CustomerID [Who],
            convert(date, pac.CallDate) [When],
            'Call Comment' [What],
            'Policy note' [Detail],
            '' [Where],
            isnull(pac.CallComment, '') ToolTip
        from
            entPolicy ep with(nolock)
            inner join penPolicyAdminCallComment pac with(nolock) on
                pac.PolicyKey = ep.PolicyKey
        where
            not exists
            (
                select 
                    null
                from
                    penPolicyTransSummary pt with(nolock)
                    inner join [db-au-cmdwh]..cisCallMetaData cmd with(nolock) on
                        cmd.PolicyTransactionKey = pt.PolicyTransactionKey
                where
                    pt.PolicyKey = ep.PolicyKey and
                    cmd.LocalStartTime >= convert(date, pac.CallDate) and
                    cmd.LocalStartTime < pac.CallDate
            ) 

        union

        select 
            ec.CustomerID [Who],
            convert(date, emc.AssessedDate) [When],
            'EMC Assessment' [What],
            convert(varchar(50), emc.ApplicationID) [Detail],
            'Australia' [Where],
            '' Tooltip
        from
            entCustomer ec with(nolock)
            cross apply
            (
                select 
                    e.AssessedDate,
                    e.ApplicationID
                from
                    emcApplicants ea with(nolock,index(idx_emcApplicants_RelaxedApplicantHash))
                    inner join emcApplications e with(nolock) on
                        e.ApplicationKey = ea.ApplicationKey
                where
                    RelaxedApplicantHash in
                    (
                        select --top 1
                            ea.RelaxedApplicantHash
                        from
                            entPolicy ep with(nolock)
                            inner join penPolicyTraveller ptv with(nolock,index(idx_penPolicyTraveller_PolicyKeyTraveller)) on
                                ptv.PolicyKey = ep.PolicyKey and
                                ptv.FirstName = ec.FirstName
                            inner join penPolicyTravellerTransaction ptt with(nolock) on
                                ptt.PolicyTravellerKey = ptv.PolicyTravellerKey
                            inner join penPolicyEMC pe with(nolock) on
                                pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
                            inner join emcApplicants ea with(nolock) on
                                ea.ApplicationKey = pe.EMCApplicationKey
                        where
                            ep.CustomerID = ec.CustomerID
                    )
            ) emc

        union

        --carebase
        select --top 100 
            ep.CustomerID [Who],
            convert(date, cn.NoteTime) [When],
            case
                when cn.NoteCode = 'TY' then 'MA Thanks'
                when cn.NoteCode = 'CS' then 'MA Complaints'
                else 'MA General' 
            end [What],
            convert(varchar(50), cp.CaseNo) [Detail],
            case
                when 1 = 0 then ''
                else 'Australia' 
            end [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicyTransSummary pt with(nolock) on
                pt.PolicyKey = ep.PolicyKey
            inner join cbPolicy cp with(nolock) on
                cp.PolicyTransactionKey = pt.PolicyTransactionKey
            --inner join cbCase cc with(nolock) on
            --    cc.CaseKey = cp.CaseKey
            inner join cbNote cn with(nolock) on
                cn.CaseKey = cp.CaseKey and
                cn.NoteCode in ('EV', 'CB', 'TY', 'ZZ', 'CS', 'CN')

        union

        --e5
        select --top 1000
            ep.CustomerID [Who],
            convert(date, w.CreationDate) [When],
            case
                when w.WorkType = 'Complaints' then 'E5 Complaint'
                when w.WorkType = 'Correspondence' then 'E5 Corro'
                when w.WorkType = 'Phone Call' then 'E5 Phone'
            end [What],
            convert(varchar(50), w.Reference) [Detail],
            '' [Where],
            '' Tooltip
        from
            entPolicy ep with(nolock)
            inner join penPolicyTransSummary pt with(nolock) on
                pt.PolicyKey = ep.PolicyKey
            inner join clmClaim cl with(nolock) on
                cl.PolicyTransactionKey = pt.PolicyTransactionKey
            inner join e5Work w with(nolock) on
                w.ClaimKey = cl.ClaimKey
        where
            w.WorkType in ('Complaints', 'Correspondence', 'Phone Call')

    ) t

--where
--    [Who] = 852064
--order by 2






GO
