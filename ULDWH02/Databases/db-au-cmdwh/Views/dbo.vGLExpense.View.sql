USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vGLExpense]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vGLExpense] as
with
cte_account
as
(
    select 
        case
            when a1.AccountCode = 'M0003' then a1.AccountDescription
            else a2.AccountDescription
        end ExpenseGroup,
        case
            when a1.AccountCode = 'M0003' then -999999990
            else a2.AccountOrder
        end ExpenseGroupOrder,
        case
            when a1.AccountCode = 'M0003' then a1.AccountDescription
            else a3.AccountDescription
        end ExpenseSubGroup,
        case
            when a1.AccountCode = 'M0003' then -999999990
            else a3.AccountOrder
        end ExpenseSubGroupOrder,
        case
            when a1.AccountCode = 'M0003' then a1.AccountCode
            else a4.AccountCode
        end AccountCode,
        case
            when a1.AccountCode = 'M0003' then a1.AccountDescription
            else a4.AccountDescription
        end AccountDescription,
        a4.AccountOrder
    from
        [db-au-cmdwh].dbo.glAccounts a1 with(nolock)
        left join [db-au-cmdwh].dbo.glAccounts a2 with(nolock) on
            a2.ParentAccountCode = a1.AccountCode
        left join [db-au-cmdwh].dbo.glAccounts a3 with(nolock) on
            a3.ParentAccountCode = a2.AccountCode
        left join [db-au-cmdwh].dbo.glAccounts a4 with(nolock) on
            a4.ParentAccountCode = a3.AccountCode
    where
        a1.ParentAccountCode = 'TC' or
        a1.AccountCode = 'M0003'
),
cte_department
as
(
    select 
        ParentDepartmentDescription ParentDepartment,
        isnull(DepartmentTypeDescription, 'Other') DepartmentType,
        DepartmentCode,
        DepartmentDescription Department
    from
        glDepartments with(nolock)
)
--select --top 100
--    acc.*,
--    dd.*,
--    d.[Date],
--    d.SUNPeriod,
--    isnull(b.BudgetAmount, 0) BudgetAmount,
--    isnull(a.ActualAmount, 0) ActualAmount
--from
--    cte_account acc
--    inner join cte_department dd on
--        1 = 1
--    inner join [db-au-cmdwh].dbo.Calendar d with(nolock) on
--        d.[Date] >= '2018-01-01' and
--        d.[Date] <  '2019-01-01' and
--        datepart(day, d.[Date]) = 1
--    outer apply
--    (
--        select
--            sum(isnull(-b.GLAmount, 0)) BudgetAmount
--        from
--            [db-au-cmdwh].dbo.glTransactions b with(nolock)
--        where
--            b.BusinessUnit = 'CMA' and
--            b.PERIOD = d.SUNPeriod and
--            b.AccountCode = acc.AccountCode and
--            b.DepartmentCode = dd.DepartmentCode and
--            b.JointVentureCode = '11' and
--            b.ScenarioCode = 'B'
--    ) b
--    outer apply
--    (
--        select
--            sum(isnull(-a.GLAmount, 0)) ActualAmount
--        from
--            [db-au-cmdwh].dbo.glTransactions a with(nolock)
--        where
--            a.BusinessUnit = 'CMG' and
--            a.PERIOD = d.SUNPeriod and
--            a.AccountCode = acc.AccountCode and
--            a.DepartmentCode = dd.DepartmentCode and
--            a.ScenarioCode = 'A'
--    ) a
--where
--    b.BudgetAmount is not null or
--    a.ActualAmount is not null
,
cte_combined as
(
    select
        gl.AccountCode,
        gl.DepartmentCode,
        d.[Date],
        sum(isnull(-gl.GLAmount, 0)) BudgetAmount,
        sum(isnull(-gl.GLAmount, 0)) * 0 ActualAmount,
        sum(isnull(-gl.GLAmount, 0)) * 0 LYBudgetAmount,
        sum(isnull(-gl.GLAmount, 0)) * 0 LYActualAmount
    from
        [db-au-cmdwh].dbo.glTransactions gl with(nolock)
        inner join [db-au-cmdwh].dbo.Calendar d with(nolock) on
            d.SUNPeriod = gl.[Period] and
            datepart(day, d.[Date]) = 1 and
            d.[Date] >= '2018-01-01' and
            d.[Date] <  '2019-01-01'
    where
        gl.BusinessUnit = 'CMA' and
        gl.JointVentureCode = '11' and
        gl.ScenarioCode = 'B'
    group by
        gl.AccountCode,
        gl.DepartmentCode,
        d.[Date]

    union all

    select
        gl.AccountCode,
        gl.DepartmentCode,
        d.[Date],
        sum(isnull(-gl.GLAmount, 0)) * 0 BudgetAmount,
        sum(isnull(-gl.GLAmount, 0)) ActualAmount,
        sum(isnull(-gl.GLAmount, 0)) * 0 LYBudgetAmount,
        sum(isnull(-gl.GLAmount, 0)) * 0 LYActualAmount
    from
        [db-au-cmdwh].dbo.glTransactions gl with(nolock)
        inner join [db-au-cmdwh].dbo.Calendar d with(nolock) on
            d.SUNPeriod = gl.[Period] and
            datepart(day, d.[Date]) = 1 and
            d.[Date] >= '2018-01-01' and
            d.[Date] <  '2019-01-01'
    where
        gl.BusinessUnit = 'CMG' and
        gl.ScenarioCode = 'A' and
        gl.AccountCode <> 'M0003'
    group by
        gl.AccountCode,
        gl.DepartmentCode,
        d.[Date]

    union all

    select
        gl.AccountCode,
        gl.DepartmentCode,
        d.[Date],
        sum(isnull(-gl.GLAmount, 0)) * 0 BudgetAmount,
        sum(isnull(-gl.GLAmount, 0)) ActualAmount,
        sum(isnull(-gl.GLAmount, 0)) * 0 LYBudgetAmount,
        sum(isnull(-gl.GLAmount, 0)) * 0 LYActualAmount
    from
        [db-au-cmdwh].dbo.glTransactions gl with(nolock)
        inner join [db-au-cmdwh].dbo.Calendar d with(nolock) on
            d.SUNPeriod = gl.[Period] and
            datepart(day, d.[Date]) = 1 and
            d.[Date] >= '2018-01-01' and
            d.[Date] <  '2019-01-01'
    where
        gl.ScenarioCode = 'A' and
        gl.AccountCode = 'M0003' and
        gl.TransactionReference <> 'Consolidations'
    group by
        gl.AccountCode,
        gl.DepartmentCode,
        d.[Date]
),
cte_calc as
(
    select 
        d.[Date],
        AccountCode,
        DepartmentCode,
        isnull(BudgetAmount, 0) BudgetAmount,
        isnull(ActualAmount, 0) ActualAmount,
        isnull(BudgetAmount, 0) - isnull(ActualAmount, 0) VariancetoBudget,
        --case
            --when d.[Date] < convert(date, convert(varchar(8), getdate(), 120) + '01') then isnull(BudgetAmount, 0)
            --else
            (
                sum(isnull(BudgetAmount, 0)) 
                    over 
                    (
                        partition by 
                            AccountCode,
                            DepartmentCode
                    ) - 
                sum
                (
                    case
                        when d.[Date] < convert(date, convert(varchar(8), getdate(), 120) + '01') then isnull(ActualAmount, 0)
                        else 0
                    end
                )
                    over 
                    (
                        partition by 
                            AccountCode,
                            DepartmentCode
                    ) 
            ) / (12 - datepart(month, getdate()) + 1)
        --end
        RemainingBudget
    from
        [db-au-cmdwh].dbo.Calendar d
        left join cte_combined t on
            t.[Date] = d.[Date]
    where
        datepart(day, d.[Date]) = 1 and
        d.[Date] >= '2018-01-01' and
        d.[Date] <  '2019-01-01'

)
select 
    a.ExpenseGroup,
    a.ExpenseGroupOrder,
    a.ExpenseSubGroup,
    a.ExpenseSubGroupOrder,
    a.AccountCode,
    a.AccountDescription,
    a.AccountOrder,
    d.ParentDepartment,
    d.DepartmentType,
    d.DepartmentCode,
    d.Department,
    t.[Date],
    '' TransactionReference,
    '' Description,
    '' ProjectCode,
    'None' ProjectDescription,
    isnull(t.BudgetAmount, 0) BudgetAmount,
    case
        when t.[Date] >= convert(date, convert(varchar(8), getdate(), 120) + '01') then null
        else isnull(t.ActualAmount, 0) 
    end ActualAmount,
    isnull(t.VariancetoBudget, 0) VariancetoBudget,
    isnull(t.RemainingBudget, 0) RemainingBudget,
    0 GLAmount,
    try_convert(date, t.[Date]) TransactionDate
