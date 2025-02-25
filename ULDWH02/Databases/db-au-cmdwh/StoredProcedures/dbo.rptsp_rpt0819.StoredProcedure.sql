USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0819]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0819]	@DateRange varchar(30),
					@StartDate varchar(10) = null,
					@EndDate varchar(10) = null                      
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0819
--  Author:         Saurabh Date
--  Date Created:   20161005
--  Description:    This stored procedure returns new consultant details, 6 weeks from when consultant created
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20161005 - SD - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/


declare @rptStartDateCY datetime
declare @rptEndDateCY datetime

/* get reporting dates */
if @DateRange = '_User Defined'
begin
    select 
        @rptStartDateCY = convert(smalldatetime,@StartDate),
        @rptEndDateCY = convert(smalldatetime,@EndDate)
end            
else
    select 
        @rptStartDateCY = StartDate, 
        @rptEndDateCY = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange

--report dates check
--select @rptStartDateCY, @rptEndDateCY


select 
	isnull(o.LatestBDMName,a.BDMName) as BDMName, 
	u.Consultantname,
	a.OutletName,
	o.ContactPostCode,
	o.ContactEmail,
	o.ContactPhone,
	Sum(ppt.GrossPremium) SellPrice,
	Sum(BasePolicyCount) PolicyCount
from [db-au-star].dbo.dimConsultant u
		inner join [db-au-star].dbo.factPolicyTransaction pt
			on pt.ConsultantSK = u.ConsultantSK
		inner join [db-au-star].dbo.dimOutlet o 
			on pt.OutletSK = o.OutletSK
		inner join sfAccount a
			on o.AlphaCode = a.AlphaCode and
				o.Country = Left(a.AgencyID, 2)
		inner join penPolicyTransSummary ppt
			on ppt.OutletAlphaKey = o.OutletAlphaKey
				and ppt.PostingDate Between DATEADD(week,-6,@rptEndDateCY) and @rptEndDateCY
Where
	o.TradingStatus = 'Stocked' and
	Left(a.AgencyID, 2) = 'AU' and
	a.TradingStatus in ('Stocked','Prospect') and
	a.OutletType = 'B2B' and
	o.SuperGroupName in ('Independents','Flight Centre','Helloworld') and
	pt.TransactionType = 'Base' and
	pt.TransactionStatus = 'Active' and
	u.ConsultantType = 'External' and
	DateDiff(Week, u.AccreditationDate, @rptEndDateCY) <= 6 and
	pt.PostingDate Between DATEADD(week,-6,@rptEndDateCY) and @rptEndDateCY
Group By
	isnull(o.LatestBDMName,a.BDMName), 
	u.Consultantname,
	a.OutletName,
	o.ContactPostCode,
	o.ContactEmail,
	o.ContactPhone
GO
