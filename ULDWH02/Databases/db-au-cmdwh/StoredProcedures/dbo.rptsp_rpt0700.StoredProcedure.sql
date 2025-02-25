USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0700]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0700]		@Country varchar(3),
											@ClaimType varchar(30) = 'All',
											@OnlineClaim varchar(30) = 'All',
											@DateRange varchar(30),
											@StartDate varchar(10) = null,
											@EndDate varchar(10) = null    
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0700
--  Author:         Linus Tor
--  Date Created:   20160412
--  Description:    This stored procedure returns claims received during a specified period 
--                  with respective online claim & e5 classification and metrics
--  Parameters:    
--                  @Country: valid country code.
--                  @DateRange: Required - Valid date range. If _User Defined, enter StartDate and EndDate
--                  @StartDate: Optional - only required if DateRange = _User Defined
--                  @EndDate: Optional - only required if DateRange = _User Defined
--  
--  Change History: 20160412 - LT - procedure created
--
/****************************************************************************************************/


--uncomment to debug  
--declare 
--    @Country varchar(3),
--	@OnlineClaim varchar(30),
--	@ClaimType varchar(30),
--    @DateRange varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10)  
--select   
--    @Country = 'AU',
--	@ClaimType = 'All',
--	@OnlineClaim = 'All',
--    @DateRange = 'Last February',
--    @StartDate = null,   
--    @EndDate = null  

 
declare @rptStartDate datetime  
declare @rptEndDate datetime  
  
/* get reporting dates */  
if @DateRange = '_User Defined'  
    select   
        @rptStartDate = @StartDate,   
        @rptEndDate = @EndDate    
else  
    select   
        @rptStartDate = StartDate,   
        @rptEndDate = EndDate  
    from   
        [db-au-cmdwh].dbo.vDateRange  
    where   
        DateRange = @DateRange

if @ClaimType = 'All' select @ClaimType = null
if @OnlineClaim = 'All' select @OnlineClaim = null	
else if @OnlineClaim = 'Online' select @OnlineClaim = 1
else if @OnlineClaim = 'Offline' select @OnlineClaim = 0

select 
    cl.ClaimNo,
	cle.ClaimDescription,
    cl.ReceivedDate,
	cl.CreatedBy,
	cl.FinalisedDate,
	case when cl.FinalisedDate is null then 0 else 1 end as isFinalised,
	isnull(claimType.AssignedUser,'Unassigned') as AssignedUser,
	claimType.AssignedDate,
	claimType.CompletionUser,
	claimType.CompletionDate,
	cl.OnlineAlpha,
    benefit.Benefit1,
	benefit.Benefit2,
	benefit.Benefit3,
	benefit.Benefit4,
	firstestimate.FirstEstimate,
    cs.EstimateValue,
    isnull(cp.Paid, 0) Paid,
    w.WorkType,
	p.SuperGroupName,
    cl.AgencyCode,
    cl.PolicyNo,
    cl.PolicyProduct,
    cl.OnlineClaim,
    case
        when cl.OnlineClaim = 0 then 'Offline'
        when isnull(cl.OnlineAlpha, '') = '' then 'Customer'			
        else isnull(crm.CRMUser, 'Agent')
    end OnlineBy,
	claimType.claimType,
	case when claimType.ClaimType = 'Teleclaim' then 1						 
			when isnull(cl.OnlineAlpha, '') = '' then 0			--customer
			when isnull(cl.OnlineAlpha, '') <> '' then 0			--agent
			when isnull(crm.CRMUser, '') <> '' then 1			   --CM internal staff
			else 0
	end as TeleclaimCount,
	case when isnull(claimType.ClaimType,'') = 'Assistance Teleclaim' then 1
			else 0
	end as AssistanceTeleclaimCount,
	claimcount.ClaimCount,
	isnull(w.AssessmentCount,0) as AssessmentCount,
	isnull(cd.ApprovedCount,0) as ApprovedCount,
	isnull(cd.DeclinedCount,0) as DeclinedCount,
	isnull(callback.CallBack,0) as CallBack,
	isnull(tele.NewClaimsCallOffered,0) as NewClaimsCalledOffered,
	isnull(telephony.CallsTransferedToTeleclaims,0) as CallsTransferredToTeleclaims,
	isnull(telephony.TotalCallsAnsweredclaims,0) as TotalCallsAnsweredClaims,
	isnull(telephony.RingNoAnswer,0) as RingNoAnswer,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate,
	case
		when isnull(was.HasApproval, 0) > 0 and isnull(was.HasDenial,0) > 0 then 'Partial Approval'
		when isnull(was.HasApproval, 0) > 0 then 'Approved'
		when isnull(was.HasDenial, 0) > 0 then 'Denied'
		else ''
	end [ApprovalStatus],
	wdays.ActiveDays,
	wdays.DiarisedDays,
	case
		when cl.FinalisedDate is not null then datediff(day, crd.ReceiptDate, isnull(convert(date, cl.FinalisedDate), getdate())) 
		else datediff(day, crd.ReceiptDate, convert(date, getdate()))
	end [CycleTime],
	cc.CompletionCount
