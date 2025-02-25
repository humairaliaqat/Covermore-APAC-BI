USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0877]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0877]
    @Region varchar(30),
    @Branch varchar(30),
    @DebtorCode varchar(max),
	@DateRange varchar(30),
    @StatementYear varchar(4),
    @StatementMonth varchar(30)

as

begin



/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0877
--  Author:         Leonardus Li
--  Date Created:   20170721
--  Description:    This stored procedure returns Sun India data for use in RPT0877 - India Statement
--  Parameters:     
--					@Region: required. All or valid region
--					@Branch: required. All or valid branch
--					@DebtorCode: required. All or valid debtor code
--					@DateRange: required. valid standard month or _User Defined
--					@StatementYear: required if DateRange = _User Defined 
--					@StatementMonth: required if DateRange = _User Defined
--   
--  Change History: 20170721 - LL - Created
--					20170825 - LL - Proper stored procedure
--					20171026 - LT - Added Comm Code 5200.
--									Net Comm also includes Comm Code 5200
--									Net Bill also includes Comm Code 5200
--					20171108 - LT - Added DateRange parameter. This is required for report scheduling
--					20171114 - LT - Added Region output column
--
/****************************************************************************************************/

    set nocount on

	--uncomment to debug
/*
    declare @Region varchar(30), @Branch varchar(30), @DebtorCode varchar(max), @DateRange varchar(30), @StatementYear varchar(4), @StatementMonth varchar(30)
	select @Region = 'West', @Branch = 'ALL', @DebtorCode = 'D9267', @DateRange = 'Last Month', @StatementYear = null, @StatementMonth = null
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


    --gl business unit
    select 
        @bu = rtrim(BusinessUnitCode)
    from
        glBusinessUnits
    where
        ParentBusinessUnitCode = 'IND' and
        BusinessUnitDescription = 'Cover-More India - ' + @Region

    --get branch list
    if object_id('tempdb..#branch') is not null
        drop table #branch

    create table #branch
    (
        [Branch Code] varchar(50),
        [Branch Name] varchar(50)
    )

    set @sql =
        '
        select 
            [Branch Code],
            [Branch Name]
        from
            openquery
            (
                [ULSQLSILV05],
                ''
                select
                    rtrim(ac.ANL_CODE) [Branch Code],
                    rtrim(ac.NAME) [Branch Name]
                from
                    [SunSystemsData_IND].dbo.' + @bu + '_ANL_CODE ac
                    inner join [SunSystemsData_IND].dbo.' + @bu + '_ANL_CAT cat on
                        cat.ANL_CAT_ID = ac.ANL_CAT_ID
                where
                    cat.S_HEAD = ''''STATE'''' and
                    len(ac.ANL_CODE) > 2
                ''
            )
        '

    insert into #branch
    (
        [Branch Code],
        [Branch Name]
    )
    exec (@sql)


    --balances
    if object_id('tempdb..#balance') is not null
        drop table #balance

    create table #balance
    (
        [Debtor Code] varchar(30),
        [Account Name] varchar(max),
        [Opening Balance] decimal(20,4),
        [Closing Balance] decimal(20,4)
    )

    set @sql =
        '
        select 
            [Debtor Code],
            [Account Name],
            isnull([Opening Balance], 0) [Opening Balance],
            isnull([Closing Balance], 0) [Closing Balance]
        from
            openquery
            (
                [ULSQLSILV05],
                ''
                select
                    rtrim(gl.ACCNT_CODE) [Debtor Code],
                    rtrim(ea.DESCR) [Account Name],
                    sum
                    (
                        case
                            when PERIOD < ' + convert(varchar, @period) + ' then gl.AMOUNT
                            else 0
                        end
                    ) [Opening Balance],
                    sum(gl.AMOUNT) [Closing Balance]
                from
                    [SunSystemsData_IND].dbo.' + @bu + '_A_SALFLDG gl
                    inner join [SunSystemsData_IND].dbo.' + @bu + '_ACNT ea on
                        ea.ACNT_CODE = gl.ACCNT_CODE
                where
                    gl.ACCNT_CODE like ''''D%'''' and
                    PERIOD <= ' + convert(varchar, @period) + '
                group by
                    rtrim(gl.ACCNT_CODE),
                    rtrim(ea.DESCR)
                ''
            )
        '

    --print @sql
    insert into #balance
    (
        [Debtor Code],
        [Account Name],
        [Opening Balance],
        [Closing Balance]
    )
    exec (@sql)


    --in period transaction
    if object_id('tempdb..#transaction') is not null
        drop table #transaction

    create table #transaction
    (
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

    set @sql =
        '
        select 
            [Journal Type],
            [Journal No],
            [Journal Line],
            [Invoice No],
            [Passenger Name],
            [Certificate No],
            [Date Of Issue],
            isnull([Trawelltag Fees], 0) [Trawelltag Fees],
            isnull([Service Tax], 0) [Service Tax],
            isnull([Service GST], 0) [Service GST],
            isnull([Net Charges], 0) [Net Charges],
            isnull([Upfront Comm], 0) [Upfront Comm],
			isnull([Comm], 0) [Comm],
            isnull([TDS], 0) [TDS],
            isnull([Net Comm], 0) [Net Comm],
            isnull([Discount], 0) [Discount],
            isnull([Cancellation Charges], 0) [Cancellation Charges],
            isnull([Cancellation GST], 0) [Cancellation GST],
            isnull([Receipts], 0) [Receipts],
            [Debtor Code],
            [Branch Code]
        from
            openquery
            (
                [ULSQLSILV05],
                ''
                select 
                    rtrim(gl.JRNAL_TYPE) [Journal Type],
                    gl.JRNAL_NO [Journal No],
                    gl.JRNAL_LINE [Journal Line],
                    rtrim(gl.TREFERENCE) [Invoice No],
                    rtrim(gl.DESCRIPTN) [Passenger Name],
                    rtrim(gl.ANAL_T8) [Certificate No],
                    gl.TRANS_DATETIME [Date Of Issue],
                    [Trawelltag Fees],
                    [Service Tax],
                    [Service GST],
                    [Trawelltag Fees] + [Service Tax] + [Service GST] [Net Charges],
                    [Upfront Comm],
					[Comm],
                    [TDS],
                    [Upfront Comm] + [TDS] + [Comm] [Net Comm],
                    [Discount],
                    [Cancellation Charges],
                    [Cancellation GST],
                    case
                        when gl.ACCNT_CODE like ''''D%'''' then gl.AMOUNT
                        else 0
                    end [Receipts],
                    case
                        when gl.ACCNT_CODE like ''''D%'''' then rtrim(gl.ACCNT_CODE)
                        else rtrim(gl.ANAL_T7) 
                    end [Debtor Code],
                    rtrim(gl.ANAL_T3) [Branch Code]
                from
                    [SunSystemsData_IND].dbo.' + @bu + '_A_SALFLDG gl
                    cross apply
                    (
                        select
                            case
                                when gl.ACCNT_CODE = ''''4700'''' then AMOUNT
                                else 0
                            end [Trawelltag Fees],
                            case
                                when gl.ACCNT_CODE = ''''2120'''' then AMOUNT
                                else 0
                            end [Service Tax],
                            case
                                when gl.ACCNT_CODE = ''''2120A'''' then AMOUNT
                                when gl.ACCNT_CODE = ''''2120B'''' then AMOUNT
                                else 0
                            end [Service GST],
                            case
                                when gl.ACCNT_CODE = ''''2120C'''' then AMOUNT
                                else 0
                            end [Cancellation GST],
                            case
                                when gl.ACCNT_CODE = ''''5250'''' then AMOUNT
                                else 0
                            end [Upfront Comm],
                            case
                                when gl.ACCNT_CODE = ''''5200'''' then AMOUNT
                                else 0
                            end [Comm],
                            case
                                when gl.ACCNT_CODE like ''''2161E%'''' then AMOUNT
                                else 0
                            end [TDS],
                            case
                                when gl.ACCNT_CODE = ''''5210'''' then AMOUNT
                                else 0
                            end [Discount],
                            case
                                when gl.ACCNT_CODE = ''''4100'''' then AMOUNT
                                else 0
                            end [Cancellation Charges]
                    ) r
                where
                    gl.PERIOD = ' + convert(varchar, @period) + ' and
                    (
                        (
                            gl.ACCNT_CODE like ''''D%''''
                        ) or
                        (
                            (
                                gl.ACCNT_CODE in 
                                (
                                    ''''4700'''', 
                                    ''''2120'''', 
                                    ''''2120A'''', 
                                    ''''2120B'''', 
                                    ''''2120C'''', 
                                    ''''5250'''', 
                                    ''''5210'''', 
									''''5200'''',
                                    ''''4100'''', 
                                    ''''2120''''
                                ) or
                                gl.ACCNT_CODE like ''''2161E%''''
                            ) and
                            len(rtrim(gl.ANAL_T7)) > 2
                        )
                    )
                ''
            )
        '

    insert into #transaction
    (
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
    exec (@sql)


    --notes
    if object_id('tempdb..#notes') is not null
        drop table #notes

    create table #notes
    (
        [Journal No] int,
        [Journal Line] int,
        [Credit Note] varchar(30)
    )

    set @sql =
        '
        select 
            [Journal No],
            [Journal Line],
            isnull([Credit Note], '''') [Credit Note]
        from
            openquery
            (
                [ULSQLSILV05],
                ''
                select 
                    gl.JRNAL_NO [Journal No],
                    gl.JRNAL_LINE [Journal Line],
                    rtrim(gl.GNRL_DESCR_01) [Credit Note]
                from
                    [SunSystemsData_IND].dbo.' + @bu + '_A_SALFLDG_LAD gl
                where
                    gl.PERIOD = ' + convert(varchar, @period) + ' and
                    (
                        (
                            gl.ACCNT_CODE like ''''D%''''
                        ) or
                        (
                            (
                                gl.ACCNT_CODE in 
                                (
                                    ''''4700'''', 
                                    ''''2120'''', 
                                    ''''2120A'''', 
                                    ''''2120B'''', 
                                    ''''2120C'''', 
                                    ''''5250'''', 
                                    ''''5210'''', 
									''''5200'''',
                                    ''''4100'''', 
                                    ''''2120''''
                                ) or
                                gl.ACCNT_CODE like ''''2161E%''''
                            ) 
                        )
                    )
                ''
            )
        '

    --print @sql
    insert into #notes
    (
        [Journal No],
        [Journal Line],
        [Credit Note]
    )
    exec (@sql)

    create index cn_idx on #notes ([Journal Line],[Journal No]) include ([Credit Note])

    ;with 
    cte_raw
    as
    (
        select 
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
                    bl.[Debtor Code] = gl.[Debtor Code]
            ) bl
            outer apply
            (
                select top 1
                    b.[Branch Name]
                from
                    #branch b
                where
                    b.[Branch Code] = gl.[Branch Code]
            ) b
    ),
    cte_agg as
    (
        select
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
		@rptStatementMonth as StatementMonth,
		@Region as Region
    from
        cte_out
    where
        (
            @Branch = 'ALL' or
            [Branch Name] = @Branch
        ) and
        (
            @DebtorCode = 'ALL' or
            [Debtor Code] in
            (
                select 
                    Item
                from
                    dbo.fn_DelimitedSplit8K(@DebtorCode, ',')
            )
        )

end
GO
