USE [db-au-star]
GO
/****** Object:  View [dbo].[vAccountAncestors]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vAccountAncestors] 
/*
    20130701, LS, create
    20141030, LS, add account order
*/
as
    with cte_account
    as
    (
        select
            Account_SK,
            Account_SK Descendant_SK,
            Account_Desc Descendant,
            Parent_Account_SK,
            Account_Code,
            Account_CODE Descendant_Code,
            Account_Desc,
            Account_Order,
            0 Level
        from
            Dim_Account a
        where
            Parent_Account_SK is not null

        union all

        select
            p.Account_SK,
            Descendant_SK,
            Descendant,
            p.Parent_Account_SK,
            p.Account_CODE,
            Descendant_Code,
            p.Account_Desc,
            a.Account_Order,
            Level + 1
        from
            cte_account a
            inner join Dim_Account p on
                p.Account_SK = a.Parent_Account_SK
    )
    select *
    from
        cte_account


GO