from
    clmClaim cl
	outer apply
	(
		select EventDesc as ClaimDescription
		from clmEvent 
		where ClaimKey = cl.ClaimKey
	) cle
	outer apply
	(
		select 
			[Benefit1],
			[Benefit2],
			[Benefit3],
			[Benefit4]
		from
			(
				select 
					'Benefit' + CAST(row_number() over(order by cs.SectionID) as varchar) [Benefit], 
					cb.BenefitDesc
				from 
					clmSection cs 
					left join vclmBenefitCategory cb on cb.BenefitSectionKey = cs.BenefitSectionKey
				where 
					cs.ClaimKey = cl.ClaimKey
			) source
			PIVOT 
			(
				max(BenefitDesc)
				FOR [Benefit] in ([Benefit1],[Benefit2],[Benefit3],[Benefit4])
			) pvt
	) benefit
    outer apply
    (
        select top 1 
            pt.PolicyNumber,
            jv.JVCode,
            jv.JVDescription,
			o.GroupName,
			o.SuperGroupName
        from
            penPolicyTransSummary pt
            inner join penOutlet o on
                o.OutletAlphaKey = pt.OutletAlphaKey and
                o.OutletStatus = 'Current'
            inner join vpenOutletJV jv on
                jv.OutletKey = o.OutletKey
        where
            pt.PolicyTransactionKey = cl.PolicyTransactionKey
    ) p
    outer apply
    (
        select top 1 
            jv.JVCode,
            jv.JVDescription,
			O.GroupName
        from
            corpQuotes q
            inner join penOutlet o on
                o.CountryKey = cl.CountryKey and
                o.AlphaCode = q.AgencyCode and
                o.OutletStatus = 'Current'
            inner join vpenOutletJV jv on
                jv.OutletKey = o.OutletKey
        where
            convert(varchar(50),q.PolicyNo) = cl.PolicyNo and
            q.CountryKey = cl.CountryKey
    ) co
	outer apply
	(
		select sum(EstimateValue) as EstimateValue
		from 
			clmSection 
		where
			ClaimKey = cl.ClaimKey
	) cs
    outer apply
    (
        select 
            sum(PaymentAmount) Paid
        from
            clmPayment cp
        where
            cp.PaymentStatus in ('PAID', 'RECY') and
            cp.ClaimKey = cl.ClaimKey
    ) cp
	outer apply
	(
		select top 1
			OnlineConsultant,
			CountryKey,
			OnlineAlpha,
			CreatedBy
		from
			clmClaim
		where
			ClaimKey = cl.ClaimKey
	) cl2
	outer apply
	(
		select top 1 
			cu.FirstName + ' ' + cu.LastName CRMUser
		from
			penCRMUser cu
		where
			cu.CountryKey = cl2.CountryKey and
			cu.UserName = cl2.OnlineConsultant
	) crm
	outer apply
	(
		select top 1 
			u.FirstName + ' ' + u.LastName Consultant
		from
			penUser u
			inner join penOutlet o on
				o.OutletStatus = 'Current' and
				o.OutletKey = u.OutletKey
		where
			u.CountryKey = cl2.CountryKey and
			u.UserStatus = 'Current' and
			u.[Login] = cl2.OnlineConsultant and
			o.AlphaCode = cl2.OnlineAlpha
	) cons	
	outer apply
	(
		select top 1 
			w.WorkType,
			AssessmentCount
		from
			e5Work w 
			outer apply
			(
				select 
					count(wa.Work_ID)  AssessmentCount
				from
					e5WorkActivity wa
				where
					wa.Work_ID = w.Work_ID and
					CategoryActivityName = 'Assessment Outcome' and
					wa.CompletionDate >= @rptStartDate and
					wa.CompletionDate <  dateadd(d,1,@rptEndDate)
			) ao

		where
			w.ClaimKey = cl.ClaimKey and
			(
				w.WorkType like '%claim%'
			)
		order by w.CreationDate
	) w
	outer apply
	(
		select top 1 
			w.CreationUser as CreatedBy,
			w.CreationDate,
			w.AssignedUser,
			w.AssignedDate,
			w.CompletionUser,
			w.CompletionDate,
			teleclaim.ClaimType
		from
			e5Work w
			outer apply
			(
				select top 1 
					witem.ClaimType
				from
					e5Work_v3 e5w
					inner join e5WorkProperties_v3 e5wp on e5w.Work_ID = e5wp.Work_ID
					outer apply
					(
						select top 1 Name as ClaimType
						from 
							e5WorkItems_v3
						where
							ID = e5wp.PropertyValue
					) witem
				where 
					e5wp.Property_ID = 'ClaimType' and
					e5w.Work_ID = w.Work_ID
			) teleclaim
		where
			w.ClaimKey = cl.ClaimKey and
			(
				w.WorkType like '%claim%'
			)
	) claimType
    cross apply
    (
        select
            case
                when cl.ReceivedDate is null then cl.CreateDate
                when cl.ReceivedDate > dateadd(day, 1, convert(date, cl.CreateDate)) then cl.CreateDate
                else cl.ReceivedDate
            end ReceiptDate
    ) crd
	outer apply
	(
		select top 1 
			sum(EstimateMovement) [FirstEstimate]
		from
			clmClaimEstimateMovement
		where
			ClaimKey = cl.ClaimKey 
		group by
			EstimateDate, 
			case EstimateCategory when 'New' then 1 else 2 end
		order by
			EstimateDate, 
			case EstimateCategory when 'New' then 1 else 2 end
	) firstEstimate
	outer apply
	(
		select count(distinct ClaimKey) as ClaimCount
		from clmClaim 
		where ClaimKey = cl.ClaimKey
	) as claimcount
	outer apply
	(
		select
			count(
				distinct 
				case
					when wa.AssessmentOutcomeDescription = 'Approve' then wa.Work_ID
					else null
				end
			) as [ApprovedCount],
			count(
				distinct 
				case
					when wa.AssessmentOutcomeDescription = 'Deny' then wa.Work_ID
					else null
				end
			) as [DeclinedCount]
		from
			e5Work_v3 w
			inner join e5WorkActivity wa on w.Work_ID = wa.Work_ID
		where
			w.ClaimKey = cl.ClaimKey and
			wa.CategoryActivityName = 'Assessment Outcome' and
			wa.AssessmentOutcomeDescription in ('Deny', 'Approve')
	) cd
	outer apply
	(
		select
			count(
				distinct
				case
					when StatusName = 'Complete' and
						 CompletionDate >= @rptStartDate  and
						 CompletionDate < dateadd(d,1,@rptEndDate)
					then ClaimKey
					else null
				end
			) CompletionCount
		from
			e5Work_v3
		where
			ClaimKey = cl.ClaimKey
	) cc
	outer apply
	(
		select
			sum(callspresented) NewClaimsCallOffered
		from 
			[dbo].[vTelephonyCallData] 
		where
			csqname='CS_CM_CSR' and 
			callednumber='1179' and 
			convert(date,calldate) >=  @rptStartDate and
			convert(date,calldate) <  dateadd(d,1,@rptEndDate)
	) tele
	outer apply
	(
		select 
			sum(callspresented) [CallsTransferedToTeleclaims],
			sum(Callshandled) [TotalCallsAnsweredclaims],
			sum(RNA) [RingNoAnswer] 
		from 
			[dbo].[vTelephonyCallData]
		where 
			callednumber='1080' and
			convert(date,calldate)>= @rptStartDate and
			convert(date,calldate) <  dateadd(d,1,@rptEndDate)
	) Telephony
	outer apply
	(
		select 
				count(		
					case
						when w.WorkType = 'Phone Call' and w.GroupType = 'Call Back' then isnull(pw.ClaimNumber, w.ClaimNumber)
						else null
					end
				) CallBack
			from
				e5Work_v3 w
				left join e5Work_v3 pw on
					pw.Work_ID = w.Parent_ID
			where
				w.CreationDate >= @rptStartDate and
				w.CreationDate < dateadd(d,1,@rptEndDate) and
				w.Country = cl.CountryKey and
				(
					(
						w.WorkType = 'Complaints' and
						w.GroupType = 'New'
					) or
					(
						w.WorkType = 'Phone Call' and
						w.GroupType = 'Call Back'
                
					)
				)
	) callback
	outer apply
	(
		select 
			sum(
				case
					when wi.Name like '%approve%' then 1
					when wi.Name like '%approval%' then 1
					else 0
				end
			) HasApproval,
			sum(
				case
					when wi.Name like '%deny%' then 1
					when wi.Name like '%deni%' then 1
					else 0
				end
			) HasDenial
		from
			e5Work ww
			inner join e5WorkActivity wa on
				wa.Work_ID = ww.Work_ID
			inner join e5WorkItems wi on
				wi.ID = wa.AssessmentOutcome
		where
			ww.ClaimKey = cl.ClaimKey and
			wa.CategoryActivityName = 'Assessment Outcome' and
			wa.CompletionDate is not null
	) was
    outer apply
    (
        select 
            sum(
                case
                    when we.StatusName = 'Active' then datediff(day, convert(date, we.EventDate), convert(date, isnull(nwe.NextChangeDate, getdate())))
                    else 0
                end
            ) ActiveDays,
            sum(
                case
                    when we.StatusName = 'Diarised' then datediff(day, convert(date, we.EventDate), convert(date, isnull(nwe.NextChangeDate, getdate())))
                    else 0
                end
            ) DiarisedDays,
            sum(
                case
                    when we.StatusName = 'Active' then datediff(day, convert(date, we.EventDate), convert(date, isnull(nwe.NextChangeDate, getdate()))) - OffDays
                    else 0
                end
            ) ActiveBusinessDays,
            sum(
                case
                    when we.StatusName = 'Diarised' then datediff(day, convert(date, we.EventDate), convert(date, isnull(nwe.NextChangeDate, getdate()))) - OffDays
                    else 0
                end
            ) DiarisedBusinessDays
        from
			e5Work_v3 ww
			inner join e5WorkEvent we on ww.Work_ID = we.Work_ID
            outer apply
            (
                select top 1
                    r.EventDate NextChangeDate
                from
                    e5WorkEvent r
                where
                    r.Work_Id = ww.Work_ID and
                    r.EventDate > we.EventDate and
                    (
                        (
                            r.EventName in ('Changed Work Status', 'Merged Work') and
                            isnull(r.EventUser, r.EventUserID) not in ('e5 Launch Service', 'svc-e5-prd-services')
                        )
                        or
                        (
                            --e5 Launch Service may cause a case to have total (Active Days + Diarised Days) > Absolute Age
                            --this is due to [Saved Work] events with multiple [Status] occuring in same timestamp to ms
                            --part of known issue revolving online claims in e5 v2
                            r.EventName = 'Saved Work' and
                            r.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                        )
                    )
                order by
                    r.EventDate
            ) nwe
            outer apply
            (
                select 
                    count(d.[Date]) OffDays
                from
                    Calendar d
                where
                    d.[Date] >= convert(date, we.EventDate) and
                    d.[Date] <  convert(date, isnull(nwe.NextChangeDate, getdate())) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            ) phd
        where
            ww.ClaimKey = cl.ClaimKey and
            (
                (
                    we.EventName in ('Changed Work Status', 'Merged Work') and
                    isnull(we.EventUser, we.EventUserID) not in ('e5 Launch Service', 'svc-e5-prd-services')
                )
                or
                (
                    we.EventName = 'Saved Work' and
                    we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
                )
            ) and
            we.StatusName in ('Active', 'Diarised')
    ) wdays
where
    cl.CountryKey = @Country and
	(
		@ClaimType is null or
		ClaimType.ClaimType = @ClaimType
	) and
	(
		@OnlineClaim is null or
		cl.OnlineClaim = @OnlineClaim
	) and
    cl.ReceivedDate >= @rptStartDate and
    cl.ReceivedDate <  dateadd(day, 1, @rptEndDate) 

GO
