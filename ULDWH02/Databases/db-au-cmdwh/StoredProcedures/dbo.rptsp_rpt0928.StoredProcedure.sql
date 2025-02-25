USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0928]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0928]	@DateRange varchar(30),
										@StatementYear varchar(4),
										@StatementMonth varchar(30)
as

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0928
--  Author:         Linus Tor
--  Date Created:   20171116
--  Description:    This stored procedure returns Sun India data for use in RPT0928 - India Consolidated Statement
--  Parameters:     
--					@DateRange: required. valid standard month or _User Defined
--					@StatementYear: required if DateRange = _User Defined 
--					@StatementMonth: required if DateRange = _User Defined
--   
--  Change History: 20171116 - LT - Created
--
/****************************************************************************************************/

set nocount on


--uncomment to debug
/*
declare @DateRange varchar(30), @StatementYear varchar(4), @StatementMonth varchar(30)
select @DateRange = 'Last Month', @StatementYear = null, @StatementMonth = null
*/

declare 
    @period int,
    @bu varchar(10),
    @sql varchar(max),
	@rptStatementYear varchar(4),
	@rptStatementMonth varchar(30)

--gl period
if @DateRange = '_User Defined'
begin
	select top 1 @period = SUNPeriod, @rptStatementYear = @StatementYear, @rptStatementMonth = @StatementMonth 
	from
		Calendar
	where
		datepart(year, [Date]) = @StatementYear and
		datename(month, [Date]) = @StatementMonth and
		datepart(day, [Date]) = 1
end
else
begin
	select top 1 @Period = SUNPeriod, @rptStatementYear = datepart(year,d.StartDate), @rptStatementMonth = datename(month,d.StartDate)
	from 
		Calendar c
		cross apply
		(
			select top 1 StartDate
			from vDateRange
			where DateRange = @DateRange
		) d
	where
		datepart(year,[Date]) = datepart(year,d.StartDate) and
		datename(month,[Date]) = datename(month,d.StartDate) and
		datepart(day,[Date]) = 1			
end


--get branch list      
if object_id('tempdb..#branch') is not null drop table #branch
create table #branch
(
	[Region] varchar(20) null,
    [Branch Code] varchar(50) null,
    [Branch Name] varchar(50) null
)	      

insert #branch
(
	[Region],
	[Branch Code],
	[Branch Name]
)
select
	'East' [Region],
	rtrim(ac.ANL_CODE) [Branch Code],
	rtrim(ac.NAME) [Branch Name]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.EAS_ANL_CODE ac
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.EAS_ANL_CAT cat on
	cat.ANL_CAT_ID = ac.ANL_CAT_ID
where
	cat.S_HEAD = 'STATE' and
	len(ac.ANL_CODE) > 2

union all

select
	'Head office' [Region],
	rtrim(ac.ANL_CODE) [Branch Code],
	rtrim(ac.NAME) [Branch Name]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.HOF_ANL_CODE ac
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.HOF_ANL_CAT cat on
	cat.ANL_CAT_ID = ac.ANL_CAT_ID
where
	cat.S_HEAD = 'STATE' and
	len(ac.ANL_CODE) > 2

union all

select
	'North' [Region],
	rtrim(ac.ANL_CODE) [Branch Code],
	rtrim(ac.NAME) [Branch Name]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.NOR_ANL_CODE ac
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.NOR_ANL_CAT cat on
	cat.ANL_CAT_ID = ac.ANL_CAT_ID
where
	cat.S_HEAD = 'STATE' and
	len(ac.ANL_CODE) > 2

union all

select
	'South' [Region],
	rtrim(ac.ANL_CODE) [Branch Code],
	rtrim(ac.NAME) [Branch Name]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_ANL_CODE ac
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_ANL_CAT cat on
	cat.ANL_CAT_ID = ac.ANL_CAT_ID
where
	cat.S_HEAD = 'STATE' and
	len(ac.ANL_CODE) > 2

