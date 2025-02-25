USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_bridgePolicyAddon_New]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE view [dbo].[v_ic_bridgePolicyAddon_New]  
as  
select distinct  
    convert(bigint, PolicySK) PolicySK,  
    AddonGroup,  
    1 BridgeCount  
from  
    [db-au-star]..factPolicyTransactionAddons t with(nolock)
	where PolicySK in (select PolicySK from dimPolicy)  
  
GO
