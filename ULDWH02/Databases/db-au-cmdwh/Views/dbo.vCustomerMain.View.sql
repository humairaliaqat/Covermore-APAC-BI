USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCustomerMain]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vCustomerMain]
as

/* 
	This view selects the main customer for each policy, and should be used as intermediate table for Policy and Customer to
	get unique customer attributes
*/

with Customer_CTE
as (select c.CountryKey,
			c.CustomerKey,
			min(c.CustomerID) as CustomerID,
			min(c.AddressID) as AddressID
	from [db-au-cmdwh].dbo.Customer c
	group by
		c.CountryKey,
		c.CustomerKey
	)	
select
	c.CountryKey,
	c.CustomerKey,
	c.AgencyCode,
	c.PolicyNo,
	c.ProductCode,
	c.Title,
	c.FirstName,
	c.Initial,
	c.LastName,
	c.DateOfBirth,
	c.AgeAtDateOfIssue,
	c.PersonIsAdult,
	c.AddressStreet,
	c.AddressSuburb,
	c.AddressState,
	c.AddressPostCode,
	c.AddressCountry,
	c.Phone,
	c.WorkPhone,
	c.Email,
	c.CustomerID,
	c.AddressID
from
	[db-au-cmdwh].dbo.Customer c
	join Customer_CTE cc on
		c.CountryKey = cc.CountryKey and
		c.CustomerKey = cc.CustomerKey and
		c.CustomerID = cc.CustomerID and
		c.AddressID = cc.AddressID


GO
