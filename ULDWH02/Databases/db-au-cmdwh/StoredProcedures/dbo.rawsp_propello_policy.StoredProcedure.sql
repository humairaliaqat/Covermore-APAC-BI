USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_propello_policy]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_propello_policy]
    @DateRange varchar(30) = 'Yesterday',
    @StartDate date = null,
    @EndDate date = null

as
begin
--20161101, LL, productionised

    set nocount on

    declare
        @start date,
        @end date

    if @DateRange = '_User Defined' 
        select 
            @start = @StartDate,
            @end = @EndDate
    else
        select 
            @start = StartDate,
            @end = EndDate
        from
            vDateRange
        where
            DateRange = @DateRange

    ;with
    cte_base as
    (
        select --top 1000
            cl.ClaimKey,
            p.PolicyKey,
            p.PolicyNumber,
            p.CountryKey + '-' + p.PolicyNumber [POLICY_ID]
        from
            [db-au-cmdwh].dbo.clmClaim cl with(nolock)
            --deliberate inner join, exclude CMC and PNR as Propello needs customer data
            inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
                pt.PolicyTransactionKey = cl.PolicyTransactionKey
            inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
                p.PolicyKey = pt.PolicyKey
        where
            cl.CountryKey in ('AU','NZ') and
            p.IssueDate >= '2011-07-01' and
            (
                (
                    cl.CreateDate >= @start and
                    cl.CreateDate <  dateadd(day, 1, @end)
                ) 
                --send policy only on claim create date
                --or
                --exists
                --(
                --    select
                --        null
                --    from
                --        [db-au-cmdwh].dbo.clmAuditPayment cap with(nolock)
                --    where
                --        cap.ClaimKey = cl.ClaimKey and
                --        cap.PaymentStatus = 'PAID' and
                --        cap.AuditDateTime >= @start and
                --        cap.AuditDateTime <  dateadd(day, 1, @end)
                --)
            )
    ),
    cte_out as
    (
        select --top 100
            p.CountryKey [COUNTRY],
            b.[POLICY_ID],
            isnull(do.Channel, '') [CHANNEL],
            case
                when o.GroupCode = 'CM' and isnull(do.Channel, '') = 'Website White-Label' then ''
                else isnull(o.GroupName, '') 
            end [AGENCY_GROUP],
            case
                when o.GroupCode = 'CM' and isnull(do.Channel, '') = 'Website White-Label' then ''
                else isnull(pt.Consultant, '')
            end [ISSUING_CONSULTANT],
            case
                when o.GroupCode = 'CM' and isnull(do.Channel, '') = 'Website White-Label' then ''
                else isnull(o.AlphaCode, '') 
            end [AGENCY_ALPHA_CODE],
            replace(p.DomainKey, 'CM-', 'CM') + '-' + convert(varchar, p.ProductID) [PRODUCT_ID],
            p.ProductDisplayName [PRODUCT_DESCRIPTION],
            isnull(ptv.PolicyTravellerKey, '') [INSURED],
            isnull(p.StatusDescription, '') [POLICY_STATUS],
            convert(varchar(10), p.IssueDate, 120) [POLICY_CREATED_DATE],
            isnull(convert(varchar(10), p.CancelledDate, 120), '') [POLICY_CANCEL_DATE],
            convert(varchar(10), p.TripStart, 120) [COVER_START_DATE],
            convert(varchar(10), p.TripEnd, 120) [COVER_END_DATE],
            isnull(p.TripType, '') [TRIP_TYPE],
            isnull(p.AreaName, '') [AREAS_COVERED],
            isnull(p.PrimaryCountry, '') [DESTINATION],
            isnull(ptv.TravellerCount, 0) [NUM_TRAVELLERS],
            p.[EXCESS],
            isnull(pt.SellPrice, 0) [PREMIUM],
            isnull(pt.Commission, 0) [COMMISSION]
        from
            (
                select distinct
                    PolicyKey,
                    [POLICY_ID]
                from
                    cte_base b
            ) b
            inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
                p.PolicyKey = b.PolicyKey
            inner join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
                o.OutletAlphaKey = p.OutletAlphaKey and
                o.OutletStatus = 'Current'
            cross apply
            (
                select 
                    max
                    (
                        case
                            when pt.TransactionType = 'Base' and pt.TransactionStatus = 'Active' then u.FirstName + ' ' + u.LastName
                            else null
                        end
                    ) Consultant,
                    sum(isnull(pt.GrossPremium, 0)) SellPrice,
                    sum(isnull(pt.Commission, 0) + isnull(pt.GrossAdminFee, 0)) Commission
                from
                    [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
                    left join [db-au-cmdwh].dbo.penUser u with(nolock) on
                        u.UserKey = pt.UserKey and
                        u.UserStatus = 'Current'
                where
                    pt.PolicyKey = p.PolicyKey
            ) pt
            outer apply
            (
                select top 1 
                    do.Channel
                from
                    [db-au-star].dbo.dimOutlet do with(nolock)
                where
                    do.OutletAlphaKey = p.OutletAlphaKey and
                    do.isLatest = 'Y'
            ) do
            outer apply
            (
                select 
                    max
                    (
                        case
                            when ptv.isPrimary = 1 then ptv.PolicyTravellerKey
                            else null
                        end
                    ) PolicyTravellerKey,
                    count(ptv.PolicyTravellerKey) TravellerCount
                from
                    [db-au-cmdwh].dbo.penPolicyTraveller ptv with(nolock)
                where
                    ptv.PolicyKey = p.PolicyKey
            ) ptv
    )
    select
        'policy_master_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
        convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
        0 xDataValuex,
        cast('COUNTRY|POLICY_ID|CHANNEL|AGENCY_GROUP|ISSUING_CONSULTANT|AGENCY_ALPHA_CODE|PRODUCT_ID|PRODUCT_DESCRIPTION|INSURED|POLICY_STATUS|POLICY_CREATED_DATE|POLICY_CANCEL_DATE|COVER_START_DATE|COVER_END_DATE|TRIP_TYPE|AREAS_COVERED|DESTINATION|NUM_TRAVELLERS|EXCESS|PREMIUM|COMMISSION' as nvarchar(max)) Data
        
    union all

    select
        'policy_master_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
        [POLICY_ID] xDataIDx,
        0 xDataValuex,
        cast
        (
            isnull([COUNTRY], '') + '|' +
            isnull([POLICY_ID], '') + '|' +
            isnull([CHANNEL], '') + '|' +
            isnull([AGENCY_GROUP], '') + '|' +
            isnull([ISSUING_CONSULTANT], '') + '|' +
            isnull([AGENCY_ALPHA_CODE], '') + '|' +
            isnull([PRODUCT_ID], '') + '|' +
            isnull([PRODUCT_DESCRIPTION], '') + '|' +
            isnull([INSURED], '') + '|' +
            isnull([POLICY_STATUS], '') + '|' +
            isnull([POLICY_CREATED_DATE], '') + '|' +
            isnull([POLICY_CANCEL_DATE], '') + '|' +
            isnull([COVER_START_DATE], '') + '|' +
            isnull([COVER_END_DATE], '') + '|' +
            isnull([TRIP_TYPE], '') + '|' +
            isnull([AREAS_COVERED], '') + '|' +
            isnull([DESTINATION], '') + '|' +
            isnull(convert(varchar(50), [NUM_TRAVELLERS]), '') + '|' +
            isnull(convert(varchar(50), [EXCESS]), '') + '|' +
            isnull(convert(varchar(50), [PREMIUM]), '') + '|' +
            isnull(convert(varchar(50), [COMMISSION]), '') 
            as nvarchar(max)
        ) Data
    from
        cte_out

    --union all

    --select
    --    'policy_master_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
    --    convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
    --    0 xDataValuex,
    --    cast(' ' as nvarchar(max)) Data

end
GO