from
    cte_calc t
    inner join cte_account a on
        t.AccountCode = a.AccountCode
    inner join cte_department d on
        d.DepartmentCode = t.DepartmentCode

union all

select 
    'Total Ex Incentives, DEP, AMO & Capitalised Cost' ExpenseGroup,
    -999999999 ExpenseGroupOrder,
    '' ExpenseSubGroup,
    -999999999 ExpenseSubGroupOrder,
    '' AccountCode,
    '' AccountDescription,
    -999999999 AccountOrder,
    d.ParentDepartment,
    d.DepartmentType,
    d.DepartmentCode,
    d.Department,
    t.[Date],
    '' TransactionReference,
    '' Description,
    '' ProjectCode,
    'None' ProjectDescription,
    isnull(t.BudgetAmount, 0) BudgetAmount,
    case
        when t.[Date] >= convert(date, convert(varchar(8), getdate(), 120) + '01') then null
        else isnull(t.ActualAmount, 0) 
    end ActualAmount,
    isnull(t.VariancetoBudget, 0) VariancetoBudget,
    isnull(t.RemainingBudget, 0) RemainingBudget,
    0 GLAmount,
    try_convert(date, t.[Date]) TransactionDate
from
    cte_calc t
    inner join cte_account a on
        t.AccountCode = a.AccountCode
    inner join cte_department d on
        d.DepartmentCode = t.DepartmentCode
