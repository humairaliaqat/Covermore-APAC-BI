USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vpenPolicyPlanCode_test]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[vpenPolicyPlanCode_test]
/*
    20140204 - LS - copied from TRIPS.PenguinPull_PolicyTransaction & Penguin.TRIPSGetPolicyPlan
	20181108 - LT - use penPolicy.PlanCode. if null, then try to extract from penProductPlan
	20181204 - LT - excludes UK from using penPolicy.PlanCode	
*/
as
select
    pt.PolicyTransactionKey,
	case when p.CountryKey <> 'UK' and p.isTripsPolicy = 0 and p.PlanCode is not null then p.PlanCode
	     else
			case pt.CountryKey 
				when 'NZ' then 
				case 
					when IsExpo = 1 then 
					case 
						when pp.PlanCode = 'C' then
						case p.TripCost
							when 'C-$200' then 'XA2'
							when 'C-$400' then 'XA4'
							when 'C-$600' then 'XA6'
							when 'C-$800' then 'XA8'
							when 'C-$1,500' then 'XA15'
							else 'X' + substring(pp.PlanCode, 2, len(pp.PlanCode))
						end 
						when left(pp.PlanCode, 1) = 'C' then 'X' + replace(pp.PlanCode, substring(pp.PlanCode, 2, 1), '')
						else 'X' + substring(pp.PlanCode, 2, len(pp.PlanCode)) 
					end
					when IsAgentSpecial = 1 then substring(pp.PlanCode, 3, len(pp.PlanCode))
					else 
					case 
						when pp.PlanCode = 'C' then
						case p.TripCost
							when 'C-$200' then 'C2'
							when 'C-$400' then 'C4'
							when 'C-$600' then 'C6'
							when 'C-$800' then 'C8'
							when 'C-$1,500' then 'C15'
							else pp.PlanCode
						end 
						else pp.PlanCode 
					end
				end 			
				else 
				case    
					when IsExpo = 1 then 
					case 
						when pp.PlanCode in ('DA2', 'DA') then
						case p.TripCost
							when 'DA-$200' then 'XA2'
							when 'DA-$400' then 'XA4'
							when 'DA-$600' then 'XA6'
							when 'DA-$800' then 'XA8'
							when 'DA-$1,500' then 'XA15'  
							else  'X' + substring(pp.PlanCode, 2, len(pp.PlanCode))
						end 
						when left(pp.PlanCode, 1) = 'C' then 'X' + replace(pp.PlanCode, substring(pp.PlanCode, 2, 1), '')
						else 'X' + substring(pp.PlanCode, 2, len(pp.PlanCode)) 
					end
					when IsAgentSpecial = 1 then substring(pp.PlanCode, 3, len(pp.PlanCode))
					else 
						case 
							when pp.PlanCode in ('DA2', 'DA') then
							case p.TripCost
								when 'DA-$200' then 'DA2'
								when 'DA-$400' then 'DA4'
								when 'DA-$600' then 'DA6'
								when 'DA-$800' then 'DA8'
								when 'DA-$1,500' then 'DA15'
								else pp.PlanCode                         				
							end 
							else pp.PlanCode 
						end
				end
			end 
	end PlanCode
from
    [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock)
    inner join [db-au-cmdwh].dbo.penPolicy p with(nolock) on
        pt.PolicyKey = p.PolicyKey
    inner join [db-au-workspace].dbo.penOutlet_test o with(nolock) on
        o.OutletAlphaKey = pt.OutletAlphaKey and
        o.OutletStatus = 'Current'
    outer apply
    (
        select top 1 
            PlanCode
        from
            [db-au-cmdwh].dbo.penArea a with(nolock)
            inner join [db-au-cmdwh].dbo.penProductPlan pp with(nolock) on
                pp.AreaID = a.AreaID
        where
            a.CountryKey = p.CountryKey and
            a.CompanyKey = p.CompanyKey and
            a.AreaName = p.AreaName and
            pp.OutletKey = o.OutletKey and
            pp.ProductId = p.ProductID and
            pp.UniquePlanId = p.UniquePlanID
    ) napp
    outer apply
    (
        select top 1 
            PlanCode
        from
            [db-au-cmdwh].dbo.penProductPlan amtpp with(nolock)
        where
            amtpp.OutletKey = o.OutletKey and
            amtpp.UniquePlanId = p.UniquePlanID and
            amtpp.ProductId = p.ProductId and
            amtpp.AMTUpsellDisplayName = p.AreaName
    ) amtpp
    cross apply
    (
        select
            isnull(napp.PlanCode, amtpp.PlanCode) PlanCode
    ) pp

    







GO