union all

select
	'West' [Region],
	rtrim(ac.ANL_CODE) [Branch Code],
	rtrim(ac.NAME) [Branch Name]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.WES_ANL_CODE ac
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.WES_ANL_CAT cat on
	cat.ANL_CAT_ID = ac.ANL_CAT_ID
where
	cat.S_HEAD = 'STATE' and
	len(ac.ANL_CODE) > 2

union all

select
	'Gujarat' [Region],
	rtrim(ac.ANL_CODE) [Branch Code],
	rtrim(ac.NAME) [Branch Name]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.GUJ_ANL_CODE ac
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.GUJ_ANL_CAT cat on
	cat.ANL_CAT_ID = ac.ANL_CAT_ID
where
	cat.S_HEAD = 'STATE' and
	len(ac.ANL_CODE) > 2


--get balances
if object_id('tempdb..#balance') is not null drop table #balance
create table #balance
(
	[Region] varchar(20) null,
    [Debtor Code] varchar(30) null,
    [Account Name] varchar(max) null,
    [Opening Balance] decimal(20,4) null,
    [Closing Balance] decimal(20,4) null
)

insert #balance
(
	[Region],
	[Debtor Code],
	[Account Name],
	[Opening Balance],
	[Closing Balance]
)
select
	'East' [Region],
	rtrim(gl.ACCNT_CODE) [Debtor Code],
	rtrim(ea.DESCR) [Account Name],
	sum(case when gl.[PERIOD] < @period then gl.AMOUNT else 0 end) [Opening Balance],
	sum(gl.AMOUNT) [Closing Balance]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.EAS_A_SALFLDG gl
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.EAS_ACNT ea on ea.ACNT_CODE = gl.ACCNT_CODE
where
	gl.ACCNT_CODE like 'D%' and
	gl.[PERIOD] <= @period
group by
	rtrim(gl.ACCNT_CODE),
	rtrim(ea.DESCR)

union all

select
	'Head office' [Region],
	rtrim(gl.ACCNT_CODE) [Debtor Code],
	rtrim(ea.DESCR) [Account Name],
	sum(case when gl.[PERIOD] < @period then gl.AMOUNT else 0 end) [Opening Balance],
	sum(gl.AMOUNT) [Closing Balance]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.HOF_A_SALFLDG gl
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.HOF_ACNT ea on ea.ACNT_CODE = gl.ACCNT_CODE
where
	gl.ACCNT_CODE like 'D%' and
	gl.[PERIOD] <= @period
group by
	rtrim(gl.ACCNT_CODE),
	rtrim(ea.DESCR)

union all

select
	'North' [Region],
	rtrim(gl.ACCNT_CODE) [Debtor Code],
	rtrim(ea.DESCR) [Account Name],
	sum(case when gl.[PERIOD] < @period then gl.AMOUNT else 0 end) [Opening Balance],
	sum(gl.AMOUNT) [Closing Balance]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.NOR_A_SALFLDG gl
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.NOR_ACNT ea on ea.ACNT_CODE = gl.ACCNT_CODE
where
	gl.ACCNT_CODE like 'D%' and
	gl.[PERIOD] <= @period
group by
	rtrim(gl.ACCNT_CODE),
	rtrim(ea.DESCR)

union all

select
	'South' [Region],
	rtrim(gl.ACCNT_CODE) [Debtor Code],
	rtrim(ea.DESCR) [Account Name],
	sum(case when gl.[PERIOD] < @period then gl.AMOUNT else 0 end) [Opening Balance],
	sum(gl.AMOUNT) [Closing Balance]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_A_SALFLDG gl
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_ACNT ea on ea.ACNT_CODE = gl.ACCNT_CODE
where
	gl.ACCNT_CODE like 'D%' and
	gl.[PERIOD] <= @period
group by
	rtrim(gl.ACCNT_CODE),
	rtrim(ea.DESCR)

