USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0112]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0112]	
    @WorkGroup varchar(100) = 'All',
    @WorkStatus varchar(100) = 'All',
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
    
as
begin

/****************************************************************************************************/
--  Name:           rptsp_rpt0002a
--  Author:         Leonardus Setyabudi
--  Date Created:   20120820
--  Description:    This stored procedure returns debtors that fall within the parameter values
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: Optional Agency Group Code; e.g. TI
--                  @AgencyCode: Opitonal csv form Agency Codes; e.g. TIN1121,TIN1122
--                  @ReportingPeriod: Value is valid date range
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2012-12-01
--
--  Change History: 20130904 - LS - Case 19119, change criteria to last assessment outcome = denied
--					20130923 - LS - Case 19177, add agency group name
--					20141118 - LS - F22417, add additional asessment outcome filters
--					20150429 - LT - F24106, added new columns to query:
--												* Catastrophe Code
--												* Plan
--												* Section Code
--												* Decline Reason (DenialDetails)
--												* First Estimate Value
--												* Current Estimate Value
--												* Total Payments
--												* Primary Customer Age
--												* Event Country
--                  20151117 - LS - F27128, this is olddd .. (e.g. still referring Agency table)
--				
/****************************************************************************************************/

--uncomment to debug
/*
	declare @WorkGroup varchar(100)
	declare @WorkStatus varchar(100)
	declare @ReportingPeriod varchar(30)
	declare @StartDate varchar(10)
	declare @EndDate varchar(10)
	select @WorkGroup = 'All', @WorkStatus = 'All', @ReportingPeriod = 'Last Month'
*/
    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime

    /* get reporting dates */
    if @ReportingPeriod = 'User Defined'
        select 
            @rptStartDate = convert(smalldatetime,@StartDate), 
            @rptEndDate = convert(smalldatetime,@EndDate)
            
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    select 
        w.ClaimNumber,
        cl.ReceivedDate,
        cl.Peril ClaimType,
        w.WorkType,
        w.GroupType,
        w.StatusName,
        cl.EstimateValue TotalEstimateValue,
        w.ClaimDescription,
        wa.CompletionDate DeniedDate,
        wa.CompletionUser ClaimsOfficer,
        @rptStartDate as rptStartDate,
        @rptEndDate as rptEndDate,
        pl.Email,
        o.GroupName AgencyGroupName,
        wa.AssessmentOutcomeDescription AssessmentOutcome,
        cl.CatastropheCode,
        cl.SectionCode,
        cl.FirstEstimateValue,
        cl.EstimateValue as CurrentEstimateValue,
        cl.PaidPayment,
        datediff(year, cl.DOB, cl.ReceivedDate) as [Age],
        cl.EventCountryName as EventCountry,
        pl.[Plan],
        den.DenialDetails
    from
        e5Work w
        inner join clmClaimSummary cl on
            cl.ClaimKey = w.ClaimKey
        inner join penOutlet o on
            o.OutletKey = cl.OutletKey and
            o.OutletStatus = 'Current'
        cross apply
        (
            select top 1
                wa.ID,
                wa.AssessmentOutcome,
                wa.AssessmentOutcomeDescription,
                wa.CompletionDate,
                wa.CompletionUser         
            from
                e5WorkActivity wa 
            where
                wa.Work_Id = w.Work_ID and
                wa.CategoryActivityName = 'Assessment Outcome' and
                wa.CompletionDate between @rptStartDate and @rptEndDate
            order by
                CompletionDate desc
        ) wa
		outer apply
		(
			select top 1
				wap.PropertyValue
			from
				e5WorkActivityProperties wap
			where
				wap.WorkActivity_ID = wa.ID and
				wap.Property_ID = 'DenialDetails'
		) wap
        outer apply
        (
            select top 1
                i.Name DenialDetails
            from
                e5WorkItems i 
            where
                i.ID = wap.PropertyValue
        ) den
        outer apply
        (
			select 
				max(
                    case
                        when Property_ID = 'Plan' then PropertyValue
                        else null
                    end
                ) [Plan],
				max(
                    case
                        when Property_ID = 'Email' then PropertyValue
                        else null
                    end
                ) [Email]
			from
				e5WorkProperties
			where
				Work_ID = w.Work_ID and
				Property_ID in ('Plan', 'Email')
		) pl            
    where
        w.StatusName <> 'Rejected' and
        w.WorkType like '%claim%' and
        (
            wa.AssessmentOutcomeDescription like '%deni%' or
            wa.AssessmentOutcomeDescription like '%deny%'
        ) and
        (
            @WorkGroup = 'All' or
            w.GroupType = @WorkGroup
        ) and
        (
            @WorkStatus = 'All' or
            w.StatusName = @WorkStatus
        )

end
GO
