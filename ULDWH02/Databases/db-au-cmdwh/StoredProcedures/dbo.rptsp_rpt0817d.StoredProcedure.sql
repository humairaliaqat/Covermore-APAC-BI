USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0817d]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0817d]	
    @DateRange varchar(30),
    @StartDate datetime,
    @EndDate datetime,
	@Country nvarchar(5),
	@Supergroup nvarchar(50),
	@Group nvarchar(50),
	@Subgroup nvarchar(50)
as

Begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0817d
--  Author:         Peter Zhuo
--  Date Created:   20160919
--  Description:    Returns all claim-derived complaint/IDR/EDR in the selected period
--					
--  Parameters:     
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--					@Country: Required. Valid outlet country
--					@Supergroup: Optional. Valid outlet supergroupname or choose 'All'
--					@Group: Optional. Valid outlet groupname or choose 'All'
--					@Subgroup: Optional. Valid outlet subgroupname or choose 'All'
--                  
--  Change History: 
--                  20160919 - PZ - Created
--					20170209 - SD - Inclusion of subgroup selection prompt
--                  
/****************************************************************************************************/

--Uncomment to debug
--Declare
--    @DateRange varchar(30),
--    @StartDate datetime,
--    @EndDate datetime,
--	@Country nvarchar(5),
--	@Supergroup nvarchar(50),
--	@Group nvarchar(50),
--	@Subgroup nvarchar(50)

--Select 
--    @DateRange = '_User Defined',
--    @StartDate = '2016-10-06',
--    @EndDate = '2016-10-06',
--	@Country = 'AU',
--	@Supergroup = 'AAA',
--	@Group = 'All',
--	@Subgroup = 'All'



declare
    @rptStartDate datetime,
    @rptEndDate datetime

    if @DateRange = '_User Defined'
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
            DateRange = @DateRange

-------------------

SELECT
	w.GroupType,
	w.Reference,
	w.AssignedUser,
	vwp.ComplaintDateLodged,
	w.CreationDate as [e5Work CreationDate],
	clm.ClaimNo,
	p.PolicyNumber,
	cn.Surname as [Primary Claimant Surname],
	o.SuperGroupName,
	o.Groupname,
	o.AlphaCode,
	o.OutletName,
	vwp.ReasonForComplaint,
	wp.isEDR,
	@DateRange as [ReportingPeriod],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
FROM
	e5Work w
INNER JOIN ve5WorkProperties vwp ON (w.Work_ID = vwp.Work_ID)  
inner join clmclaim clm on clm.ClaimKey = w.ClaimKey
left join clmname cn on cn.ClaimKey = clm.ClaimKey and cn.isPrimary = 1
left join penPolicyTransSummary pts on clm.PolicyTransactionKey = pts.PolicyTransactionKey
left join penpolicy p on p.PolicyKey = pts.PolicyKey
inner join penoutlet o on o.OutletKey = clm.OutletKey and o.OutletStatus = 'current'
outer apply
(
    select top 1 
        convert(varchar, a_wp.PropertyValue) as isEDR
    from
        [db-au-cmdwh]..e5WorkProperties a_wp
    where
        a_wp.Work_ID = w.Work_ID and
        a_wp.Property_ID = 'EDRReferral'
) wp
WHERE
	o.CountryKey = @Country and
	w.WorkType = 'Complaints' and
	w.ClaimKey is not null and
	convert(date, w.CreationDate) >= @rptStartDate and convert(date, w.CreationDate) < dateadd(day,1,@rptEndDate)
	and (o.SuperGroupName = @Supergroup or isnull(@Supergroup,'All') = 'All')
	and (o.GroupName = @Group or isnull(@Group,'All') = 'All')
	and (o.SubGroupName = @Subgroup or isnull(@Subgroup,'All') = 'All')

end
GO
