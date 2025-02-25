USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_reset]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [opsupport].[rptsp_EnterpriseSearch_reset]
    @CustomerID bigint

as
begin

    delete
    from
        [uldwh02].[db-au-workspace].opsupport.ev_customer
    where
        CustomerID = @CustomerID

    delete 
    from
        [uldwh02].[db-au-workspace].opsupport.ev_contact
    where
        CustomerID = @CustomerID

    delete 
    from
        [uldwh02].[db-au-workspace].opsupport.ev_network
    where
        CustomerID = @CustomerID

    delete 
    from
        [uldwh02].[db-au-workspace].opsupport.ev_relation
    where
        CustomerID = @CustomerID

    delete 
    from
        [uldwh02].[db-au-workspace].opsupport.ev_timeline
    where
        Who = @CustomerID

    delete
    from
        [bhdwh03].[db-au-opsupport].dbo.ev_customer
    where
        CustomerID = @CustomerID

    delete 
    from
        [bhdwh03].[db-au-opsupport].dbo.ev_contact
    where
        CustomerID = @CustomerID

    delete 
    from
        [bhdwh03].[db-au-opsupport].dbo.ev_network
    where
        CustomerID = @CustomerID

    delete 
    from
        [bhdwh03].[db-au-opsupport].dbo.ev_timeline
    where
        Who = @CustomerID


end
GO
