USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_Profile]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [opsupport].[rptsp_EnterpriseSearch_Profile]
--declare
    @CustomerID bigint

as
begin

--requirement:
--create type EVSearch as table (CustomerID bigint, ForceInclude bit)

    set nocount on

    --initialize result
    declare @ids EVSearch

    insert into @ids (CustomerID) values (@CustomerID)
    
    --cache contacts
    exec [db-au-workspace].[opsupport].[rptsp_EnterpriseSearch_Contact]
        @Customer = @ids

    --cache relation and network
    exec [db-au-workspace].[opsupport].[rptsp_EnterpriseSearch_Relation]
        @Customer = @ids

    --cache interaction timeline
    exec [db-au-workspace].[opsupport].[rptsp_EnterpriseSearch_Timeline]
        @Customer = @ids


end
GO
