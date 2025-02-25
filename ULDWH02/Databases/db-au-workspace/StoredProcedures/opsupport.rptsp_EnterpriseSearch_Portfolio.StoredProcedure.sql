USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_Portfolio]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [opsupport].[rptsp_EnterpriseSearch_Portfolio]
as
begin

    if object_id('tempdb..#active') is not null
        drop table #active

    create table #active (Reference int)

    insert into #active
    select
        Reference
    from
        [ULSQLGOLD01\E5].[e5_Content_PRD].dbo.Work r with(nolock)
    where
        r.Status_Id = 1 and
        Category2_Id in
        (
            select 
                r.Id
            from  
                [ULSQLGOLD01\E5].[e5_Content_PRD].dbo.Category2 r
            where
                r.Name in ('Claim', 'Phone Call')
                --r.Name in ('Claim', 'Phone Call', 'Complaints', 'Recovery', 'Investigation')
        ) and
        r.CreationDate < convert(date, getdate())


    if object_id('[db-au-workspace].opsupport.ev_portfolio') is null
    begin


        create table [db-au-workspace].opsupport.ev_portfolio
        (
            [BIRowID] bigint not null identity(1,1),
	        [Country] [varchar](max),
	        [Claim Number] [int],
	        [Work Type] [varchar](max),
	        [Date Received] [date],
	        [Absolute Age] [int],
	        [Time in current status] [int],
	        [Team Leader] [varchar](max),
	        [Team Leader Email] [varchar](512),
	        [Assigned User] [varchar](max),
	        [Assigned User Email] [varchar](512),
	        [AssociatedCustomerID] [bigint],
	        [Customer Name] [nvarchar](255),
	        [MDM SortID] [int],
	        [RiskCategory] [varchar](29),
            [e5URL] [varchar](max)
        )

        create unique clustered index idx_ev_portfolio_BIRowID on [db-au-workspace].opsupport.ev_portfolio (BIRowID)
        create nonclustered index ncidx_teamleader on [db-au-workspace].opsupport.ev_portfolio ([Team Leader Email])
        create nonclustered index ncidx_assignee on [db-au-workspace].opsupport.ev_portfolio ([Assigned User Email])

    end

    truncate table [db-au-workspace].opsupport.ev_portfolio

    insert into [db-au-workspace].opsupport.ev_portfolio
    (
	    [Country],
	    [Claim Number],
	    [Work Type],
	    [Date Received],
	    [Absolute Age],
	    [Time in current status],
	    [Team Leader],
        [Team Leader Email],
	    [Assigned User],
        [Assigned User Email],
	    [AssociatedCustomerID],
	    [Customer Name],
	    [MDM SortID],
	    [RiskCategory],
        [e5URL]
    )
    select --top 100
        t.[Country],
        [Claim Number],
        [Work Type],
        [Date Received],
        [Absolute Age],
        [Time in current status],
        [Team Leader],
        case
            when l.EmailAddress is null and t.[Country] = 'AU' then 'Michael.Lazare@covermore.com'
            when l.EmailAddress is null and t.[Country] = 'NZ' then 'Brad.Pinkney@covermore.com'
            else 'Michael.Lazare@covermore.com'
        end [Team Leader Email],
        [Assigned User],
        a.EmailAddress [Assigned User Email],
        isnull(ec.CustomerID, -1) AssociatedCustomerID,
        isnull(ec.CUstomerName, isnull(t.[Customer Name], '')) +
        case
            when t.ProductCode is null then char(10) + '[PNR]'
            when t.ProductCode = 'CMC' then char(10) + '[Corporate]'
            else ''
        end [Customer Name],
        isnull(isnull(BlockFlag, 0) * 100000 + isnull(ec.ClaimScore, ec.PrimaryScore), 9999) [MDM SortID],
        case
            when ec.CustomerID is null then 'Unknown'

            when isnull(BlockScore, 0) > 0 then 'Blocked'
            when ec.ClaimScore >= 3000 then 'Very high risk'
            when ec.ClaimScore >= 500 then 'High risk'
            when ec.ClaimScore >= 10 then 'Medium risk'

            when ec.PrimaryScore >= 5000 then 'Very high risk'
            when ec.SecondaryScore >= 6000 then 'Very high risk by association'
            when ec.PrimaryScore >= 3000 then 'High risk'
            when ec.SecondaryScore >= 4000 then 'High risk by association'
            when ec.PrimaryScore > 1500 then 'Medium risk'
            when ec.SecondaryScore > 2000 then 'Medium risk by association'
            else 'Low Risk'
        end RiskCategory,
        case
            when t.ProductCode is null then 'http://e5.covermore.com/sites/CoverMore/AU/_layouts/15/e5/WorkProcessFrame.aspx?source=FindWork&id=' + convert(varchar(50), w.Original_Work_ID) + '&:linktarget=_blank'
            when t.ProductCode = 'CMC' then 'http://e5.covermore.com/sites/CoverMore/AU/_layouts/15/e5/WorkProcessFrame.aspx?source=FindWork&id=' + convert(varchar(50), w.Original_Work_ID) + '&:linktarget=_blank'
            else ''
        end e5URL
    from
        [db-au-cmdwh].[dbo].vClaimPortfolio t with(nolock)
        inner join [db-au-cmdwh].[dbo].e5Work w on
            w.Reference = t.[e5 Reference]
        left join [db-au-cmdwh].[dbo].entCustomer ec with(nolock) on
            ec.CustomerID = t.AssociatedCustomerID
        outer apply
        (
            select top 1
                9001 BlockScore,
                1 BlockFlag
            from
                [db-au-cmdwh].[dbo].entBlacklist bl with(nolock)
            where
                bl.CustomerID = ec.CustomerID
        ) bl
        outer apply
        (
            select top 1
                isnull(l.EmailAddress, l.UserID) EmailAddress
            from
                [db-au-cmdwh].[dbo].[usrLDAP] l
            where
                l.DisplayName = t.[Team Leader] and
                l.isActive = 1 and
                l.EmailAddress not like '%travelinsurance%'
        ) l
        outer apply
        (
            select top 1
                isnull(l.EmailAddress, l.UserID) EmailAddress
            from
                [db-au-cmdwh].[dbo].[usrLDAP] l
            where
                l.DisplayName = t.[Assigned User] and
                l.isActive = 1 and
                l.EmailAddress not like '%travelinsurance%'
        ) a

    where
        t.[Status] in ('Active') and
        exists
        (
            select
                null
            from
                #active r with(nolock)
            where
                r.Reference = t.[e5 Reference]
        )

end
GO