union all

select
	'South' [Region],
	rtrim(gl.ACCNT_CODE) [Debtor Code],
	rtrim(ea.DESCR) [Account Name],
	sum(case when gl.[PERIOD] < @period then gl.AMOUNT else 0 end) [Opening Balance],
	sum(gl.AMOUNT) [Closing Balance]
from
	[ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_A_SALFLDG gl
	inner join [ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_ACNT ea on ea.ACNT_CODE = gl.ACCNT_CODE
where
	gl.ACCNT_CODE like 'D%' and
	gl.[PERIOD] <= @period
group by
	rtrim(gl.ACCNT_CODE),
	rtrim(ea.DESCR)


--get transactions
if object_id('tempdb..#tmpTransaction') is not null drop table #tmpTransaction
select 
	'East' [Region],
    rtrim(gl.JRNAL_TYPE) [Journal Type],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.TREFERENCE) [Invoice No],
    rtrim(gl.DESCRIPTN) [Passenger Name],
    rtrim(gl.ANAL_T8) [Certificate No],
    gl.TRANS_DATETIME [Date Of Issue],
	gl.ACCNT_CODE,
	gl.AMOUNT,
    rtrim(gl.ANAL_T3) [Branch Code],
	gl.[PERIOD],
	gl.ANAL_T7
into #tmpTransaction
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.EAS_A_SALFLDG gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
		(
			(
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
			) and
			len(rtrim(gl.ANAL_T7)) > 2
		)
    )

union all

select 
	'Head office' [Region],
    rtrim(gl.JRNAL_TYPE) [Journal Type],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.TREFERENCE) [Invoice No],
    rtrim(gl.DESCRIPTN) [Passenger Name],
    rtrim(gl.ANAL_T8) [Certificate No],
    gl.TRANS_DATETIME [Date Of Issue],
	gl.ACCNT_CODE,
	gl.AMOUNT,
    rtrim(gl.ANAL_T3) [Branch Code],
	gl.[PERIOD],
	gl.ANAL_T7
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.HOF_A_SALFLDG gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
		(
			(
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
			) and
			len(rtrim(gl.ANAL_T7)) > 2
		)
    )

union all

select 
	'North' [Region],
    rtrim(gl.JRNAL_TYPE) [Journal Type],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.TREFERENCE) [Invoice No],
    rtrim(gl.DESCRIPTN) [Passenger Name],
    rtrim(gl.ANAL_T8) [Certificate No],
    gl.TRANS_DATETIME [Date Of Issue],
	gl.ACCNT_CODE,
	gl.AMOUNT,
    rtrim(gl.ANAL_T3) [Branch Code],
	gl.[PERIOD],
	gl.ANAL_T7
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.NOR_A_SALFLDG gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
		(
			(
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
			) and
			len(rtrim(gl.ANAL_T7)) > 2
		)
    )

union all

select 
	'South' [Region],
    rtrim(gl.JRNAL_TYPE) [Journal Type],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.TREFERENCE) [Invoice No],
    rtrim(gl.DESCRIPTN) [Passenger Name],
    rtrim(gl.ANAL_T8) [Certificate No],
    gl.TRANS_DATETIME [Date Of Issue],
	gl.ACCNT_CODE,
	gl.AMOUNT,
    rtrim(gl.ANAL_T3) [Branch Code],
	gl.[PERIOD],
	gl.ANAL_T7
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_A_SALFLDG gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
		(
			(
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
			) and
			len(rtrim(gl.ANAL_T7)) > 2
		)
    )

union all

select 
	'West' [Region],
    rtrim(gl.JRNAL_TYPE) [Journal Type],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.TREFERENCE) [Invoice No],
    rtrim(gl.DESCRIPTN) [Passenger Name],
    rtrim(gl.ANAL_T8) [Certificate No],
    gl.TRANS_DATETIME [Date Of Issue],
	gl.ACCNT_CODE,
	gl.AMOUNT,
    rtrim(gl.ANAL_T3) [Branch Code],
	gl.[PERIOD],
	gl.ANAL_T7
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.WES_A_SALFLDG gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
		(
			(
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
			) and
			len(rtrim(gl.ANAL_T7)) > 2
		)
    )

