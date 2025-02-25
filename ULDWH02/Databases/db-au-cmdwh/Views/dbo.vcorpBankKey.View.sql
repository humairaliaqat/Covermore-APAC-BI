USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vcorpBankKey]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vcorpBankKey]
as

select
	b.CountryKey,
	'DaysPaid' as BankRecordType,
	dp.QuoteKey,
	dp.BankRecordKey
from
	[db-au-cmdwh].dbo.corpBank b
	right outer join [db-au-cmdwh].dbo.corpDaysPaid dp on
		b.BankRecordKey = dp.BankRecordKey

union all
			
select
	b.CountryKey,
	'Closing' as BankRecordType,
	cl.QuoteKey,
	cl.BankRecordKey
from
	[db-au-cmdwh].dbo.corpBank b
	right outer join [db-au-cmdwh].dbo.corpClosing cl on
		b.BankRecordKey = cl.BankRecordKey
		
union all

select
	b.CountryKey,
	'EMC' as BankRecordType,
	em.QuoteKey,
	em.BankRecordKey
from
	[db-au-cmdwh].dbo.corpBank b
	right outer join [db-au-cmdwh].dbo.corpEMC em on
		b.BankRecordKey = em.BankRecordKey
		
union all

select
	b.CountryKey,
	'Luggage' as BankRecordType,
	lu.QuoteKey,
	lu.BankRecordKey
from
	[db-au-cmdwh].dbo.corpBank b
	right outer join [db-au-cmdwh].dbo.corpLuggage lu on
		b.BankRecordKey = lu.BankRecordKey
GO