where
    ExpenseGroup not in ('Amortisation', 'Depreciation', 'FTE') and
    ExpenseSubGroup not in ('Incentives') and
    AccountDescription not in ('Capitalised Project (Employment) Costs')

union all

select 
    a.ExpenseGroup,
    a.ExpenseGroupOrder,
    a.ExpenseSubGroup,
    a.ExpenseSubGroupOrder,
    a.AccountCode,
    a.AccountDescription,
    a.AccountOrder,
    d.ParentDepartment,
    d.DepartmentType,
    d.DepartmentCode,
    d.Department,
    dd.[Date],
    gl.TransactionReference,
    gl.Description,
    gl.ProjectCode,
    case
        when rtrim(ltrim(isnull(p.ProjectDescription, ''))) = '' then 'None'
        else ltrim(rtrim(p.ProjectDescription))
    end,
    0 BudgetAmount,
    0 ActualAmount,
    0 VariancetoBudget,
    0 RemainingBudget,
    -gl.GLAmount,
    try_convert(date, gl.TransactionDate)
from
    [db-au-cmdwh].dbo.glTransactions gl with(nolock)
    inner join [db-au-cmdwh].dbo.Calendar dd with(nolock) on
        dd.SUNPeriod = gl.[Period] and
        datepart(day, dd.[Date]) = 1 and
        dd.[Date] >= '2018-01-01' and
        dd.[Date] <  '2019-01-01'
    inner join cte_account a on
        gl.AccountCode = a.AccountCode
    inner join cte_department d on
        d.DepartmentCode = gl.DepartmentCode
    left join glProjects p on
        p.ProjectCode = gl.ProjectCode
where
    gl.BusinessUnit in
    (
        select 
            BusinessUnitCode
        from
            glBusinessUnits
        where
            ParentBusinessUnitCode = 'CMG'
    ) and
    gl.ScenarioCode = 'A' and
    gl.AccountCode <> 'M0003'

--where
--    d.DepartmentCode = '81' and
--    a.AccountCode = '8201'


GO
