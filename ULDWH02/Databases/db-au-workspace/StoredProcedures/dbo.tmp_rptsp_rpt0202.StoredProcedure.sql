USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0202]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_rptsp_rpt0202]	
                  @AgencyGroupCode varchar(10),
									@ReportingPeriod varchar(30),
									@StartDate varchar(10),
									@EndDate varchar(10),
									@ReportType varchar(25) = null
as

SET NOCOUNT ON


/****************************************************************************************************/
--	Name:			dbo.rptsp_rpt0202
--	Author:			Linus Tor
--	Date Created:	20110817
--	Description:	This stored procedure returns policy sales for the specified agency and 
--					reporting report.
--	Parameters:		@AgencyCode: value is any valid agency code
--					@ReportingPeriod: value is any standard date range or '_User Defined'
--					@StartDate: Enter user defined start date. Format YYYY-MM-DD eg. 2010-01-01
--					@EndDate: Enter user defined end date. Format YYYY-MM-DD eg. 2010-01-01
--					@ReportType: value is 'OFFSET', 'DIRECTDEBIT', or null (default if called from B2B
--	
--	Change History:	20110817 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @AgencyCode varchar(10)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @ReportType varchar(100)
select @AgencyCode = 'FLQ1305', @ReportingPeriod = 'Current Month', @StartDate = null, @EndDate = null, @ReportType = null
*/

declare @rptStartDate smalldatetime
declare @rptEndDate smalldatetime
declare @Cnt int
declare @DDdone varchar(1)


/* get reporting dates */
if @ReportingPeriod = '_User Defined'
  select @rptStartDate = convert(smalldatetime,@StartDate), @rptEndDate = convert(smalldatetime,@EndDate)
else
  select @rptStartDate = StartDate, @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = @ReportingPeriod


select @cnt = count(*) 
from [db-au-cmdwh].dbo.Policy p
inner join [db-au-cmdwh].dbo.Agency a on a.AgencyKey = p.AgencyKey and a.AgencyStatus = 'Current'
where 
	p.CountryKey = 'AU' and
	a.AgencyGroupCode = @AgencyGroupCode and
	p.CreateDate between @rptStartDate and @rptEndDate and
	p.PaymentDate is null

if @Cnt = 0 select @DDdone = '1'
else select @DDdone = '0'  

if (@ReportType is null or @ReportType = '' or @ReportType not in ('OFFSET','DIRECTDEBIT'))
	select @ReportType = (select case a.CommissionPayTypeID when 1 then 'NOCOMM'
															when 2 then 'DISCOUNT'
															when 3 then 'DIRECTCREDIT'
															when 4 then 'OFFSET'
															when 5 then 'DIRECTDEBIT'
								 end as CommissionTypeDesc
						 from [db-au-cmdwh].dbo.Agency a
						 where a.CountryKey = 'AU' and
							   a.AgencyStatus = 'Current' and
							   a.AgencyGroupCode = @AgencyGroupCode
						)
  

if @ReportType = 'OFFSET'
begin
	select distinct
		a.AgencyCode, 
		convert(varchar(200),case when o.PolicyNo is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'  
			 else 'Credit Card Policies -  Commission payable to Agent'
		end) as ProductType,
		a.AgencyStatusCode,
		a.BDMName,
		a.AgencyGroupCode,
		a.AgencyName,
		isNull(p.GrossPremiumExGSTBeforeDiscount,0) + isNull(p.GSTonGrossPremium,0) as Gross,
		a.Branch,
		null as CLCRL,
		a.AgencyGroupState,
		a.AddressStreet,
		a.AddressSuburb,
		a.AddressState,
		a.AddressPostCode,
		a.ContactTitle,
		a.ContactFirstName,
		a.ContactMiddleInitial,
		a.ContactLastName,
		p.ConsultantInitial,
		null as PPREF,
		p.PolicyNo,
		p.IssuedDate,
		p.CreateDate,
		p.DepartureDate,
		p.PolicyType,
		p.ActualCommissionAfterDiscount,
		p.CommissionAmount,
		case when o.PolicyNo is null then 
				(isNull(p.ActualGrossPremiumAfterDiscount,0) + isNull(p.GSTonGrossPremium,0)) - (isNull(p.ActualCommissionAfterDiscount,0) + isNull(p.GSTonCommission,0))
		     else (-isNull(p.ActualCommissionAfterDiscount,0) - isNull(p.GSTonCommission,0))
		end as Nett, 
		case when o.PolicyNo is null then 'Net Amounts Payable to Cover-More'
			 else 'Credit Card Policies Commission payable to Agent'
	    end as Prdx,
	    p.PaymentDate,
	    a.Phone,
	    a.FLCountryCode,
	    c.FirstName + ' ' + c.LastName as FirstOfPPName,
	    isNull(p.GSTonGrossPremium,0) as GSTonGrossPremium,
	    isNull(p.GSTonCommission,0) as GSTonCommission,
	    a.ABN,
	    0 as PendingDiff,
	    @DDdone as DDDone,
	    @rptStartDate as rptStartDate,
	    @rptEndDate as rptEndDate,
	    @ReportType as ReportType
	from
		[db-au-cmdwh].dbo.Agency a
		right join [db-au-cmdwh].dbo.Policy p on
			a.CountryKey = p.CountryKey and
			a.AgencyKey = p.AgencyKey and
			a.AgencyStatus = 'Current'
		left join [db-au-cmdwh].dbo.OnlinePayment o on
			p.CountryKey = o.CountryKey and
			p.PolicyNo = o.PolicyNo
		left join [db-au-cmdwh].dbo.Customer c on
			p.CountryKey = c.CountryKey and
			p.PolicyNo = c.PolicyNo and
			c.isPrimary = 1
	where
		p.CreateDate between @rptStartDate and @rptEndDate and
		a.AgencyGroupCode = @AgencyGroupCode and
		a.AgencyStatusCode <> 'Z' and		
		a.CommissionPayTypeID = 4 
 ORDER BY  
		convert(varchar(200),case when o.PolicyNo is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'  
			 else 'Credit Card Policies -  Commission payable to Agent'
		end), 
		p.IssuedDate
end
else if @ReportType = 'DIRECTDEBIT'
begin
	select distinct
		a.AgencyCode, 
		convert(varchar(200),case when o.PolicyNo is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'  
			 else 'Credit Card Policies -  Commission payable to Agent'
		end) as ProductType,
		a.AgencyStatusCode,
		a.BDMName,
		a.AgencyGroupCode,
		a.AgencyName,
		isNull(case when a.AgencyGroupCode = 'FL' and o.PolicyNo is null then p.GrossPremiumExGSTBeforeDiscount else p.ActualGrossPremiumAfterDiscount end,0) + isNull(p.GSTonGrossPremium,0) as Gross,
		a.Branch,
		null as CLCRL,
		a.AgencyGroupState,
		a.AddressStreet,
		a.AddressSuburb,
		a.AddressState,
		a.AddressPostCode,
		a.ContactTitle,
		a.ContactFirstName,
		a.ContactMiddleInitial,
		a.ContactLastName,
		p.ConsultantInitial,
		null as PPREF,
		p.PolicyNo,
		p.IssuedDate,
		p.CreateDate,
		p.DepartureDate,
		p.PolicyType,
		p.ActualCommissionAfterDiscount,
		case when a.AgencyGroupCode = 'FL' and o.PolicyNo is null then p.CommissionAmount 
			 else p.ActualCommissionAfterDiscount 
		end as CommissionAmount,
		case when o.PolicyNo is null then 
				(isNull(case when a.AgencyGroupCode = 'FL' then p.GrossPremiumExGSTBeforeDiscount else p.ActualGrossPremiumAfterDiscount end,0) + isNull(p.GSTonGrossPremium,0)) - (isNull(case when a.AgencyGroupCode = 'FL' then p.CommissionAmount else p.ActualCommissionAfterDiscount end,0) + isNull(p.GSTonCommission,0))
		     else (-isNull(p.ActualCommissionAfterDiscount,0) - isNull(p.GSTonCommission,0))
		end as Nett, 
		case when o.PolicyNo is null then 'Net Amounts Payable to Cover-More'
			 else 'Credit Card Policies Commission payable to Agent'
	    end as Prdx,
	    p.PaymentDate,
	    a.Phone,
	    a.FLCountryCode,
	    c.FirstName + ' ' + c.LastName as FirstOfPPName,
	    isNull(p.GSTonGrossPremium,0) as GSTonGrossPremium,
	    isNull(p.GSTonCommission,0) as GSTonCommission,
	    a.ABN,
	    0 as PendingDiff,
	    @DDdone as DDDone,
	    @rptStartDate as rptStartDate,
	    @rptEndDate as rptEndDate,
	    @ReportType as ReportType
	from
		[db-au-cmdwh].dbo.Agency a
		right join [db-au-cmdwh].dbo.Policy p on
			a.CountryKey = p.CountryKey and
			a.AgencyKey = p.AgencyKey and
			a.AgencyStatus = 'Current'
		left join [db-au-cmdwh].dbo.OnlinePayment o on
			p.CountryKey = o.CountryKey and
			p.PolicyNo = o.PolicyNo
		left join [db-au-cmdwh].dbo.Customer c on
			p.CountryKey = c.CountryKey and
			p.PolicyNo = c.PolicyNo and
			c.isPrimary = 1
	where
		p.CreateDate between @rptStartDate and @rptEndDate and
		a.AgencyGroupCode = @AgencyGroupCode and
		a.AgencyStatusCode <> 'Z' and
		a.CommissionPayTypeID = 5
 ORDER BY  
		convert(varchar(200),case when o.PolicyNo is null then 'Non Credit card Policies - Net Amounts Payable to Cover-More'  
			 else 'Credit Card Policies -  Commission payable to Agent'
		end), 
		p.IssuedDate
end
else
begin
	select distinct
		a.AgencyCode, 
		convert(varchar(200),p.ProductCode) as ProductType,
		a.AgencyStatusCode,
		a.BDMName,
		a.AgencyGroupCode,
		a.AgencyName,
		isNull(case when a.AgencyGroupCode = 'FL' and o.PolicyNo is null then p.GrossPremiumExGSTBeforeDiscount else p.ActualGrossPremiumAfterDiscount end,0) + isNull(p.GSTonGrossPremium,0) as Gross,
		a.Branch,
		null as CLCRL,
		a.AgencyGroupState,
		a.AddressStreet,
		a.AddressSuburb,
		a.AddressState,
		a.AddressPostCode,
		a.ContactTitle,
		a.ContactFirstName,
		a.ContactMiddleInitial,
		a.ContactLastName,
		p.ConsultantInitial,
		null as PPREF,
		p.PolicyNo,
		p.IssuedDate,
		p.CreateDate,
		p.DepartureDate,
		p.PolicyType,
		p.ActualCommissionAfterDiscount,
		case when a.AgencyGroupCode = 'FL' and o.PolicyNo is null then p.CommissionAmount 
			 else p.ActualCommissionAfterDiscount 
		end as CommissionAmount,
		case when o.PolicyNo is null then 
				(isNull(case when a.AgencyGroupCode = 'FL' then p.GrossPremiumExGSTBeforeDiscount else p.ActualGrossPremiumAfterDiscount end,0) + isNull(p.GSTonGrossPremium,0)) - (isNull(case when a.AgencyGroupCode = 'FL' then p.CommissionAmount else p.ActualCommissionAfterDiscount end,0) + isNull(p.GSTonCommission,0))
		     else (-isNull(p.ActualCommissionAfterDiscount,0) - isNull(p.GSTonCommission,0))
		end as Nett, 
		case when p.ProductCode = 'TSG' then 'TSG' 
			 else 'CMO'
		end as Prdx,
	    p.PaymentDate,
	    a.Phone,
	    a.FLCountryCode,
	    c.FirstName + ' ' + c.LastName as FirstOfPPName,
	    isNull(p.GSTonGrossPremium,0) as GSTonGrossPremium,
	    isNull(p.GSTonCommission,0) as GSTonCommission,
	    a.ABN,
	    0 as PendingDiff,
	    @DDdone as DDDone,
	    @rptStartDate as rptStartDate,
	    @rptEndDate as rptEndDate,
	    @ReportType as ReportType	    
	from
		[db-au-cmdwh].dbo.Agency a
		right join [db-au-cmdwh].dbo.Policy p on
			a.CountryKey = p.CountryKey and
			a.AgencyKey = p.AgencyKey and
			a.AgencyStatus = 'Current'
		left join [db-au-cmdwh].dbo.OnlinePayment o on
			p.CountryKey = o.CountryKey and
			p.PolicyNo = o.PolicyNo
		left join [db-au-cmdwh].dbo.Customer c on
			p.CountryKey = c.CountryKey and
			p.PolicyNo = c.PolicyNo and
			c.isPrimary = 1
	where
		p.CreateDate between @rptStartDate and @rptEndDate and
		a.AgencyGroupCode = @AgencyGroupCode and
		a.AgencyStatusCode <> 'Z' --and
		--o.PolicyNo is null				--for direct credit agents, only cash sales are shown and not credit card sales
 ORDER BY  
		convert(varchar(200),p.ProductCode), 
		p.IssuedDate,
		p.PolicyNo
end
GO
