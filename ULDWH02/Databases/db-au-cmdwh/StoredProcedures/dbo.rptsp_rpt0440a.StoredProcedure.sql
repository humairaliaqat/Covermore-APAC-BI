USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0440a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0440a]	
    @Country varchar(3),
    @PolicyNumber varchar(20)
    
as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0440
--  Author:         Linus Tor
--  Date Created:   20130626
--  Description:    This stored procedure returns policy details. It will be called from a Webi report
--  Parameters:     @Country: Country is AU, NZ, or UK
--                  @PolicyNumber: valid policy number
--   
--  Change History: 20130626 - LT - Created
--                  20130731 - LS - conversion on left side of equation disables index
--                                  change convert(varchar, Policy.PolicyNo)  =  @PolicyNumber
--                                  to Policy.PolicyNo  =  @PolicyNumber
--					20130904 - LT - filtered query to isTripsPolicy = 1
--
/****************************************************************************************************/								   

--uncomment to debug
--declare 
--    @Country varchar(3),
--    @PolicyNumber varchar(20)
--select 
--    @Country = 'AU', 
--    @PolicyNumber = '56968057'

    set nocount on

    declare 
        @isCancelled int,
        @ProductName varchar(100)

    --check if main policy has been cancelled
    select 
        @isCancelled = 
            sum(
                case 
                    when PolicyType = 'R' and OldPolicyType = 'N' then 1 
                    else 0 
                end
            )
    from 
        Policy
    where 
        CountryKey = @Country and 
        (
            PolicyNo = @PolicyNumber or 
            OldPolicyNo = @PolicyNumber
        )

    --get product name
    select 
        @ProductName = 
            (
                select top 1 
                    ppl.ProductType + ' ' + ppl.TripType + ' Trip'
				from 
				    Policy p 
				    inner join ProductPlan ppl on 
				        p.ProductCode = ppl.ProductCodeDisplay and 
				        p.PlanCode = ppl.PlanCode
				where 
				    p.CountryKey = @Country and 
				    p.PolicyNo = @PolicyNumber
			)
			
    SELECT
      Policy.IssuedDate,
      Agency.AgencyGroupCode,
      Policy.PolicyNo,
      Policy.PolicyType,
      Agency.AgencyCode,
      Policy.ConsultantName,
      Policy.ProductCode,
      Policy.PlanCode,
      Policy.Excess,
      Policy.Destination,
      Policy.DepartureDate,
      Policy.ReturnDate,
      Policy.NumberOfDays,
      Policy.NumberOfAdults,
      Policy.NumberOfChildren,
      Policy.NumberofWeeks,
      Policy.TripCost,
      Policy.CancellationCoverValue,
      Agency.AgencyName,
      Agency.Branch,
      Agency.Phone,
      Agency.ContactEmail,
      PolicyEMC.EMCNumber,
      sum(Policy.ActualMedicalPremiumAfterDiscount) as ActualMedicalPremiumAfterDiscount,
      sum(Policy.ActualLuggagePremiumAfterDiscount) as ActualLuggagePremiumAfterDiscount,
      sum(Policy.ActualGrossPremiumAfterDiscount) as ActualGrossPremiumAfterDiscount,
      sum(Policy.ActualCommissionAfterDiscount) as ActualCommissionAfterDiscount,
      sum(Policy.ActualCancellationPremiumAfterDiscount) as ActualCancellationPremiumAfterDiscount,
      sum(Policy.GSTOnCommission) as GSTOnCommission,
      sum(Policy.GSTonGrossPremium) as GSTonGrossPremium,
      sum(Policy.CommissionAmount) as CommissionAmount,
      sum(Policy.StampDuty) as StampDuty,
      sum(Policy.GrossPremiumExGSTBeforeDiscount + Policy.GSTonGrossPremium - Policy.CommissionAmount - Policy.GSTOnCommission) as NetPremium,
      sum(Policy.WinterSportPremium) as WinterSportPremium,
      sum(Policy.RentalCarPremium) as RentalCarPremium,
      sum(Policy.MotorcyclePremium) as MotorcyclePremium,
      Policy.OldPolicyNo,
      Policy.SingleFamily,
      Policy.CountryKey as Country,
      sum(case when Policy.PolicyType = 'R' and Policy.OldPolicyType in ('N','E') then 1 else 0 end) as CancelledPolicyCount,
      sum(Policy.GrossPremiumExGSTBeforeDiscount) as GrossPremiumExGSTBeforeDiscount,
      sum(Policy.ActualAdminFeeAfterDiscount) as ActualAdminFeeAfterDiscount,
      Policy.PaymentDate,
      Policy.BankPaymentRecord,
      Policy.AreaType,
      Policy.AreaNo,
      @isCancelled as isCancelled,
      @ProductName as ProductName,
      case when right(Policy.BatchNo,2) = 'BB' then 'B2B User'
	            when right(Policy.BatchNo,2) = 'BC' then 'B2C User'
	            else 'CRM User'
      end as IssuedBy
    FROM
      Agency 
      INNER JOIN Policy ON (Policy.AgencyKey=Agency.AgencyKey)
      INNER JOIN 
      ( 
	      select
		    PolicyKey, 
		    EMCNumber,
		    case when pe.PolicyEMCType is null then 'No EMC'
			     when pe.PolicyEMCType = 'Assessed' then 'Assessment and Charge'
			     when pe.PolicyEMCType = 'Self-Assessed' and p.MedicalPremium = 0 then 'Auto Accept With No Charge'
			     when pe.PolicyEMCType = 'Self-Assessed' and p.MedicalPremium > 0 then 'Auto Accept With Charge'
			     else 'Undefined'
		    end EMCType
	      from 
	        Policy p
	        outer apply
		    (
			    select top 1 
			      PolicyEMCType,
			      ClientID EMCNumber
			    from PolicyEMC pe
			    where 
			      pe.CountryKey = p.CountryKey and
			      pe.PolicyNo = p.PolicyNo and
			      pe.PolicyEMCType is not null
		    ) pe
	    )  PolicyEMC ON (Policy.PolicyKey=PolicyEMC.PolicyKey)
    WHERE
      (
       Policy.CountryKey = @Country
       AND
       Policy.PolicyNo  =  @PolicyNumber
       AND
       Policy.isTripsPolicy = 1
       AND
       ( Agency.AgencyStatus = 'Current'  )
      )
    GROUP BY
      Policy.IssuedDate, 
      Agency.AgencyGroupCode, 
      Policy.PolicyNo, 
      Policy.PolicyType, 
      Agency.AgencyCode, 
      Policy.ConsultantName, 
      Policy.ProductCode, 
      Policy.PlanCode, 
      Policy.Excess, 
      Policy.Destination, 
      Policy.DepartureDate, 
      Policy.ReturnDate, 
      Policy.NumberOfDays, 
      Policy.NumberOfWeeks,
      Policy.NumberOfAdults, 
      Policy.NumberOfChildren, 
      Policy.TripCost, 
      Policy.CancellationCoverValue, 
      Agency.AgencyName, 
      Agency.Branch, 
      Agency.Phone, 
      Agency.ContactEmail, 
      PolicyEMC.EMCNumber, 
      Policy.OldPolicyNo, 
      Policy.SingleFamily, 
      Policy.CountryKey, 
      Policy.PaymentDate, 
      Policy.BankPaymentRecord, 
      Policy.AreaType, 
      Policy.AreaNo,
      case when right(Policy.BatchNo,2) = 'BB' then 'B2B User'
	            when right(Policy.BatchNo,2) = 'BC' then 'B2C User'
	            else 'CRM User'
      end


end
GO
