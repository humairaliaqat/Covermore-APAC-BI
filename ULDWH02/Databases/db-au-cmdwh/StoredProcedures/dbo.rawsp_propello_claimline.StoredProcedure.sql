USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_propello_claimline]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_propello_claimline]
    @DateRange varchar(30) = 'Yesterday',
    @StartDate date = null,
    @EndDate date = null,
    @Type varchar(10) = 'New'

as
begin
--20161101, LL, productionised
--20170127, LL, include all sections in NEW file

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
            --cl.claimno = 922649 and
            p.IssueDate >= '2011-07-01' and
            (
                (
                    @Type = 'New' and
                    cl.CreateDate >= @start and
                    cl.CreateDate <  dateadd(day, 1, @end)
                ) 
                or
                (
                    @Type = 'Delta' and
                    exists
                    (
                        select
                            null
                        from
                            [db-au-cmdwh].dbo.clmAuditPayment cap with(nolock)
                        where
                            cap.ClaimKey = cl.ClaimKey and
                            cap.PaymentStatus in ('PAID', 'RECY') and
                            cap.AuditDateTime >= @start and
                            cap.AuditDateTime <  dateadd(day, 1, @end)
                    )
                )
            )
    ),
    cte_out as
    (
        select --top 100 
            cl.CountryKey [COUNTRY],
            cl.ClaimNo [CLAIM_ID],
            isnull(cs.EventID, '') [EVENT_ID],
            isnull(cp.SectionID, '') [SECTION_ID],
            isnull(cp.PaymentID, '') [PAYMENT_ID],
            isnull(cp.ChequeNo, '') [PAYMENT_REFERENCE],
            isnull(cs.SectionDescription, '') [CATEGORY],
            case
                when cp.PaymentKey is null then isnull(csi.FirstEstimate, 0)
                when cp.PaymentID = min(PaymentID) over (partition by cp.SectionID) then isnull(csi.FirstEstimate, 0)
                else 0
            end [CLAIM_LINE_AMOUNT],
            isnull(cp.ExcessAmount, 0) [EXCESS],
            isnull(cp.PaymentAmount, 0) [TOTAL_PAID],
            convert(varchar(10), cp.ModifiedDate, 120) [PAYMENT_DATE],
            isnull(PaymentMethod , '') [PAYMENT_METHOD],
            cn.AccountName [ACCOUNT_NAME],
            isnull(convert(varchar(250), [db-au-stage].dbo.sysfn_DecryptClaimsString(cn.EncryptBSB)) + ' ', '') +
            isnull(convert(varchar(250), [db-au-stage].dbo.sysfn_DecryptClaimsString(cn.EncryptAccount)), '') [ACCOUNT]
        from
            cte_base b
            inner join [db-au-cmdwh].dbo.clmClaim cl with(nolock) on
                cl.ClaimKey = b.ClaimKey
            inner join [db-au-cmdwh].dbo.clmSection cs with(nolock) on
                cs.ClaimKey = cl.ClaimKey
            left join [db-au-cmdwh].dbo.clmPayment cp with(nolock) on
                cp.ClaimKey = cl.ClaimKey and
                cp.SectionKey = cs.SectionKey and
                cp.PaymentStatus in ('PAID', 'RECY')
            outer apply
            (
                select
                    sum(isnull(csi.FirstEstimate, 0)) FirstEstimate
                from
                    (
                        select 
                            case
                                when csi.IncurredTime = min(csi.IncurredTime) over (partition by csi.SectionKey) then EstimateDelta
                                else 0
                            end FirstEstimate
                        from
                            [db-au-cmdwh].dbo.vclmClaimSectionIncurredIntraDay csi with(nolock)
                        where
                            csi.SectionKey = cs.SectionKey 
                    ) csi
            ) csi
            outer apply
            (
                select top 1 
                    pb.PaymentMethod
                from
                    [db-au-cmdwh].dbo.clmPaymentBatch pb with(nolock)
                where
                    cp.CountryKey = pb.CountryKey and
                    cp.PaymentID = pb.PaymentID
            ) pb
            outer apply
            (
                select top 1 *
                from
                    [db-au-cmdwh].dbo.clmName cn with(nolock)
                where
                    cn.NameKey = cp.PayeeKey
            ) cn
        where
            (
                @Type = 'New' or
                (
                    @Type = 'Delta' and
                    cp.PaymentKey is not null
                )
            )
    )
    select
        case
            when @Type = 'New' then 'claim_line_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
            else 'delta_claim_line_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
        end xOutputFileNamex,
        convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
        0 xDataValuex,
        cast('COUNTRY|CLAIM_ID|EVENT_ID|SECTION_ID|PAYMENT_ID|PAYMENT_REFERENCE|CATEGORY|CLAIM_LINE_AMOUNT|EXCESS|TOTAL_PAID|PAYMENT_DATE|PAYMENT_METHOD|ACCOUNT_NAME|ACCOUNT' as nvarchar(max)) Data
        
    union all

    select
        'claim_line_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' xOutputFileNamex,
        isnull(convert(varchar(50), [CLAIM_ID]), '') + '-' + isnull(convert(varchar(50), [PAYMENT_ID]), '') xDataIDx,
        0 xDataValuex,
        cast
        (
            isnull([COUNTRY], '') + '|' +
            isnull(convert(varchar(50), [CLAIM_ID]), '') + '|' +
            isnull(convert(varchar(50), [EVENT_ID]), '') + '|' +
            isnull(convert(varchar(50), [SECTION_ID]), '') + '|' +
            isnull(convert(varchar(50), [PAYMENT_ID]), '') + '|' +
            isnull(convert(varchar(50), [PAYMENT_REFERENCE]), '') + '|' +
            isnull([CATEGORY], '') + '|' +
            isnull(convert(varchar(50), [CLAIM_LINE_AMOUNT]), '') + '|' +
            isnull(convert(varchar(50), [EXCESS]), '') + '|' +
            isnull(convert(varchar(50), [TOTAL_PAID]), '') + '|' +
            isnull([PAYMENT_DATE], '') + '|' +
            isnull([PAYMENT_METHOD], '') + '|' +
            isnull([ACCOUNT_NAME], '') + '|' +
            isnull([ACCOUNT], '') 
            as nvarchar(max)
        ) Data
    from
        cte_out

    --union all

    --select
    --    case
    --        when @Type = 'New' then 'claim_line_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
    --        else 'delta_claim_line_' + replace(convert(varchar(10), getdate(), 120), '-', '') + '.txt' 
    --    end xOutputFileNamex,
    --    convert(varchar(10), @start, 120) + '_' + convert(varchar(10), @end, 120) xDataIDx,
    --    0 xDataValuex,
    --    nchar(0xFEFF) Data

end
GO