union all

select 
	'Gujarat' [Region],
    rtrim(gl.JRNAL_TYPE) [Journal Type],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.TREFERENCE) [Invoice No],
    rtrim(gl.DESCRIPTN) [Passenger Name],
    rtrim(gl.ANAL_T8) [Certificate No],
    gl.TRANS_DATETIME [Date Of Issue],
	gl.ACCNT_CODE,
	gl.AMOUNT,
    rtrim(gl.ANAL_T3) [Branch Code],
	gl.[PERIOD],
	gl.ANAL_T7
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.GUJ_A_SALFLDG gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
		(
			(
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
			) and
			len(rtrim(gl.ANAL_T7)) > 2
		)
    )


if object_id('tempdb..#transaction') is not null drop table #transaction
create table #transaction
(
	[Region] varchar(20),
    [Journal Type] varchar(30),
    [Journal No] int,
    [Journal Line] int,
    [Invoice No]  varchar(30),
    [Passenger Name] varchar(50),
    [Certificate No] varchar(30),
    [Date Of Issue] datetime,
    [Trawelltag Fees] decimal(20,4),
    [Service Tax] decimal(20,4),
    [Service GST] decimal(20,4),
    [Net Charges] decimal(20,4),
    [Upfront Comm] decimal(20,4),
	[Comm] decimal(20,4),
    [TDS] decimal(20,4),
    [Net Comm] decimal(20,4),
    [Discount] decimal(20,4),
    [Cancellation Charges] decimal(20,4),
    [Cancellation GST] decimal(20,4),
    [Receipts] decimal(20,4),
    [Debtor Code] varchar(30),
    [Branch Code] varchar(30)		
)

insert into #transaction
(
	[Region],
    [Journal Type],
    [Journal No],
    [Journal Line],
    [Invoice No],
    [Passenger Name],
    [Certificate No],
    [Date Of Issue],
    [Trawelltag Fees],
    [Service Tax],
    [Service GST],
    [Net Charges],
    [Upfront Comm],
	[Comm],
    [TDS],
    [Net Comm],
    [Discount],
    [Cancellation Charges],
    [Cancellation GST],
    [Receipts],
    [Debtor Code],
    [Branch Code]
)
select
	gl.Region,
	gl.[Journal Type],
	gl.[Journal No],
	gl.[Journal Line],
	gl.[Invoice No],
	gl.[Passenger Name],
	gl.[Certificate No],
	gl.[Date Of Issue],
	r.[Trawelltag Fees],
	r.[Service Tax],
	r.[Service GST],
	r.[Trawelltag Fees] + r.[Service Tax] + r.[Service GST] [Net Charges],
	r.[Upfront Comm],
	r.[Comm],
	r.[TDS],
	r.[Upfront Comm] + r.[TDS] + r.[Comm] [Net Comm],
	r.[Discount],
	r.[Cancellation Charges],
	r.[Cancellation GST],
	case
		when gl.ACCNT_CODE like 'D%' then gl.AMOUNT
		else 0
	end [Receipts],
	case
		when gl.ACCNT_CODE like 'D%' then rtrim(gl.ACCNT_CODE)
		else rtrim(gl.ANAL_T7) 
	end [Debtor Code],
	gl.[Branch Code]
