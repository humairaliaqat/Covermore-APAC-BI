USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetBaseRiskNetRatio]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[fn_GetBaseRiskNetRatio] (@CountryPolicyKey varchar(50))
returns float
as
begin

  declare @risknetratio float
  declare @policytype varchar(1)
  declare @oldpolicytype varchar(1)
  declare @oldcountrypolicykey varchar(50)
  declare @result float
  
  select
    @risknetratio = 
    case
      when (GrossPremiumExGSTBeforeDiscount - ActualAdminFee) = 0 then 0
      else RiskNet / (GrossPremiumExGSTBeforeDiscount - ActualAdminFee)
    end,
    @policytype = PolicyType,
    @oldpolicytype = OldPolicyType,
    @oldcountrypolicykey = CountryKey + '-' + convert(varchar(48), OldPolicyNo)
  from Policy
  where CountryPolicyKey = @CountryPolicyKey

  set @result = 0

  if @policytype = 'N' 
    set @result = @risknetratio
    
  else if @policytype = 'R'
    set @result = @risknetratio
    
  else if @policytype is not null
    set @result = dbo.fn_GetBaseRiskNetRatio(@oldcountrypolicykey)
    
  return @result

end

GO
