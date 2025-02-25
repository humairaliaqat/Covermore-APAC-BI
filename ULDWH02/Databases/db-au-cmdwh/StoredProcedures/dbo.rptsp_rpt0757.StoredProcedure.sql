USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0757]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0757] 
@Country nvarchar(5),
@ReportingPeriod varchar(30),
@StartDate date,
@EndDate date,
@e5claimtype nvarchar(255)

as
begin




--  Change History: 20160414 - PZ - Created, INC0007062




--uncomment to debug
--declare 
--    @Country nvarchar(5),
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date,
--	@e5claimtype nvarchar(255)
--select 
--    @Country = 'AU',
--    @ReportingPeriod = 'Current Fiscal Year', 
--    @StartDate = null, 
--    @EndDate = null,
--	@e5claimtype = 'LiveCanxClaim'


set nocount on
                                    
declare 
    @rptStartDate datetime,
    @rptEndDate datetime

--get reporting dates
if @ReportingPeriod = '_User Defined'
    select 
        @rptStartDate = @StartDate,
        @rptEndDate = @EndDate

else
    select 
        @rptStartDate = StartDate, 
        @rptEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @ReportingPeriod

----------------------------------------------

select
cl.CountryKey as [Country],
cl.ClaimNo,
pts.PolicyNumber,
isnull(ep.[Current Estimate],0) as [Current Estimate],
isnull(ep.[Total Paid],0) as [Total Paid],
isnull(ep.[Current Estimate],0) + isnull(ep.[Total Paid],0) as [Total Incurred],
n.Title + ' ' + n.Firstname + ' ' + n.Surname as [Customer Name],
crd.ReceiptDate as [Received Date],
case
    when w.[Claim Status] = 'Complete' then datediff(day, crd.ReceiptDate, isnull(convert(date, w.CompletionDate), getdate())) 
    else datediff(day, crd.ReceiptDate, convert(date, getdate()))
end as [Total Cycle Time],
@rptStartDate as [StartDate],
@rptEndDate as [EndDate]
from clmclaim cl
inner join penPolicyTransSummary pts on cl.PolicyTransactionKey = pts.PolicyTransactionKey --and pts.TransactionType = 'base'
inner join clmName n on n.ClaimKey = cl.ClaimKey and n.isPrimary = 1
cross apply
	(
	Select distinct
		a_w.ClaimKey,
		a_w.StatusName as [Claim Status],
		a_w.CompletionDate
	from e5work a_w
	inner join e5WorkProperties a_wp on a_w.Work_ID = a_wp.Work_ID
	inner join e5WorkItems a_wi on a_wi.id = a_wp.PropertyValue
	where
		a_w.ClaimKey = cl.ClaimKey
		and a_w.WorkType = 'claim'
		and a_wp.Property_ID = 'ClaimType'
		and a_wi.Code = @e5claimtype
	) as w
cross apply
    (
    select
        case
            when cl.ReceivedDate is null then cl.CreateDate
            when cl.ReceivedDate > dateadd(day, 1, convert(date, cl.CreateDate)) then cl.CreateDate
            else cl.ReceivedDate
        end as [ReceiptDate]
    ) as crd
outer apply
	(
	select
		sum(a_s.EstimateValue) as [Current Estimate],
		sum(pm.PaymentAmount) as [Total Paid]
	from clmSection a_s
		outer apply
			(
			select
				sum(a_p.PaymentAmount) as [PaymentAmount]
			from clmPayment a_p
			where
				a_p.SectionKey = a_s.SectionKey
				and a_p.PaymentStatus = 'PAID'
				and a_p.isDeleted = 0
			) as pm
	where
		a_s.ClaimKey = cl.ClaimKey
		and a_s.isDeleted = 0
	) as ep
where
	cl.CountryKey = @Country
	and crd.ReceiptDate >= @rptStartDate and crd.ReceiptDate <= @rptEndDate


end
GO