from
	#tmpTransaction gl
	cross apply
	(
		select
			case when gl.ACCNT_CODE = '4700' then gl.AMOUNT else 0 end [Trawelltag Fees],
			case when gl.ACCNT_CODE = '2120' then gl.AMOUNT else 0 end [Service Tax],
			case when gl.ACCNT_CODE = '2120A' then gl.AMOUNT
				 when gl.ACCNT_CODE = '2120B' then gl.AMOUNT
				 else 0
			end [Service GST],
			case when gl.ACCNT_CODE = '2120C' then gl.AMOUNT else 0 end [Cancellation GST],
			case when gl.ACCNT_CODE = '5250' then gl.AMOUNT else 0 end [Upfront Comm],
			case when gl.ACCNT_CODE = '5200' then gl.AMOUNT else 0 end [Comm],
			case when gl.ACCNT_CODE like '2161E%' then gl.AMOUNT else 0 end [TDS],
			case when gl.ACCNT_CODE =  '5210' then gl.AMOUNT else 0 end [Discount],
			case when gl.ACCNT_CODE = '4100' then gl.AMOUNT else 0 end [Cancellation Charges]
	) r


--get notes
if object_id('tempdb..#notes') is not null drop table #notes
create table #notes
(
	[Region] varchar(20) null,
    [Journal No] int null,
    [Journal Line] int null,
    [Credit Note] varchar(30) null
)

insert into #notes
(
	[Region],
	[Journal No],
	[Journal Line],
	[Credit Note]
)
select
	'East' [Region],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.GNRL_DESCR_01) [Credit Note]
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.EAS_A_SALFLDG_LAD gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
        (
            (
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
            ) 
        )
    )

union all

select
	'Head office' [Region],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.GNRL_DESCR_01) [Credit Note]
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.HOF_A_SALFLDG_LAD gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
        (
            (
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
            ) 
        )
    )

union all

select
	'North' [Region],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.GNRL_DESCR_01) [Credit Note]
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.NOR_A_SALFLDG_LAD gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
        (
            (
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
            ) 
        )
    )

union all

select
	'South' [Region],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.GNRL_DESCR_01) [Credit Note]
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.SOU_A_SALFLDG_LAD gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
        (
            (
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
            ) 
        )
    )

union all

select
	'West' [Region],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.GNRL_DESCR_01) [Credit Note]
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.WES_A_SALFLDG_LAD gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
        (
            (
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
            ) 
        )
    )

union all

select
	'Gujarat' [Region],
    gl.JRNAL_NO [Journal No],
    gl.JRNAL_LINE [Journal Line],
    rtrim(gl.GNRL_DESCR_01) [Credit Note]
from
    [ULSQLSILV05].[SunSystemsData_IND].dbo.GUJ_A_SALFLDG_LAD gl
where
    gl.[PERIOD] = @period and
    (
		gl.ACCNT_CODE like 'D%' or
        (
            (
				gl.ACCNT_CODE in ('4700','2120','2120A','2120B','2120C','5250','5210','5200','4100','2120') or
				gl.ACCNT_CODE like '2161E%'
            ) 
        )
    )

create index cn_idx on #notes ([Region], [Journal Line],[Journal No]) include ([Credit Note])


