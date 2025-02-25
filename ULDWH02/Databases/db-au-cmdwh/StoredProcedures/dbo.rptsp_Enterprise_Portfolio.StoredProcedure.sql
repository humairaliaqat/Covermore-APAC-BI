USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_Enterprise_Portfolio]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_Enterprise_Portfolio]
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


    if object_id('[db-au-workspace]..live_dashboard_portfolio') is null
        create table [db-au-workspace]..live_dashboard_portfolio
        (
	        [Country] [varchar](max),
	        [Claim Number] [int],
	        [Work Type] [varchar](max),
	        [Date Received] [date],
	        [Absolute Age] [int],
	        [Time in current status] [int],
	        [Team Leader] [varchar](max),
	        [Assigned User] [varchar](max),
	        [AssociatedCustomerID] [bigint],
	        [Customer Name] [nvarchar](255),
	        [MDM SortID] [int],
	        [RiskCategory] [varchar](29),
            [e5URL] [varchar](max)
        )

    truncate table [db-au-workspace]..live_dashboard_portfolio

    insert into [db-au-workspace]..live_dashboard_portfolio
    (
	    [Country],
	    [Claim Number],
	    [Work Type],
	    [Date Received],
	    [Absolute Age],
	    [Time in current status],
	    [Team Leader],
	    [Assigned User],
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
        [Assigned User],
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
        vClaimPortfolio t with(nolock)
        inner join e5Work w on
            w.Reference = t.[e5 Reference]
        left join entCustomer ec with(nolock) on
            ec.CustomerID = t.AssociatedCustomerID
        outer apply
        (
            select top 1
                9001 BlockScore,
                1 BlockFlag
            from
                entBlacklist bl with(nolock)
            where
                bl.CustomerID = ec.CustomerID
        ) bl
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
