USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_zurich_tb]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_zurich_tb]
    @Month varchar(30) = 'March',
    @Year int = 2018

as
begin

    declare 
        @start int,
        @end int,
        @period varchar(10)

    select top 1
        @end = SUNPeriod,
        @start = SUNPeriod - datepart(month, [Date]) + 1,
        @period = left(datename(month, [Date]), 3) + ' ' + datename(year, [Date])
    from
        Calendar
    where
        datepart(day, [Date]) = 1 and
        datename(month, [Date]) = @Month and
        datepart(year, [Date]) = @Year

    

    if object_id('tempdb..#gl') is not null
        drop table #gl

    select 
        AccountCode,
        sum
        (
            case
                when gl.Period < @start then gl.GLAmount
                else 0
            end
        ) [Opening balance],
        sum
        (
            case
                when gl.Period >= @start then gl.GLAmount
                else 0
            end
        ) [YTD mvmnt]
    into #gl
    from
        [db-au-cmdwh]..glTransactions gl       
    where
        gl.BusinessUnit = 'CMG' and
        gl.ScenarioCode = 'A' and
        gl.Period <= @end
    group by
        gl.AccountCode

    select 
        a.AccountCode [Account code],
        a.AccountDescription [Account name],
        a.AccountType [Account type],
        a.StatutoryMapping [Statutory reporting mapping],
        a.InternalMapping [Internal reporting mapping],
        isnull(gl.[Opening balance] + gl.[YTD mvmnt], 0) [Balance],
        0 [Adjustments - STI and D&O],
        isnull(gl.[Opening balance], 0) [Opening balance],
        isnull(gl.[YTD mvmnt], 0) [YTD mvmnt],
        isnull(za.GroupAccountNumber, '') [Group Acct],
        isnull(za.GroupAccountNumber, '') + ' ' + drv.[DR/CR] [TOM KEY FIELD],
        drv.[DR/CR],
        a.SAPPE3Account [PE3],
        abs(isnull(gl.[YTD mvmnt], 0)) [Amount in DC Absoluate value],
        @period + ' - ' + a.AccountCode + ' ' + a.AccountDescription [Text],
        case
            when a.SAPPE3Account in ('1449020000', '2950110000') then '400067'
            when a.SAPPE3Account in ('2972100000', '2442100000', '2671000000') then '10000'
            else ''
        end [Trading partners],
        isnull(tom.TOMCode, '') [TOM]
        --,
        --'' [FIP Expense Subassignment],
        --'' [Reclass to 6609000000],
        --a.AccountType [Acc Type]
    from
        [db-au-cmdwh]..glAccounts a
        inner join #gl gl on
            gl.AccountCode = a.AccountCode
        outer apply
        (
            select top 1 
                za.GroupAccountNumber
            from
                [db-au-cmdwh]..glSAPAccounts za
            where
                za.AccountCode = a.SAPPE3Account
        ) za
        cross apply
        (
            select
                case
                    when isnull(gl.[YTD mvmnt], 0) < 0 then '50'
                    else '40'
                end [DR/CR]
        ) drv
        outer apply
        (
            select top 1 
                tom.TOMCode
            from
                [db-au-cmdwh]..glTOMAccounts tom
            where
                tom.TOMKey = isnull(za.GroupAccountNumber, '') + ' ' + drv.[DR/CR]
        ) tom
    where
        isnull(a.SAPPE3Account, '') <> ''
        
end


GO
