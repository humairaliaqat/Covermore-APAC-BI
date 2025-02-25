USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1051]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt1051]	@Country varchar(3),
										@Source varchar(100),
										@DateRange varchar(30),
										@StartDate datetime,
										@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt1051
--  Author:         Linus Tor
--  Date Created:   20190620
--  Description:    This stored procedure returns payment registration list in reporting period
--  Parameters:     @Country: Country code
--					@Source: All or one of MIGRATION, CCRECON, MONTHEND, ADJUSTMENT MIGRATION, MANUAL, CARRYFWD
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20190620 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @Country varchar(2)
declare @Source varchar(100)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @Country = 'AU', @Source = 'MANUAL', @DateRange = '_User Defined', @StartDate = '2019-01-01', @EndDate = '2019-01-31'
*/

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

/* prepare source values */
if object_id('tempdb..#source') is not null drop table #source
create table #source
(
	[Source] varchar(100) null
)

if @Source = 'ALL'
	insert #source
	select distinct PaymentSource
	from [db-au-cmdwh].dbo.penPaymentRegister
else
	insert #source values(@source)


select
	p.CountryKey as Country,
	p.CompanyKey as Company,
	pt.PaymentRegisterID,
	crm.CRMUser,
	p.PaymentStatus as PaymentRegisterStatus,
	p.PaymentSource,
	p.Comment,
	pt.CreateDateTime,
	pt.UpdateDateTime,
	pt.Payer,
	pt.BankDate,
	pt.Amount,
	pt.[Status],
	pt.PaymentAllocationID,
	@rptStartDate as StartDate,
	@rptEndDate as EndDate
from
	[db-au-cmdwh].dbo.penPaymentRegister p
	inner join [db-au-cmdwh].dbo.penPaymentRegisterTransaction pt on p.PaymentRegisterKey = pt.PaymentRegisterKey
	outer apply
	(
		select top 1
			UserName as CRMUser
		from
			penCRMUser
		where
			CRMUserKey = p.CRMUserKey			
	)  crm
where
	p.CountryKey = @Country and
	pt.UpdateDateTime >= @rptStartDate and
	pt.UpdateDateTime < dateadd(d,1,@rptEndDate) and
	p.PaymentSource in (select [Source] from #source)
GO
