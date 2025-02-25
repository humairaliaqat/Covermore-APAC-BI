USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_policy]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rawsp_policy]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @AgencyCodes varchar(max) = null,
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin


/****************************************************************************************************/
--  Name:          rawsp_policy
--  Author:        Leonardus Setyabudi
--  Date Created:  20111021
--  Description:   This stored procedure extract policy data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--
--  Change History: 20111021 - LS - Created
--                  20111024 - LS - bug fix, duplicate data (Agency Status)
--                  20120309 - LT - bug fix, wrong consultant selected.
--                                  Amended ConsultantInital and ConsultantName columns to select
--                                  from penPolicyTransaction and penUser tables.
--                  20120327 - LS - bug fix, duplicate records from PolicyEMC
--                  20120403 - LS - TFS 4647, add PaymentMethod
--                  20120516 - LS - Bug fix, duplicate User ID (CM + TIP)
--                  20120913 - LS - Add Promo
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
--                  20130530 - LS - Case 18562, add extra parameter for agency code in csv
--
/****************************************************************************************************/
--uncomment to debug
/*
declare
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @AgencyCodes varchar(max),
    @DateRange varchar(30),
    @StartDate date,
    @EndDate date
select
    @Country = 'AU',
    @AgencyGroup = 'MB',
    @DateRange = '_User Defined',
    @StartDate = '2015-05-05',
    @EndDate = '2015-05-05'
*/

    set nocount on

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
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange

	if object_id('[db-au-workspace].dbo.rawPolicy') is not null drop table [db-au-workspace].dbo.rawPolicy
    select
        p.CountryKey,
        p.CompanyKey,
        p.BatchNo,
        p.PolicyNo,
        p.AgencyCode,
        p.StoreCode,
        p.CreateDate,
        p.CreateTime,
        p.IssuedDate,
        p.DepartureDate,
        p.ReturnDate,
        p.ProductCode,
        p.PlanCode,
        p.SingleFamily,
        p.PolicyComment,
        p.PolicyType,
        p.OldPolicyNo,
        p.OldPolicyType,
        p.OldProductCode,
        p.OldPlanCode,
        p.NumberOfChildren,
        p.NumberOfAdults,
        p.NumberOfPersons,
        p.NumberOfDays,
        p.NumberOfBonusDays,
        p.Destination,
        p.TripCost,
        p.Excess,
        p.RentalCarPremiumCovered,
        p.CancellationCoverValue,
        p.BasePremium,
        p.MedicalPremium,
        e.PolicyEMCID,
        e.PolicyEMCType,
        p.LuggagePremium,
        p.MotorcyclePremium,
        p.RentalCarPremium,
        p.WinterSportPremium,
        p.CancellationPremium,
        p.NetPremium,
        p.GrossPremiumExGSTBeforeDiscount,
        p.NetRate,
        p.CommissionRate,
        p.CommissionAmount,
        p.GSTonGrossPremium,
        p.GSTOnCommission,
        p.StampDuty,
        p.ActualAdminFee,
        p.ActualCommissionAfterDiscount,
        p.ActualGrossPremiumAfterDiscount,
        p.ActualLuggagePremiumAfterDiscount,
        p.ActualMedicalPremiumAfterDiscount,
        p.ActualRentalCarPremiumAfterDiscount,
        p.ActualCancellationPremiumAfterDiscount,
        p.ActualAdminFeeAfterDiscount,
        p.PaymentDate,
        case
            when op.PolicyKey is null then 'Non Credit Card'
            else 'Credit Card'
        end PaymentMethod
	into [db-au-workspace].dbo.rawPolicy
    from
        Agency a
        inner join Policy p on
            p.AgencyKey = a.AgencyKey
        left join OnlinePayment op on
            op.PolicyKey = p.CountryPolicyKey
        outer apply
        (
            select top 1
                PolicyEMCID,
                PolicyEMCType
            from
                PolicyEMC e
            where
                e.CountryKey = p.CountryKey and
                e.PolicyNo = p.PolicyNo
        ) e
    where
        a.CountryKey = @Country and
        a.AgencyGroupCode = @AgencyGroup and
        a.AgencyStatus = 'Current' and
        (
            (
                p.IssuedDate >= @dataStartDate and
                p.IssuedDate <  dateadd(day, 1, @dataEndDate)
            ) or
            (
                p.PaymentDate >= @dataStartDate and
                p.PaymentDate <  dateadd(day, 1, @dataEndDate)
            )
        ) and

        (
            isnull(@AgencyCodes, '') = '' or
            a.AgencyCode in
            (
                select Item
                from
                    dbo.fn_DelimitedSplit8K(@AgencyCodes, ',')
            )
        )

	if object_id('[db-au-workspace].dbo.rawConsultant') is not null drop table [db-au-workspace].dbo.rawConsultant
	select
		pt.CountryKey,
		pt.CompanyKey,
		pt.PolicyNumber as PolicyNo,
        u.Initial ConsultantInitial,
        u.FirstName + ' ' + u.LastName ConsultantName,
        u.[Login] MNumber
	into [db-au-workspace].dbo.rawConsultant
    from
        [db-au-cmdwh].dbo.penPolicyTransaction pt
        inner join [db-au-cmdwh].dbo.penUser u on
            pt.UserKey = u.UserKey and
            u.UserStatus = 'Current'
    where
        pt.CountryKey = @Country and
        pt.PolicyNumber in (select PolicyNo from [db-au-workspace].dbo.rawPolicy) and
        pt.CompanyKey =
            case
                when @AgencyGroup in ('MB', 'AP') then 'TIP'
                else 'CM'
            end

        
	if object_id('[db-au-workspace].dbo.rawPromo') is not null drop table [db-au-workspace].dbo.rawPromo
    select
		pt.CountryKey,
		pt.CompanyKey,
		pt.PolicyNumber,
        ppr.PromoCode,
        ppr.PromoKey
	into [db-au-workspace].dbo.rawPromo        
    from
        penPolicyTransaction pt
        inner join penPolicyTransactionPromo ppr on
            ppr.PolicyTransactionKey = pt.PolicyTransactionKey
    where
        pt.CountryKey = @Country and
        pt.PolicyNumber in (select PolicyNo from [db-au-workspace].dbo.rawPolicy) and
        pt.CompanyKey =
            case
                when @AgencyGroup in ('MB', 'AP') then 'TIP'
                else 'CM'
            end and
        ppr.IsApplied = 1
                
    select
        a.CountryKey,
        a.BatchNo,
        a.PolicyNo,
        a.AgencyCode,
        a.StoreCode,
        cn.ConsultantInitial,
        cn.ConsultantName,
        cn.MNumber,
        a.CreateDate,
        a.CreateTime,
        a.IssuedDate,
        a.DepartureDate,
        a.ReturnDate,
        a.ProductCode,
        a.PlanCode,
        a.SingleFamily,
        a.PolicyComment,
        a.PolicyType,
        a.OldPolicyNo,
        a.OldPolicyType,
        a.OldProductCode,
        a.OldPlanCode,
        a.NumberOfChildren,
        a.NumberOfAdults,
        a.NumberOfPersons,
        a.NumberOfDays,
        a.NumberOfBonusDays,
        a.Destination,
        a.TripCost,
        a.Excess,
        a.RentalCarPremiumCovered,
        a.CancellationCoverValue,
        a.BasePremium,
        a.MedicalPremium,
        e.PolicyEMCID,
        e.PolicyEMCType,
        a.LuggagePremium,
        a.MotorcyclePremium,
        a.RentalCarPremium,
        a.WinterSportPremium,
        a.CancellationPremium,
        a.NetPremium,
        a.GrossPremiumExGSTBeforeDiscount,
        a.NetRate,
        a.CommissionRate,
        a.CommissionAmount,
        a.GSTonGrossPremium,
        a.GSTOnCommission,
        a.StampDuty,
        a.ActualAdminFee,
        a.ActualCommissionAfterDiscount,
        a.ActualGrossPremiumAfterDiscount,
        a.ActualLuggagePremiumAfterDiscount,
        a.ActualMedicalPremiumAfterDiscount,
        a.ActualRentalCarPremiumAfterDiscount,
        a.ActualCancellationPremiumAfterDiscount,
        a.ActualAdminFeeAfterDiscount,
        a.PaymentDate,
        a.PaymentMethod,
        (
            select
                ppr.PromoCode +
                case
                    when ppr.PromoKey = max(ppr.PromoKey) over () then ''
                    else ','
                end
            from
                [db-au-workspace].dbo.rawPromo ppr
            where
                ppr.CountryKey = a.CountryKey and
                ppr.PolicyNumber = a.PolicyNo and
                ppr.CompanyKey = a.CompanyKey
            order by PromoKey
            for xml path('')
        ) PromoCode
    from
        [db-au-workspace].dbo.rawPolicy a
        outer apply
        (
            select top 1
                PolicyEMCID,
                PolicyEMCType
            from
                PolicyEMC e
            where
                e.CountryKey = a.CountryKey and
                e.PolicyNo = a.PolicyNo
        ) e
        outer apply
        (
            select top 1
                c.ConsultantInitial,
                c.ConsultantName,
                c.MNumber
            from
                [db-au-workspace].dbo.rawConsultant c
            where
                c.CountryKey = a.CountryKey and
                c.PolicyNo = a.PolicyNo and
                c.CompanyKey = a.CompanyKey
        ) cn


	truncate table [db-au-workspace].dbo.rawPolicy
	truncate table [db-au-workspace].dbo.rawConsultant
	truncate table [db-au-workspace].dbo.rawPromo

end

GO
