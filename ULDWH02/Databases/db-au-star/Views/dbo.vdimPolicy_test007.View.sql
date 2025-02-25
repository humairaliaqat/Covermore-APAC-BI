USE [db-au-star]
GO
/****** Object:  View [dbo].[vdimPolicy_test007]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE view [dbo].[vdimPolicy_test007] as  
/*  
20160317, PW,   add area, trip duration columns  
20160321, LS,   move overhead (from joining to ODS tables) to ETL  
20180412, LL,   only expose policy number issued in the last 3 years  
*/  
select --top 1000  
    dp.PolicySK,   
    dp.Country,   
    dp.PolicyKey,   
    dp.PolicyNumber,   
    case  
        when dp.IssueDate < convert(date, convert(varchar(5), dateadd(year, -3, getdate()), 120) + '01-01') then 'Out of range'  
        else dp.PolicyNumber  
    end ExposedPolicyNumber,  
    dp.PolicyStatus,   
    convert(date, dp.IssueDate) IssueDate,   
    convert(date, dp.CancelledDate) CancelledDate,   
    dp.TripStart,
    dp.TripEnd,
    dp.GroupName,   
    dp.CompanyName,   
    dp.PolicyStart,   
    dp.PolicyEnd,  
    dp.Excess,  
    '$' + replace(convert(varchar, try_convert(money, isnull(dp.Excess, 0)), 1), '.00', '') ExcessName,  
    dp.TripType,   
    try_convert(money, isnull(dp.TripCost, 0)) TripCost,   
    '$' + replace(convert(varchar, try_convert(money, isnull(dp.TripCost, 0)), 1), '.00', '') TripCostName,  
    dp.isCancellation,   
    try_convert(money, isnull(dp.CancellationCover, 0)) CancellationCover,  
    '$' + replace(convert(varchar, try_convert(money, isnull(dp.CancellationCover, 0)), 1), '.00', '') CancellationCoverName,  
    dp.LoadDate,   
    dp.updateDate,   
    dp.LoadID,   
    dp.updateID,   
    dp.HashKey,   
    case  
        when lt.LeadTime < 0 then 'Unknown'  
        when lt.LeadTime between 0 and 27 then 'Pricing group 1'  
        when lt.LeadTime between 28 and 56 then 'Pricing group 2'  
        when lt.LeadTime between 57 and 92 then 'Pricing group 3'  
        when lt.LeadTime between 93 and 213 then 'Pricing group 4'  
        when lt.LeadTime between 214 and 359 then 'Pricing group 5'  
        else 'Pricing group 6'  
    end LeadTimeGroup,  
    case  
        when lt.LeadTime < 0 then 999  
        when lt.LeadTime between 0 and 27 then 27  
        when lt.LeadTime between 28 and 56 then 56  
        when lt.LeadTime between 57 and 92 then 92  
        when lt.LeadTime between 93 and 213 then 213  
        when lt.LeadTime between 214 and 359 then 359  
        else 360  
    end LeadTimeGroupKey,  
    case  
        when lt.LeadTime < 0 then 'Unknown'  
        when lt.LeadTime between 0 and 2 then '2 days'  
        when lt.LeadTime between 3 and 5 then '5 days'  
        when lt.LeadTime between 6 and 8 then '8 days'  
        when lt.LeadTime between 9 and 11 then '11 days'  
        when lt.LeadTime between 12 and 14 then '14 days'  
        when lt.LeadTime between 15 and 17 then '17 days'  
        when lt.LeadTime between 18 and 20 then '20 days'  
        when lt.LeadTime between 21 and 27 then '4 weeks'  
        when lt.LeadTime between 28 and 35 then '5 weeks'  
        when lt.LeadTime between 36 and 42 then '6 weeks'  
        when lt.LeadTime between 43 and 49 then '7 weeks'   
        when lt.LeadTime between 50 and 56 then '8 weeks'  
        when lt.LeadTime between 57 and 63 then '9 weeks'  
        when lt.LeadTime between 64 and 70 then '10 weeks'  
        when lt.LeadTime between 71 and 92 then '11 weeks'  
        when lt.LeadTime between 93 and 123 then '3 months'  
        when lt.LeadTime between 124 and 153 then '4 months'  
        when lt.LeadTime between 154 and 183 then '5 months'  
        when lt.LeadTime between 184 and 213 then '6 months'  
        when lt.LeadTime between 214 and 243 then '7 months'  
        when lt.LeadTime between 244 and 274 then '8 months'  
        when lt.LeadTime between 275 and 304 then '9 months'  
        when lt.LeadTime between 305 and 335 then '10 months'  
        when lt.LeadTime between 336 and 359 then '11 months'  
        when lt.LeadTime between 360 and 366 then '12 months'  
        else 'Greater than 12 months'  
    end LeadTimeBand,  
    case  
        when lt.LeadTime < 0 then 999  
        when lt.LeadTime between 0 and 2 then 2  
        when lt.LeadTime between 3 and 5 then 5  
        when lt.LeadTime between 6 and 8 then 8  
        when lt.LeadTime between 9 and 11 then 11  
        when lt.LeadTime between 12 and 14 then 14  
        when lt.LeadTime between 15 and 17 then 17  
        when lt.LeadTime between 18 and 20 then 20  
        when lt.LeadTime between 21 and 27 then 27  
        when lt.LeadTime between 28 and 35 then 35  
        when lt.LeadTime between 36 and 42 then 42  
        when lt.LeadTime between 43 and 49 then 49  
        when lt.LeadTime between 50 and 56 then 56  
        when lt.LeadTime between 57 and 63 then 63  
        when lt.LeadTime between 64 and 70 then 70  
        when lt.LeadTime between 71 and 92 then 92  
        when lt.LeadTime between 93 and 123 then 123  
        when lt.LeadTime between 124 and 153 then 153  
        when lt.LeadTime between 154 and 183 then 183  
        when lt.LeadTime between 184 and 213 then 213  
        when lt.LeadTime between 214 and 243 then 243  
        when lt.LeadTime between 244 and 274 then 274  
        when lt.LeadTime between 275 and 304 then 304  
        when lt.LeadTime between 305 and 335 then 335  
        when lt.LeadTime between 336 and 359 then 359  
        when lt.LeadTime between 360 and 366 then 366  
        else 367  
    end LeadTimeBandKey,  
    isnull(datediff(day, dp.IssueDate, dp.TripStart), 0) LeadTime,   
    case   
        when isnumeric(dp.CancellationCover) = 0 then 99999999  
        when try_convert(int, dp.CancellationCover) = 0 then 0  
        when try_convert(int, dp.CancellationCover) < 2000 then 2000  
        when try_convert(int, dp.CancellationCover) < 4000 then 4000  
        when try_convert(int, dp.CancellationCover) < 7000 then 7000  
        when try_convert(int, dp.CancellationCover) < 11000 then 11000  
        when try_convert(int, dp.CancellationCover) < 21000 then 21000  
        when try_convert(int, dp.CancellationCover) <= 200000 then 200000  
        when try_convert(int, dp.CancellationCover) < 1000000 then 1000000  
        else 1000001  
    end CancellationCoverBandKey,  
    case   
        when isnumeric(dp.CancellationCover) = 0 then 'Unknown'   
        when try_convert(int, dp.CancellationCover) = 0 then '0'   
        when try_convert(int, dp.CancellationCover) < 2000 then '< 2k'   
        when try_convert(int, dp.CancellationCover) < 4000 then '2-3k'   
        when try_convert(int, dp.CancellationCover) < 7000 then '4-6k'   
        when try_convert(int, dp.CancellationCover) < 11000 then '7-10k'   
        when try_convert(int, dp.CancellationCover) < 21000 then '11-20k'   
        when try_convert(int, dp.CancellationCover) <= 200000 then '21-200k'   
        when try_convert(int, dp.CancellationCover) < 1000000 then '200-900k'   
        else '>1m'   
    end CancellationCoverBand,  
    case  
        when dp.PurchasePath like 'Business%' then 'Business'  
        when dp.PurchasePath like 'Age%' then 'Age Approved'  
        else 'Leisure'  
    end PurchasePathGroup,  
    isnull(dp.PurchasePath, 'Leisure') PurchasePath,  
    isnull(dp.MaxDuration, 0) MaxDuration,  
    isnull(dp.TravellerCount, 0) TravellerCount,  
    isnull(dp.AdultCount, 0) AdultCount,  
    isnull(dp.ChargedAdultCount, 0) ChargedAdultCount,  
    isnull(TotalPremium, 0) PremiumAtIssue,  
    case  
        when isnull(TotalPremium, 0) < 100 then '0 - 99'  
        when isnull(TotalPremium, 0) < 250 then '100 - 249'  
        when isnull(TotalPremium, 0) < 500 then '250 - 499'  
        when isnull(TotalPremium, 0) < 1000 then '500 - 999'  
        when isnull(TotalPremium, 0) < 1500 then '1000 - 1499'  
        when isnull(TotalPremium, 0) <= 2000 then '1500 - 2000'  
        else '2000+'  
    end PremiumAtIssueBand,  
    case  
        when isnull(TotalPremium, 0) < 100 then 100  
        when isnull(TotalPremium, 0) < 250 then 250  
        when isnull(TotalPremium, 0) < 500 then 500  
        when isnull(TotalPremium, 0) < 1000 then 1000  
        when isnull(TotalPremium, 0) < 1500 then 1500  
        when isnull(TotalPremium, 0) <= 2000 then 2000  
        else 2001  
    end PremiumAtIssueBandKey,  
    EMCFlag,  
    MaxEMCScore,  
    TotalEMCScore,  
    CancellationFlag,  
    CruiseFlag,  
    ElectronicsFlag,  
    LuggageFlag,  
    MotorcycleFlag,  
    RentalCarFlag,  
    WinterSportFlag,  
    -1 CustomerID,  
    --isnull(CustomerID, -1) CustomerID  
  
    Underwriter,
	CancellationPlusFlag  
from  
    dimPolicy_test007 dp  
    cross apply  
    (  
        select  
            datediff(day, dp.IssueDate, dp.TripStart) LeadTime  
    ) lt  
  
  
GO
