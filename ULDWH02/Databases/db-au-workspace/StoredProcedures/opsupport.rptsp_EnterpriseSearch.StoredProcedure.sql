USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [opsupport].[rptsp_EnterpriseSearch]
--declare
    @SearchString varchar(1024) = '',
    @Refresh bit = 0

as
begin

--requirement:
--create type EVSearch as table (CustomerID bigint, ForceInclude bit)

    set nocount on

    --initialize result
    declare @ids EVSearch

    -- user search: start
    if @Refresh = 0
    begin

        insert into @ids
        (
            CustomerID
        )
        select distinct top 20
            CustomerID
        from
            [db-au-workspace].[opsupport].fn_EnterpriseSearch('Blacktown')

    end
    -- user search: stop

    -- daily refresh: start
    if @Refresh = 1
    begin
		
		--20181026, LL, disabled for now, no one uses it in the last 3 months
        --exec [opsupport].[rptsp_EnterpriseSearch_Portfolio]

        declare @searchperiod varchar(30)

        if datename(dw, getdate()) = 'Monday' 
            set @searchperiod = 'Last Friday-To-Now'

        else
            set @searchperiod = 'Yesterday-To-Now'


        insert into @ids
        (
            CustomerID,
            forceInclude
        )
        select
            CustomerID,
            forceInclude
        from
            [db-au-workspace].[opsupport].fn_EnterpriseSearchInPeriod('Last Friday-To-Now', null)
          
        --insert into @ids
        --(
        --    CustomerID,
        --    ForceInclude
        --)
        --select 
        --    AssociatedCustomerID,
        --    1
        --from
        --    [db-au-workspace].[opsupport].[ev_portfolio] t
        --where
        --    not exists
        --    (
        --        select
        --            null
        --        from
        --            @ids r
        --        where
        --            r.CustomerID = t.AssociatedCustomerID
        --    )

    end
    -- daily refresh: stop

    --dump result for other use
    select distinct
        CustomerID
    from
        @ids

    --make sure tables are available
    exec [opsupport].[rptsp_EnterpriseSearch_preparetables]

    --materialize: start
    if @Refresh = 1 
    begin

        truncate table [db-au-workspace].[opsupport].[ev_customer]
        truncate table [db-au-workspace].[opsupport].[ev_contact]
        truncate table [db-au-workspace].[opsupport].[ev_network]
        truncate table [db-au-workspace].[opsupport].[ev_relation]
        truncate table [db-au-workspace].[opsupport].[ev_timeline]
        
    end

    --don't bother refreshing the expensive process below for cached data
    delete 
    from @ids
    where
        CustomerID in
        (
            select
                CustomerID
            from
                [db-au-workspace].[opsupport].[ev_customer]
        )

    --cache main customer list
    exec [db-au-workspace].[opsupport].[rptsp_EnterpriseSearch_Customer]
        @Customer = @ids,
        @Refresh = @Refresh

    if @Refresh = 1
    begin

        --cache contacts
        exec [db-au-workspace].[opsupport].[rptsp_EnterpriseSearch_Contact]
            @Customer = @ids


        --cache relation and network
        exec [db-au-workspace].[opsupport].[rptsp_EnterpriseSearch_Relation]
            @Customer = @ids

        --cache interaction timeline
        exec [db-au-workspace].[opsupport].[rptsp_EnterpriseSearch_Timeline]
            @Customer = @ids

        --distribute: start
        exec [BHDWH03].[db-au-opsupport].[dbo].[rptsp_EnterpriseSearch_copy]
            @Refresh = 1
        --distribute: stop

    end
    --materialize: stop



end

GO
