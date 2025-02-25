USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0789]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0789]
    @Country varchar(5) = '',
    @ReportingPeriod varchar(30) = 'Last 24 Hours',
    @StartDate date = null,
    @EndDate date = null,
    @CaseNumber varchar(30) = ''

as
begin

--declare 
--    @Country varchar(5),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date,
--    @CaseNumber varchar(30)

--select
--    @Country = 'AU',
--    @ReportingPeriod = 'Last 24 Hours'

    set nocount on


    declare
        @start datetime,
        @end datetime

    if @ReportingPeriod = 'Last 24 Hours' 
    begin

        select
            @start = dateadd(hour, -24, convert(varchar(13), getdate(), 120) + ':00.00'),
            @end = convert(varchar(13), getdate(), 120) + ':00.00'

    end

    else if @ReportingPeriod = '_User Defined' 
    begin

        select
            @start = @StartDate,
            @end = @EndDate

    end

    else
    begin

        select
            @start = StartDate,
            @end = EndDate
        from
            vDateRange t
        where
            DateRange = @ReportingPeriod

    end

    --print @start
    --print @end


    ;with 
    cte_audit as
    (
        select 
            ac.CaseKey,
            ac.CaseNo,
            ac.AuditDateTime,
            ac.AuditAction,
            u.FirstName + ' ' + u.Surname ChangeUser,
            f.RiskReason,
            f.RiskLevel,
            f.TotalEstimate,
            f.Emotion,
            f.UWCoverStatus,
            f.CaseStatus,
            f.Country,
            f.Location,
            checksum
            (
                f.RiskReason,
                f.RiskLevel,
                f.TotalEstimate,
                f.Emotion,
                f.UWCoverStatus,
                f.CaseStatus,
                f.Country,
                f.Location
            ) ChkSum
        from
            cbAuditCase ac
            inner join cbUser u on
                u.UserID = ac.AuditUser
            outer apply
            (
                select top 1 
                    e.Emotion
                from
                    cbEmotion e
                where
                    e.CaseKey = ac.CaseKey and
                    e.EmotionDate < dateadd(second, 1, ac.AuditDateTime)
                order by
                    e.EmotionDate desc
            ) e
            outer apply
            (
                select
                    rtrim(isnull(ac.RiskReason, '')) RiskReason,
                    rtrim(isnull(ac.RiskLevel, '')) RiskLevel,
                    isnull(ac.TotalEstimate, 0) TotalEstimate,
                    rtrim(isnull(e.Emotion, '')) Emotion,
                    rtrim(isnull(ac.UWCoverStatus, '')) UWCoverStatus,
                    rtrim(isnull(ac.CaseStatus, '')) CaseStatus,
                    rtrim(isnull(ac.Country, '')) Country,
                    rtrim(isnull(ac.Location, '')) Location
            ) f
    ),
    cte_changes as
    (
        select 
            a1.CaseKey,
            a1.ChangeUser,
            a1.AuditDateTime,
            a1.AuditAction,
            a2.CaseStatus FromStatus,
            a1.CaseStatus ToStatus,
            a2.Emotion FromEmotion,
            a1.Emotion ToEmotion,
            a2.RiskReason FromReason,
            a2.RiskReason ToReason,
            a2.RiskLevel FromLevel,
            a1.RiskLevel ToLevel,
            a2.TotalEstimate FromEstimate,
            a1.TotalEstimate ToEstimate,
            a1.UWCoverStatus FromUWCover,
            a2.UWCoverStatus ToUWCover,
            a1.Country ToCountry,
            a2.Country FromCountry,
            a1.Location ToLocation,
            a2.Location FromLocation
        from
            cte_audit a1
            cross apply
            (
                select top 1 *
                from
                    cte_audit a2
                where
                    a2.CaseKey = a1.CaseKey and
                    a2.AuditDateTime < a1.AuditDateTime
                order by
                    a2.AuditDateTime desc
            ) a2
        where
            a1.AuditAction <> 'I' and
            (
                (
                    @CaseNumber <> '' and
                    a1.CaseNo = @CaseNumber
                ) or
                (
                    @CaseNumber = '' and
                    a1.AuditDateTime >= @start and
                    a1.AuditDateTime <  dateadd(minute, 1, @end) 
                ) 
            ) and
            a1.ChkSum <> a2.ChkSum
    )
    select 
        cc.CaseKey,
        cc.CaseNo,
        cc.CaseStatus,
        cc.OpenTime,
        cc.Surname,
        cc.ClientName,
        cc.CountryKey Domain,
        ca.ChangeUser,
        ca.AuditDateTime,
        nx.AuditDateTime NextAudit,
        ca.FromStatus,
        ca.ToStatus,
        ca.FromEmotion,
        ca.ToEmotion,
        ca.FromReason,
        ca.ToReason,
        ca.FromLevel,
        ca.ToLevel,
        ca.FromEstimate,
        ca.ToEstimate,
        ca.FromUWCover,
        ca.ToUWCover,
        ca.FromLocation,
        ca.ToLocation,
        ca.FromCountry,
        ca.ToCountry,
        v.*,
        @start StartTime,
        @end EndTime
    from
        cbCase cc
        inner join cte_changes ca on
            ca.CaseKey = cc.CaseKey
        outer apply
        (
            select top 1 
                AuditDateTime
            from
                cte_audit nx
            where
                nx.CaseKey = ca.CaseKey and
                nx.AuditDateTime > ca.AuditDateTime and
                nx.Emotion not in
                (
                    'dissatisfaction - review in one hour',
                    'dissatisfaction - review in progress',
                    'complaint - unresolved',
                    'complaint - unable to resolve'
                ) 
            order by
                nx.AuditDateTime
        ) nx
        outer apply
        (
            select
                case
                    when ca.ToReason = '' then 'Invalid'
                    when lower(ca.ToReason) not in 
                        (
                            'risk: high profile/crisis/medex greater than 200k',
                            'medical case: urgent evacuation',
                            'medical case: death',
                            'medical case: icu/ccu/hdu',
                            'medical case: child under 5yrs - in or outpatient',
                            'medical case: inpatient medex less than 20k',
                            'medical case: inpatient medex greater than 20k',
                            'medical case: outpatient all adults',
                            'technical',
                            'risk: denial/potential denial',
                            'admin: no further assistance required',
                            'safety: missing',
                            'safety: uncontactable',
                            'safety: contactable'
                        ) and
                        lower(ca.ToReason) not like 'medical case: repatriation%'
                    then 'Obsolete'
                    when 
                        lower(ca.ToLevel) like 'very high%' and
                        ca.ToReason in
                        (
                            'risk: high profile/crisis/medex greater than 200k',
                            'medical case: urgent evacuation',
                            'safety: missing'
                        )
                    then 'Valid'
                    when 
                        lower(ca.ToLevel) like 'high%' and
                        (
                            ca.ToReason in
                            (
                                'medical case: death',
                                'medical case: icu/ccu/hdu',
                                'medical case: child under 5yrs - in or outpatient',
                                'medical case: inpatient medex greater than 20k',
                                'risk: denial/potential denial',
                                'safety: uncontactable'
                            ) or
                            ca.ToReason like 'medical case: repatriation%'
                        )
                    then 'Valid'
                    when 
                        lower(ca.ToLevel) like 'medium%' and
                        ca.ToReason in
                        (
                            'medical case: inpatient medex less than 20k',
                            'medical case: outpatient all adults'
                        )
                    then 'Valid'
                    when 
                        lower(ca.ToLevel) like 'low%' and
                        ca.ToReason in
                        (
                            'technical',
                            'admin: no further assistance required',
                            'safety: contactable'
                        )
                    then 'Valid'
                    else 'Invalid'
                end RiskReasonValidity,
                case
                    when ca.ToEmotion = '' then 'Invalid'
                    when lower(ca.ToEmotion) not in
                        (
                            'dissatisfaction - review in one hour',
                            'dissatisfaction - review in progress',
                            'dissatisfaction - resolved',
                            'complaint - unresolved',
                            'complaint - resolved',
                            'complaint - unable to resolve',
                            'compliment',
                            'satisfied',
                            'testimonial'
                        )
                    then 'Obsolete'
                    when lower(ca.ToEmotion) in
                        (
                            'compliment',
                            'satisfied',
                            'testimonial'
                        )
                    then 'Valid'
                    when
                        lower(ca.ToLevel) like 'very high%' and
                        lower(ca.ToEmotion) in
                        (
                            'dissatisfaction - review in one hour',
                            'complaint - unresolved'
                        )
                    then 'Valid'
                    when
                        lower(ca.ToLevel) like 'high%' and
                        lower(ca.ToEmotion) in
                        (
                            'dissatisfaction - review in progress',
                            'complaint - resolved'
                        )
                    then 'Valid'
                    when
                        lower(ca.ToLevel) like 'medium%' and
                        lower(ca.ToEmotion) in
                        (
                            'complaint - unable to resolve'
                        )
                    then 'Valid'
                    when
                        lower(ca.ToLevel) like 'low%' and
                        lower(ca.ToEmotion) in
                        (
                            'dissatisfaction - resolved'
                        )
                    then 'Valid'
                    else 'Invalid'
                end EmotionRiskValidity,
                case
                    when lower(ca.FromEmotion) = lower(ca.ToEmotion) then 'Valid'
                    when 
                        lower(ca.FromEmotion) not in
                        (
                            'compliment',
                            'satisfied'
                        ) then 'Valid'
                    when 
                        lower(ca.FromEmotion) in
                        (
                            'compliment',
                            'satisfied'
                        ) and
                        lower(ca.ToEmotion) in
                        (
                            'dissatisfaction - review in one hour',
                            'dissatisfaction - review in progress',
                            'complaint - unresolved',
                            'complaint - unable to resolve'
                        ) 
                    then
                        case
                            when datediff(hour, ca.AuditDateTime, isnull(nx.AuditDateTime, getdate())) >= 24 then 'Invalid'
                            else 'In progress'
                        end
                    else 'Valid'
                end EmotionChangeValidity,
                case
                    when lower(ca.ToStatus) <> 'closed' then 'Valid'
                    when 
                        lower(ca.FromStatus) <> 'closed' and
                        lower(ca.ToStatus) = 'closed' and
                        lower(ca.ToEmotion) in
                        (
                            'dissatisfaction - review in one hour',
                            'dissatisfaction - review in progress',
                            'complaint - unresolved'
                        )
                    then 'Invalid'
                    else 'Valid'
                end StatusChangeValidity,
                case
                    when ToLocation = '' then 'Invalid'
                    when ToCountry = '' then 'Invalid'
                    else 'Valid'
                end LocationValidity
        ) v
    order by 
        cc.CaseNo,
        ca.AuditDateTime

end
GO
