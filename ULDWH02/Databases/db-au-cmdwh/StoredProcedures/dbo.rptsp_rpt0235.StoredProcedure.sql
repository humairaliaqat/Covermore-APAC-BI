USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0235]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0235]
  @Country varchar(2),
  @AgencyGroup varchar(2),
  @ReportingPeriod varchar(30),
  @StartDate varchar(10) = null,
  @EndDate varchar(10) = null
                    
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0235
--  Author:         Leonardus Setyabudi
--  Date Created:   20111031
--  Description:    This stored procedure returns benchmark measures for consultant
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20111031 - LS - Created
--                  20120120 - LS - put in new fields (sales channel, store code)
--                  20120301 - LS - use subgroupname for channel
--                  20120302 - LS - Use Channel for empty store code
--                  20140129 - LS - migrate to penguin data set
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
    @Country = 'AU',
    @AgencyGroup = 'CM',
    @ReportingPeriod = 'Last Fiscal Month', 
    @StartDate = null, 
    @EndDate = null
*/

    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
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

    ;with cte_quotes as
    (
        select
            o.AlphaCode AgencyCode,
            o.SubGroupName AgencySubGroupCode, -- MPL Sales Channel
            isnull(convert(varchar(250), upper(q.StoreCode)), o.SubGroupName) AgencyName,
            q.QuoteID,
            convert(varchar(10), q.CreateDate, 120) QuoteDate,
            q.Destination,
            case
                when q.CanxFlag = 1 then 'Yes'
                else 'No'
            end HasCanx,
            case
                when PolicyNo is null then 'No'
                else 'Yes'
            end Converted,
            NumberOfAdults,
            NumberOfChildren,
            NumberOfPersonWithEMC,
            EMCID,
            isnull(ApprovedEMC, 0) ApprovedEMC,
            isnull(DeclinedEMC, 0) DeclinedEMC
        from 
            penOutlet o
            inner join penQuote q on 
                q.OutletAlphaKey = o.OutletAlphaKey
            cross apply
            (
                select 
                    count(qc.CustomerID) NumberOfPersonWithEMC
                from 
                    penQuoteCustomer qc
                where 
                    qc.QuoteCountryKey = q.QuoteCountryKey and
                    qc.HasEMC = 1
            ) qe
            outer apply
            (
                select 
                    min(qe.EMCID) EMCID,
                    max(
                        case
                            when qe.DeniedAccepted = 'A' then 1 
                            else 0
                        end
                    ) ApprovedEMC,
                    max(
                        case
                            when qe.DeniedAccepted = 'D' then 1 
                            else 0
                        end
                    ) DeclinedEMC
                from 
                    penQuoteEMC qe
                where 
                    qe.QuoteCountryKey = q.QuoteCountryKey
            ) qec
        where 
            o.OutletStatus = 'Current' and
            o.CountryKey = @Country and
            o.GroupCode = @AgencyGroup and
            q.CreateDate between @rptStartDate and @rptEndDate and
            NumberOfPersonWithEMC > 0
    )
    select
        AgencyCode,
        AgencySubGroupCode,
        AgencyName,
        QuoteID,
        QuoteDate,
        Destination,
        HasCanx,
        Converted,
        NumberOfAdults,
        NumberOfChildren,
        NumberOfPersonWithEMC,
        EMCID,
        case
            when ApprovedEMC = 1 and DeclinedEMC = 1 then 'Partial Approval'
            when ApprovedEMC = 1 then 'Approved'
            when DeclinedEMC = 1 then 'Declined'
            when EMCID is not null then 'Pending'
            else 'No EMC Application'
        end AssessmentStatus,
        @rptStartDate StartDate, 
        @rptEndDate EndDate
    from 
        cte_quotes
    order by 
        QuoteDate,
        QuoteID

end
GO