;with 
cte_raw
as
(
    select 
		[Region],
        [Journal Type],
        [Journal No],
        [Journal Line],
        [Invoice No],
        [Passenger Name],
        [Certificate No],
        [Date Of Issue],
        [Trawelltag Fees],
        [Service Tax],
        [Service GST],
        [Net Charges],
        [Upfront Comm],
		[Comm],
        [TDS],
        [Net Comm],
        [Discount],
        [Cancellation Charges],
        [Cancellation GST],
        [Receipts],
        isnull(cn.[Credit Note], '') [Credit Note],
        [Debtor Code],
        [Branch Code],
        b.[Branch Name],
        bl.[Account Name],
        isnull(bl.[Opening Balance], 0) [Opening Balance],
        isnull(bl.[Closing Balance], 0) [Closing Balance]
    from
        #transaction gl
        outer apply
        (
            select top 1 
                [Credit Note]
            from
                #notes cn
            where
				cn.[Region] = gl.[Region] and
                cn.[Journal No] = gl.[Journal No] and
                cn.[Journal Line] = gl.[Journal Line]
        ) cn
        outer apply
        (
            select top 1 
                bl.[Account Name],
                bl.[Opening Balance],
                bl.[Closing Balance]
            from
                #balance bl
            where
				bl.[Region] = gl.[Region] and
                bl.[Debtor Code] = gl.[Debtor Code]
        ) bl
        outer apply
        (
            select top 1
                b.[Branch Name]
            from
                #branch b
            where
				b.[Region] = gl.[Region] and
                b.[Branch Code] = gl.[Branch Code]
        ) b
),
cte_agg as
(
    select
		[Region],
        [Journal Type],
        [Invoice No],
        [Passenger Name],
        [Certificate No],
        [Date Of Issue],
        sum([Trawelltag Fees]) [Trawelltag Fees],
        sum([Service Tax]) [Service Tax],
        sum([Service GST]) [Service GST],
        sum([Net Charges]) [Net Charges],
        sum([Upfront Comm]) [Upfront Comm],
		sum([Comm]) [Comm],
        sum([TDS]) [TDS],
        sum([Net Comm]) [Net Comm],
        sum([Discount]) [Discount],
        sum([Cancellation Charges]) [Cancellation Charges],
        sum([Cancellation GST]) [Cancellation GST],
        sum([Receipts]) [Receipts],
        [Credit Note],
        [Debtor Code],
        [Branch Code],
        [Branch Name],
        [Account Name],
        max([Opening Balance]) [Opening Balance],
        max([Closing Balance]) [Closing Balance]
    from
        cte_raw
    group by
		[Region],
        [Journal Type],
        [Invoice No],
        [Passenger Name],
        [Certificate No],
        [Date Of Issue],
        [Credit Note],
        [Debtor Code],
        [Branch Code],
        [Branch Name],
        [Account Name]
),
cte_out as
(
    select
		[Region],
        [Journal Type],
        [Invoice No],
        [Passenger Name],
        [Certificate No],
        [Date Of Issue],
        [Trawelltag Fees],
        case
            when [Service Tax] < 0 then 0
            else [Service Tax]
        end [Service Tax],
        [Service GST],
        [Net Charges],
        [Upfront Comm],
		[Comm],
        [TDS],
        [Net Comm],
        [Discount],
        [Cancellation Charges],
        [Cancellation GST],
        case
            when [Service Tax] < 0 then [Service Tax]
            else 0
        end [Service Tax Canx],
        [Credit Note],
        [Debtor Code],
        max([Branch Code]) over (partition by [Debtor Code]) [Branch Code],
        max([Branch Name]) over (partition by [Debtor Code]) [Branch Name],
        [Account Name],
        -(case
            when [Journal Type] = 'GJ' and Receipts = 0 then 
                [Trawelltag Fees] + 
                [Service Tax] + 
                [Service GST] + 
                [Upfront Comm] + 
				[Comm] + 
                [TDS] + 
                [Discount] + 
                [Cancellation Charges] +
                [Cancellation GST]
            else [Receipts]
        end) [Net Bill],
        [Opening Balance],
        [Closing Balance]
    from
        cte_agg
)
select 
	[Region],
	[Journal Type],
	[Invoice No],
	[Passenger Name],
	[Certificate No],
	[Date Of Issue],
	[Trawelltag Fees],
	[Service Tax],
	[Service GST],
	[Net Charges],
	[Upfront Comm],
	[Comm],
	[TDS],
	[Net Comm],
	[Discount],
	[Cancellation Charges],
	[Cancellation GST],
	[Service Tax Canx],
	[Credit Note],
	[Debtor Code],
	[Branch Code],
	[Branch Name],
	[Account Name],
	[Net Bill],
	[Opening Balance],
	[Closing Balance],
	@rptStatementYear as StatementYear,
	@rptStatementMonth as StatementMonth
from
    cte_out
GO
