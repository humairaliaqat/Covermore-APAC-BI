USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_policytraveller_test007]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rawsp_policytraveller_test007]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @AgencyCodes varchar(max) = null,
	  @ProductCode varchar(max) = null,
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null 
  
as

Begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:          rawsp_policytraveller
--  Author:        Linus Tor
--  Date Created:  20140212
--  Description:   Based on rawsp_policy and rawsp_policycustomer procedures.
--				   This stored procedure extract policy and traveller data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL 
--				   @ProductCode: Product code; e.g. MNC, MNM	
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20140212 - LT - Created
--					20140520 - LT - Fogbugz #20913 - Added Area and NewPolicyCount columns to extract
--					20160830 - PZ - Include AHM (groupcode = 'AH') in Medibank (groupcode = 'MB') extract 
--                  20180604 - LL - INC0071750, add posting date
--					20181126 - YY - REQ693 - Add a new parameter "Product Code"
--					20190305 - YY - REQ1060 - Add a column "Channel"
--
/****************************************************************************************************/
--uncomment to debug
--/*
--EXEC rawsp_policytraveller 'AU','MB',Null,'MNC,MNM','Last Week' --uncomment to debug
--declare 
--	@Country varchar(2),
--	@AgencyGroup varchar(2),
--	@AgencyCodes varchar(max),
--	@ProductCode varchar(max),
--	@DateRange varchar(30),
--	@StartDate date,
--	@EndDate date
--select 
--	@Country = 'AU', 
--	@AgencyGroup = 'MB', 
--	@ProductCode = 'MNC,MNM',
--	@DateRange = 'Last Week'
--*/
truncate table [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytransactions_tmp
truncate table [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp
truncate table [db-au-workspace].dbo.tmp_rawspPolicyTravellerrepeatcustomer_tmp					


declare @dataStartDate date
declare @dataEndDate date

/* get dates */
if @DateRange = '_User Defined'
    select 
        @dataStartDate = @StartDate,
        @dataEndDate = @EndDate

else
    select 
        @dataStartDate = StartDate, 
        @dataEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange


if object_id('[db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytransactions_tmp') is not null 
drop table [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytransactions_tmp

select
	pt.PolicyKey,
    pt.CountryKey,
    o.GroupCode,
	o.Channel,  
    p.PolicyNumber,
    pt.PolicyNumber as TransactionNumber,
	p.AlphaCode as AgencyCode,		        
    pt.StoreCode,  
    u.Initial as ConsultantInitial,
    u.FirstName + ' ' + u.LastName as ConsultantName,
    u.[Login] as MNumber,        
    pt.IssueTime IssueTime,
    pt.IssueDate IssueDate,
    p.TripStart DepartureDate,
    p.TripEnd ReturnDate,
    p.ProductCode,
    p.PlanName,
    p.StatusDescription as PolicyStatus,
    pt.TransactionType,
    pt.TransactionStatus,
    case pt.SingleFamilyFlag
        when 0 then 'Single'
        when 1 then 'Family'
        when 2 then 'Duo'
        else 'Undefined'
    end SingleFamily,
    pt.ChildrenCount,
    pt.AdultsCount,
    pt.TravellersCount,
    p.DaysCovered as Duration,
    pt.NoOfBonusDaysApplied as BonusDays,
    p.TripCost,
    p.TripType,
    p.PrimaryCountry as Destination,
    p.Area,
    p.AreaType,
    p.Excess,        
    pt.UserComments as PolicyComment,
    rc.CoverIncrease as RentalCarPremiumCovered,
    p.CancellationCover as CancellationCoverValue,
    pa.MedicalUnadj as UnadjustedMedicalPremium,
    pa.LuggageUnadj as UnadjustedLuggagePremium,
    pa.MotorcycleUnadj as UnadjustedMotorcyclePremium,
    pa.RentalCarUnadj as UnadjustedRentalCarPremium,
    pa.WinterSportUnadj as UnadjustedWinterSportPremium,
    pa.CancellationUnadj as UnadjustedCancellationPremium,
    pt.UnadjBasePremium as UnadjustedBasePremium,
    pt.UnAdjAdjustedNet as UnadjustedNetPrice,
    pt.UnAdjGrossPremium as UnadjustedSellPrice,
    pt.UnadjCommission as UnadjustedCommission,
    pt.UnadjGrossAdminFee as UnadjustedAdminFee,		        
    pt.CommissionRatePolicyPrice as CommissionRate,
    pt.NewPolicyCount,
    pt.BasePremium,
    pt.GrossPremium as SellPrice,
    pt.AdjustedNet as NetPrice,
    pt.Commission as Commission,        
    pt.TaxAmountGST GSTonGrossPremium,
    pt.TaxOnAgentCommissionGST as GSTOnCommission,
    pt.TaxAmountSD as SDonGrossPremium,
    pt.TaxOnAgentCommissionSD as SDonCommission,
    pt.GrossAdminFee as AdminFee,
    pa.Medical as MedicalPremium,
    pa.Luggage as LuggagePremium,
    pa.Motorcycle as MotorcyclePremium,
    pa.RentalCar as RentalCarPremium,
    pa.WinterSport as WinterSportPremium,
    pa.Cancellation as CancellationPremium,
    pt.PaymentDate,
	case when isNull(op.PaymentID,0)=0 and len(isnull(op.CardType,''))=0 then 'Non Credit Card' 
		 else 'Credit Card' 
	end as PaymentMethod,
    (
        select 
            ppr.PromoCode + 
            case
                when ppr.PromoKey = max(ppr.PromoKey) over () then ''
                else ','
            end
        from  
            [db-au-cmdwh]..penPolicyTransactionPromo ppr
        where
            ppr.PolicyTransactionKey = pt.PolicyTransactionKey and
            ppr.IsApplied = 1
        order by PromoKey
        for xml path('')
    ) PromoCode,
    pt.PostingDate
into [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytransactions_tmp        
from
    [db-au-cmdwh]..penOutlet o
    inner join [db-au-cmdwh]..penPolicyTransSummary pt on 
        pt.OutletAlphaKey = o.OutletAlphaKey
    inner join [db-au-cmdwh]..penPolicy p on
        p.PolicyKey = pt.PolicyKey
    left join [db-au-cmdwh]..penUser u on
        u.UserKey = pt.UserKey and
        u.UserStatus = 'Current'           
    left join [db-au-cmdwh]..vPenPolicyAddonPremium pa on
        pa.PolicyTransactionKey = pt.PolicyTransactionKey
    left join [db-au-cmdwh]..penPayment op on 
        op.PolicyTransactionKey = pt.PolicyTransactionKey
    outer apply
    (
        select top 1
            CoverIncrease
        from
            [db-au-cmdwh]..penPolicyTransAddOn pta
        where
            pta.PolicyTransactionKey = pt.PolicyTransactionKey and
            AddOnGroup = 'Rental Car'
    ) rc
where 
    o.CountryKey = @Country and
	o.GroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    o.OutletStatus = 'Current' and
    (
        (
            pt.PostingDate >= @dataStartDate and 
            pt.PostingDate <  dateadd(day, 1, @dataEndDate)
        ) or
        (
            pt.PaymentDate >= @dataStartDate and 
            pt.PaymentDate <  dateadd(day, 1, @dataEndDate)
        )
    ) and
    (
        isnull(@AgencyCodes, '') = '' or
        o.AlphaCode in
        (
            select Item
            from
                [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@AgencyCodes, ',')
        )
    ) and			-- Add Product Code -YY 20181126
	(
        isnull(@ProductCode, '') = '' or
        p.ProductCode in
        (
            select Item
            from
                [db-au-cmdwh].dbo.fn_DelimitedSplit8K(@ProductCode, ',')
        )

	)


--get policy traveller details
if object_id('[db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp') is not null 
drop table [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp

select
	pt.CountryKey,
	pt.PolicyKey,
	p.IssueDate,
	o.GroupCode,
	pt.PolicyTravellerID,
	pt.MemberNumber,
	pt.isPrimary,
	pt.DOB,
	pt.Age,
	pt.isAdult,
	pt.Title,
	pt.FirstName,
	pt.LastName,
	pt.AddressLine1 + ' ' + pt.AddressLine2 as Street,
	pt.Suburb,
	pt.Postcode,
	pt.[State],
	pt.Country,
	pt.EmailAddress,
	case when isnull(pt.HomePhone,'') = '' then isnull(pt.MobilePhone,'')
		 else isnull(pt.HomePhone,'')
	end as HomeMobilePhone,
	pt.WorkPhone,
	pt.OptFurtherContact,
	pt.EMCRef as EMCReference,
	pt.DisplayName as EMCType,
	0 as isRepeatCustomer,
    pt.PIDValue --Medibank INC0169984
into [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp		
from
	[db-au-cmdwh]..penPolicyTraveller pt
	inner join [db-au-cmdwh]..penPolicy p on pt.PolicyKey = p.PolicyKey
	inner join [db-au-cmdwh]..penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	pt.CountryKey = 'AU' and
	pt.CompanyKey = 'TIP' and
	o.GroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
	pt.PolicyKey in (select distinct PolicyKey from [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytransactions_tmp)
			 

/* repurchase based on member number or name & dob combination for prior purchase for the same agency group */
if object_id('[db-au-workspace].dbo.tmp_rawspPolicyTravellerrepeatcustomer_tmp') is not null drop table [db-au-workspace].dbo.tmp_rawspPolicyTravellerrepeatcustomer_tmp
select 
    t.PolicyKey,
    case
        when exists
        (
            select null
            from
                [db-au-cmdwh]..penPolicyTraveller ptv
                inner join [db-au-cmdwh]..penPolicy p on
                    p.PolicyKey = ptv.PolicyKey
                inner join [db-au-cmdwh]..penOutlet o on
                    o.OutletAlphaKey = p.OutletAlphaKey and
                    o.OutletStatus = 'Current'
            where
                t.MemberNumber is not null and
                t.MemberNumber <> '' and
                ptv.MemberNumber = t.MemberNumber and
                ptv.PolicyTravellerID < t.PolicyTravellerID and 
                p.IssueDate < poltrans.IssueDate and 
                o.GroupCode = poltrans.GroupCode and
                o.CountryKey = poltrans.CountryKey
        ) then 1
        when exists
        (
            select null
            from
                [db-au-cmdwh]..penPolicyTraveller ptv
                inner join [db-au-cmdwh]..penPolicy p on
                    p.PolicyKey = ptv.PolicyKey
                inner join [db-au-cmdwh]..penOutlet o on
                    o.OutletAlphaKey = p.OutletAlphaKey and
                    o.OutletStatus = 'Current'
            where
                ptv.FirstName = t.FirstName and
                ptv.LastName = t.LastName and
                ptv.DOB = t.DOB and
                ptv.PolicyTravellerID < t.PolicyTravellerID and 
                p.IssueDate < t.IssueDate and 
                o.GroupCode = t.GroupCode and
                o.CountryKey = t.CountryKey
        ) then 1
        else 0
    end Flag
into [db-au-workspace].dbo.tmp_rawspPolicyTravellerrepeatcustomer_tmp
from
    [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp t
    join [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytransactions_tmp poltrans on t.PolicyKey = poltrans.PolicyKey

			
--update isRepeatCustomer flag in [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp				
update t
set isRepeatCustomer = case when r.Flag = 1 then 1 else 0 end
from
	[db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp t
	inner join [db-au-workspace].dbo.tmp_rawspPolicyTravellerrepeatcustomer_tmp r on t.PolicyKey = r.PolicyKey
	
	
--output
select
	t.PolicyTravellerID,
	t.MemberNumber,
	t.isPrimary,
	t.DOB,
	t.Age,
	t.isAdult,
	t.Title,
	t.FirstName,
	t.LastName,
	t.Street,
	t.Suburb,
	t.Postcode,
	t.[State],
	t.Country,
	t.EmailAddress,
	t.HomeMobilePhone,
	t.WorkPhone,
	t.OptFurtherContact,
	t.EMCReference,
	t.EMCType,
	t.isRepeatCustomer,
	pt.AgencyCode,
	pt.StoreCode,
	pt.ConsultantInitial,
	pt.ConsultantName,
	pt.MNumber,
    pt.PolicyNumber,
    pt.TransactionNumber,	
	pt.IssueTime,
	pt.IssueDate,
	pt.DepartureDate,
	pt.ReturnDate,
	pt.ProductCode,
	pt.PlanName,
	pt.PolicyStatus,
	pt.TransactionType,
	pt.TransactionStatus,
	pt.SingleFamily,
	pt.ChildrenCount,
	pt.AdultsCount,
	pt.TravellersCount,
	pt.Duration,
	pt.BonusDays,
	pt.TripCost,
	pt.TripType,
	pt.Destination,
	pt.Area,
	pt.AreaType,
	pt.Excess,
	pt.RentalCarPremiumCovered,
	pt.PolicyComment,
    pt.CancellationCoverValue,
    pt.UnadjustedMedicalPremium,
    pt.UnadjustedLuggagePremium,
    pt.UnadjustedMotorcyclePremium,
    pt.UnadjustedRentalCarPremium,
    pt.UnadjustedWinterSportPremium,
    pt.UnadjustedCancellationPremium,
    pt.UnadjustedBasePremium,
    pt.UnadjustedNetPrice,
    pt.UnadjustedSellPrice,
    pt.UnadjustedCommission,
    pt.UnadjustedAdminFee,		        
    pt.CommissionRate,
    pt.NewPolicyCount,
    pt.BasePremium,
    pt.SellPrice,
    pt.NetPrice,
    pt.Commission,        
    pt.GSTonGrossPremium,
    pt.GSTOnCommission,
    pt.SDonGrossPremium,
    pt.SDonCommission,
    pt.AdminFee,
    pt.MedicalPremium,
    pt.LuggagePremium,
    pt.MotorcyclePremium,
    pt.RentalCarPremium,
    pt.WinterSportPremium,
    pt.CancellationPremium,
    pt.PaymentDate,
	pt.PaymentMethod,
    pt.PromoCode,
    pt.PostingDate,
	pt.Channel,
    t.PIDValue as BPID --Medibank INC0169984
from
	[db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytravellers_tmp t
	inner join [db-au-workspace].dbo.tmp_rawspPolicyTravellerpolicytransactions_tmp pt on t.PolicyKey = pt.PolicyKey

End






GO
