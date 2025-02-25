USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Quote Data_test007]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[Quote Data_test007] 
as


select distinct
       p.CreateDate,
       p.QuoteID,
	   p.SessionID,
	   p.PolicyNo,
	   p.MultiDestination,
	   p.Destination,
	   c.DestinationOrder,
	   p.Area,
	   c.isPrimaryDestination,
	   p.DepartureDate,
	   p.ReturnDate,
	   p.Duration,
	   p.PlanType,
	   p.PlanCode,
	   p.PlanName,
	   p.NumberOfAdults,
	   p.NumberOfChildren,
	   p.Excess,
	   p.TripCost,
       g.AddOnName as GroupName,
	   p.GrossPremium,
	   g.PremiumIncrease,
	   k.Title,
	   k.FirstName,
	   k.LastName,
	   k.EmailAddress,
	   k.MobilePhone,
	   k.State,
	   k.DOB,
	   k.PostCode,
	   z.Age,
	   s.OldestAge,
       y.AlphaCode,
	   y.OutletName,
	   y.Channel,
	   r.PromoCode,
	   r.Discount,
	   p.VolumeCommission,
	   s.QuoteCount

---select COUNT(1)
from
      [db-au-cmdwh].[dbo].penQuote p with (nolock)
      outer apply (
	                 select c.DestinationOrder,c.isPrimaryDestination from [db-au-cmdwh].[dbo].penQuoteDestination c with (nolock)
	                 where p.QuoteKey=c.QuoteKey and  p.CountryKey=c.CountryKey and p.CompanyKey=c.CompanyKey 
	              )c
    
	  outer apply (
	                 select g.AddOnName,g.PremiumIncrease,g.CountryKey,g.CompanyKey,g.CustomerID from [db-au-cmdwh].[dbo].penQuoteAddOn g  with (nolock)
	                 where p.QuoteID=g.QuoteID and  p.CountryKey=g.CountryKey and p.CompanyKey=g.CompanyKey --and g.IsActive=1
				 )g

      outer apply( 
	                select k.Title,k.FirstName,k.LastName,k.EmailAddress,k.MobilePhone,k.State,k.DOB,k.PostCode
					 from [db-au-cmdwh].[dbo].penCustomer k with (nolock)
                     where g.CountryKey=k.CountryKey and g.CompanyKey=k.CompanyKey and g.CustomerID=k.CustomerID
                )k

      outer apply ( 
	                select s.OldestAge,s.QuoteCount,s.CountryKey,s.OutletAlphaKey from [db-au-cmdwh].[dbo].penQuoteSummary s with (nolock)
	                where p.CountryKey=s.CountryKey and p.CompanyKey=s.CompanyKey and p.OutletAlphaKey=s.OutletAlphaKey

				)s
	 
	  outer apply (
	                select y.AlphaCode,y.OutletName,y.Channel from   [db-au-cmdwh].[dbo].penOutlet y with (nolock)
	               where p.CompanyKey=y.CompanyKey and p.CountryKey=s.CountryKey and p.OutletAlphaKey=s.OutletAlphaKey and p.OutletSKey=y.OutletSKey
	             )y

	  outer apply (
	                select r.PromoCode,r.Discount from  [db-au-cmdwh].[dbo].penQuotePromo r with (nolock)
                    where p.CompanyKey=r.CompanyKey and p.CountryKey=r.CountryKey  and p.QuoteID=r.QuoteID
                )r

      outer apply (
	                select z.Age from [db-au-cmdwh].[dbo].penQuoteCustomer z
                   where p.QuoteCountryKey=z.QuoteCountryKey and  p.CountryKey=z.CountryKey and p.CompanyKey=z.CompanyKey and p.QuoteID=z.QuoteID
				   )z
   
 
	  where CreateDate between DATEADD(mm,-3,getdate()) and GETDATE()
GO
