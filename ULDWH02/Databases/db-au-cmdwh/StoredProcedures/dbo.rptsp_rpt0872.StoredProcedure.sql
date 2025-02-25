USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0872]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0872]    
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0872
--  Author:         Saurabh Date
--  Date Created:   20170721
--  Description:    This stored procedure returns Zurich Claims deails
--  Change History: 20170721 - SD - Created
/****************************************************************************************************/

select
	cc.CountryKey,
	cc.ReceivedDate,
	st.CompletionDate,
	Case
		When convert(date, cc.ReceivedDate) = convert(date, st.CompletionDate) then 1
		When convert(date, cc.ReceivedDate) = convert(date, getdate()) then 1
		When st.Status = 'Complete' then datediff(day, cc.ReceivedDate, isnull(convert(date, st.CompletionDate), getdate()))
        else datediff(day, cc.ReceivedDate, convert(date, getdate()))
	End [AbsoluteAge],
	cc.ClaimNo,
	st.Status,
	IsNull(ps.AddOnGroup, 'Unknown') PolicySection,
	IsNull(Estimate, 0) Estimate,
	isNull(Paid, 0) Paid
From
	clmClaim cc
	Outer apply
	(
		select
			Top 1
			Sum(vcc.Estimate) Estimate,
			Sum(vcc.Paid) Paid,
			Max(vcc.IncurredDate) IncurredDate
		From
			vclmClaimSectionIncurred vcc
		where
			vcc.claimkey = cc.ClaimKey
	) inc
	Outer apply
	(
		select 
			top 1
			w.StatusName Status,
			w.CompletionDate
        from
            [db-au-cmdwh]..e5Work w with(nolock)
            inner join [db-au-cmdwh]..e5WorkEvent we with(nolock) on
                we.Work_ID = w.Work_ID
        where
            w.ClaimKey = cc.ClaimKey and
            w.WorkType like '%claim%' and
            w.WorkType not like '%audit%' and
            we.EventDate < convert(date, dateadd(day, 1, inc.IncurredDate))
        order by
            we.EventDate desc
	)st
	Outer apply
	(
		select
			Top 1
			AddOnGroup
		From
			penPolicyTransAddon ppt
		where
			ppt.PolicyTransactionKey = cc.policyTransactionKey
		Order By
			GrossPremium Desc
	) ps
Where
	((cc.PolicyIssuedDate >= '2017-06-01' and cc.AgencyCode not in ('APN0004', 'APN0005')) or cc.PolicyIssuedDate >= '2017-07-01')
	and
	cc.CountryKey in ('AU', 'NZ')
	and
	Status is not null
	and
	Status <> 'Rejected'


end
GO
