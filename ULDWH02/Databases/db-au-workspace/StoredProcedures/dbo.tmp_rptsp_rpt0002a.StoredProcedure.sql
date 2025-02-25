USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0002a]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tmp_rptsp_rpt0002a] @AgencyCodeFrom varchar(7),
										@AgencyCodeTo varchar(7),
										@ReportingPeriod varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0002a
--	Author:			Linus Tor
--	Date Created:	20110615
--	Description:	This stored procedure returns debtors that fall within the parameter values
--	Parameters:		@AgencyCode: % for all agencies, or enter 1 or more agency codes separated by comma
--					@ReportingPeriod: default date range or _User Defined
--					@StartDate: if _User Defined, enter Start Date. Format: YYYY-MM-DD eg. 2011-01-01
--					@EndDate: if _User Defined, enter End Date. Format: YYYY-MM-DD eg. 2011-01-01
--
--	Change History:	20110615 - LT - Migrated from OXLEY.RPTDB.dbo.rptsp_rpt0002a
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @AgencyCodeFrom varchar(7)
declare @AgencyCodeTo varchar(7)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @AgencyCodeFrom = 'aaaaaaa', @AgencyCodeTo = 'zzzzzzz', @ReportingPeriod = 'Last Month', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime


/* get reporting dates */
if @ReportingPeriod = 'User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod
  
select @rptStartDate = '2003-05-01'
--select @rptStartDate, @rptEndDate
  
if object_id('tempdb..#rpt0002a_Unallocated') is not null drop table #rpt0002a_Unallocated
select 
	r.CountryKey,
	r.AgencyCode, 
	sum(isnull(p.Amount,0)) as Amount 
into #rpt0002a_Unallocated
from 
	[db-au-cmdwh].dbo.BankPayment p
	join [db-au-cmdwh].dbo.BankReturn r on
		p.CountryKey = r.CountryKey and
		p.ReturnKey = r.ReturnKey
where 
	p.CountryKey = 'AU' and
	(p.Allocated is null or p.Allocated = 0) and
	(r.Op is not null or r.Op <> 'WS')
group by
	r.CountryKey,
	r.AgencyCode

select distinct
	a.AgencyCode,
	p.ProductCode,
	case when (a.CommissionPayTypeID <> 4 and a.CommissionPayTypeID <> 5) then p.ProductCode
		 else case when o.PolicyNo is null then 'Non Credit Card Policies - Net Amounts Payable to Cover-More'
			       else 'Credit Card Policies -  Commission payable to Agent'
			  end
	end as OrderBy,
	a.AgencyStatusCode,
	a.AgencyStatusCode,
	a.BDMName,
	a.AgencyGroupCode,
	a.AgencyName,
	isnull(case when a.AgencyGroupCode = 'FL' then p.GrossPremiumExGSTBeforeDiscount 
			    else p.ActualGrossPremiumAfterDiscount
		   end,0) + isnull(p.GSTonGrossPremium,0)
     as Gross, 
	a.Branch,
	a.AgencyGroupState,
	a.AddressStreet,
	a.AddressSuburb,
	a.AddressState,	
	a.AddressPostCode,
	case when (a.ContactTitle is null or a.ContactFirstName like 'Flight %') then (a.ContactFirstName +' '+ a.ContactLastName)
		  else (a.ContactTitle + ' ' + a.ContactFirstName + ' ' + a.ContactLastName)
	end as ContactName,
	a.ContactTitle,
	a.ContactLastName,
	a.ContactFirstName,
	p.ConsultantInitial,
	p.PolicyNo,
	p.IssuedDate,
	p.CreateDate,
	p.DepartureDate,
	p.PolicyType,
	p.ActualCommissionAfterDiscount,  
	--id = 3 is direct credit agents 
	case when (a.CommissionPayTypeID = 3) then (isnull(p.GrossPremiumExGSTBeforeDiscount,0) + isnull(p.GSTonGrossPremium,0) - isnull(p.CommissionAmount,0) - isnull(p.GSTOnCommission,0) )
		 else (case when o.PolicyNo is null then (isnull(case a.AgencyGroupCode when 'FL' then p.GrossPremiumExGSTBeforeDiscount else p.ActualGrossPremiumAfterDiscount end,0) 
		 + isnull(P.GSTonGrossPremium,0))
		 -(isnull(case when a.AgencyGroupCode = 'FL' then p.CommissionAmount 
					   else p.ActualCommissionAfterDiscount end,0) 
		 + isnull(P.GSTOnCommission,0)) 
		else (- isnull( p.ActualCommissionAfterDiscount, 0) - isnull(P.GSTOnCommission,0)) END) 
	END Nett,
	p.paymentdate,
	a.phone,
	a.FLCountryCode,
	(a.ContactFirstName + ' '+ a.ContactLastName)as Name,
	isnull(p.GSTonGrossPremium,0) as GSTonGrossPremium,
	isnull(p.GSTOnCommission,0)as GSTOnCommission,
	a.ABN,
	a.CommissionPayTypeID,
	isnull(u.Amount,0) as Unallocated,
	isnull(f.Name,'') as AdminExec,
	isnull(f.Phone,'') as Phone,
	isnull(f.Email,'') as AdminEmail,
	f.Fax,
	@rptStartDate as rptStartDate,
	@rptEndDate as rptEndDate
from
	[db-au-cmdwh].dbo.Agency a
	left join #rpt0002a_Unallocated u on 
		a.CountryKey = u.CountryKey and
		a.AgencyCode = u.AgencyCode
	right join [db-au-cmdwh].dbo.Policy p on 
		a.AgencyKey = p.AgencyKey
	left join  [db-au-cmdwh].dbo.OnlinePayment o on
		p.CountryKey = o.CountryKey and
		p.PolicyNo = o.PolicyNo
 --LEFT JOIN trips.dbo.Codes ON P.PPNER = Codes.Code 
	left join [db-au-cmdwh].dbo.Customer m on
		p.CustomerKey = m.CustomerKey and
		p.PolicyNo = m.PolicyNo
	left join [db-au-cmdwh].dbo.FinanceAdmin f on
		f.CountryKey = a.CountryKey and
		f.Initial = a.CustomerServiceInitial 
where
-- for dd's only before 1/1/2008
	p.CreateDate between convert(varchar(10),@rptStartDate,120) and (case when a.CommissionPayTypeID = 5 then '2007-12-31' else convert(varchar(10),@rptEndDate,120) end) and
	((m.CustomerID is null) or (m.CustomerID = (select min(CustomerID) FROM [db-au-cmdwh].dbo.Customer where CustomerKey = p.CustomerKey and ProductCode = p.ProductCode and AgencyCode = p.AgencyCode))) and
	a.AgencyCode between @AgencyCodeFrom and @AgencyCodeTo and
	a.AgencyStatusCode <> 'Z' and
	p.PaymentDate is null and
	isnull(o.PolicyNo,0) = (case when a.CommissionPayTypeID = 3 then 0 else isnull(o.PolicyNo,0) end) --for direct credit agents only cash sales are shown and not credit card sales
order by
	case when (a.CommissionPayTypeID <> 4 and a.CommissionPayTypeID <> 5) then p.ProductCode
		 else case when o.PolicyNo is null then 'Non Credit Card Policies - Net Amounts Payable to Cover-More'
			       else 'Credit Card Policies -  Commission payable to Agent'
			  end
	end


drop table #rpt0002a_Unallocated
GO
