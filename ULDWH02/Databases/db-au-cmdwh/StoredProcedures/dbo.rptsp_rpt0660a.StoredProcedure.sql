USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0660a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0660a]
as
begin

    set nocount on

    declare 
        @rawdata table
        (
            AlphaCode varchar(255),
            OutletName varchar(255),
            StateArea varchar(255),
            ExtBDMID int,
            ExternalBDMName varchar(255),
            BDMName varchar(255),
            Consultant varchar(255),
            Month varchar(255),
            WeekOfMonth int,
            PolicyNumber varchar(50),
            TransactionStatus varchar(50),
            FirstDateofWeek datetime,
            LastDateofWeek datetime,
            PolicyCount int,
            INTPolicyCount int,
            SellPrice money,
            LYPolicyCount int,
            LYINTPolicyCount int,
            LYSellPrice money
        )

    insert into @rawdata
    exec rptsp_rpt0660

    ;with 
    cte_num as
    (
        select top 200 
            row_number() over(order by [Date]) LineNumber
        from
            Calendar
    ),
    cte_data as
    (
        select 
            Consultant,
            StateArea,
            [Month],
            WeekOfMonth,
            PolicyNumber,
            TransactionStatus,
            sum(INTPolicyCount) EligiblePolicyCount
        from
            @rawdata
        where
            Consultant is not null and
            Consultant not like '%webuser%' 
            --and [Month] = 'March' and WeekOfMonth in (1, 2)
        group by
            Consultant,
            StateArea,
            [Month],
            PolicyNumber,
            TransactionStatus,
            WeekOfMonth
    ),
    cte_selection as
    (
        select 
            Consultant,
            StateArea,
            [Month],
            WeekOfMonth,
            PolicyNumber,
            TransactionStatus,
            rand(row_number() over (order by PolicyNumber)) RNDNum,
            newid() RNDStr,
            sum(EligiblePolicyCount) over (partition by Consultant,StateArea,[Month],WeekOfMonth) FilterCount,
            case
                when TransactionStatus = 'Active' then dense_rank() over (partition by Consultant,StateArea,[Month],WeekOfMonth order by PolicyNumber)
                else 1000
            end PolicyRank
        from
            cte_data t
            --inner join cte_num r on
            --    LineNumber <= EligiblePolicyCount
    )
    select 
        Consultant,
        StateArea,
        [Month],
        WeekOfMonth,
        PolicyNumber,
        TransactionStatus,
        RNDNum,
        RNDStr,
        FilterCount,
        PolicyRank
    from
        cte_selection
    where
        PolicyRank <= FilterCount

end
GO
