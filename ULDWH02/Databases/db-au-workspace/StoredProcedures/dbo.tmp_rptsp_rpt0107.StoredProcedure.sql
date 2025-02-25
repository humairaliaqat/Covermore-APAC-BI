USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0107]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_rptsp_rpt0107]	@ReportingPeriod varchar(30),	
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON 
/****************************************************************************************************/
--	Name:			rptsp_rpt0107
--	Author:			Sharmila Inbaseelan
--	Date Created:	20101118
--	Description:	This stored procedure returns all the AU policies under Alpha CMFL000 and the CANX 
--					cover details.
--	Parameters:		@ReportingPeriod	--If value "User Dafined" enter Start Date and End Date
--					@StartDate			--Enter Start Date (Format:YYYY-MM-DD Eg 2010-01-01)
--					@EndDate			--Enter End Date   (Format:YYYY-MM-DD Eg 2010-01-01)
--	Parameters:
--	Change History:	20101118 - sharmilai - Created
--					20110106 - sharmilai - Added a script in where clause to exclude new policies that
--										   were subsequently cancelled (Fogbugs Case_14757)
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar (10)
declare @EndDate varchar (10)
select @ReportingPeriod = 'Month-To-Date',@StartDate =null ,@EndDate=null
*/
declare @rptStartDate datetime
declare @rptEndDate datetime

if @ReportingPeriod = 'User Defined'
select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
select @rptStartDate = StartDate, @rptEndDate = EndDate
from [db-au-cmdwh].dbo.vDateRange
where DateRange = @ReportingPeriod

select 
distinct p.PolicyNo,
p.CancellationCoverValue as CANXCover,
p.IssuedDate,
p.DepartureDate,
p.ReturnDate,
p.ProductCode,
p.GrossPremiumExGSTBeforeDiscount as SellPrice,
c.ConsultantName,
cu.AddressState As CustomerStates,
@rptStartDate as StartDate,
@rptEndDate as EndDate

from [db-au-cmdwh].dbo.Policy p
inner join [db-au-cmdwh].dbo.Consultant c on c.ConsultantKey = p.ConsultantKey
inner join [db-au-cmdwh].dbo.Customer cu on cu.CustomerKey = p.CustomerKey

where 
p.CountryKey = 'AU'
and p.IssuedDate between @rptStartDate and @rptEndDate
and p.PolicyType = 'N'
and p.agencycode = 'CMFL000'
and p.PolicyNo not in (select pp.OldPolicyNo --exclude new policies that were subsequently cancelled
						from [db-au-cmdwh].dbo.Policy pp
						where pp.CountryKey ='AU'
						and pp.IssuedDate between @rptStartDate and @rptEndDate
						and pp.PolicyType ='R'
						and pp.AgencyCode ='CMFL000'
						and pp.OldPolicyNo <> 0) 
						
order by
p.policyno
GO
