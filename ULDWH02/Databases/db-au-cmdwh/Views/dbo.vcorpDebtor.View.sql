USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vcorpDebtor]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vcorpDebtor]
as


select
	t.CountryKey,
	t.QuoteKey,
	t.ItemKey,
	t.QuoteID, 
	t.ItemID, 
	t.ItemType, 
	t.PropBal, 
	t.UWSaleExGST, 
	t.GSTGross, 
	t.AgtCommExGST, 
	t.GSTAgtComm,
	(t.UWSaleExGST - t.AgtCommExGST) as Nett, 
	(t.GSTGross - t.GSTAgtComm) as GSTNett, 
	t.AccountingPeriod,
	l.IssuedDate
from
	[db-au-cmdwh].dbo.corpLuggage l
	join [db-au-cmdwh].dbo.corpTaxes t on
		l.LuggageKey = t.ItemKey and 
		l.QuoteKey = t.QuoteKey
where
	l.BankRecord is null
	
union

select 
	t.CountryKey,
	t.QuoteKey,
	t.ItemKey,
	t.QuoteID,
	t.ItemID, 
	t.ItemType, 
	t.PropBal, 
	t.UWSaleExGST, 
	t.GSTGross, 
	t.AgtCommExGST, 
	t.GSTAgtComm, 
	t.UWSaleExGST -t.AgtCommExGST AS Nett, 
	t.GSTGross - t.GSTAgtComm as GSTNett, 
	t.AccountingPeriod,
	c.IssuedDate
from
	[db-au-cmdwh].dbo.corpClosing c
	join [db-au-cmdwh].dbo.corpTaxes t on 
		c.QuoteKey = t.QuoteKey and
		c.ClosingKey = t.ItemKey
where
	c.BankRecord is null
	
union	

select
	t.CountryKey,
	t.QuoteKey,
	t.ItemKey,
	t.QuoteID, 
	t.ItemID, 
	t.ItemType,  
	t.PropBal, 
	t.UWSaleExGST, 
	t.GSTGross, 
	t.AgtCommExGST, 
	t.GSTAgtComm, 
	t.UWSaleExGST - t.AgtCommExGST  AS Nett,
	t.GSTGross - t.GSTAgtComm as GSTNett, 
	t.AccountingPeriod,
	e.IssuedDate
from
	[db-au-cmdwh].dbo.corpEMC e
	join [db-au-cmdwh].dbo.corpTaxes t on
		e.QuoteKey = t.QuoteKey and
		e.EMCKey = t.ItemKey
where
	e.BankRecord is null

union

select
	t.CountryKey,
	t.QuoteKey,
	t.ItemKey,
	t.QuoteID,
	t.ItemID, 
	t.ItemType, 
	t.PropBal,  
	t.UWSaleExGST, 
	t.GSTGross, 
	t.AgtCommExGST, 
	t.GSTAgtComm, 
	(t.UWSaleExGST - t.AgtCommExGST) AS Nett, 
	(t.GSTGross - t.GSTAgtComm) as GSTNett, 
	t.AccountingPeriod,
	d.IssuedDate
from 
	[db-au-cmdwh].dbo.corpDaysPaid d
	join [db-au-cmdwh].dbo.corpTaxes t on 
		d.QuoteKey = t.QuoteKey and
		d.DaysPaidKey = t.ItemKey
where 
	d.BankRecord Is Null
GO
