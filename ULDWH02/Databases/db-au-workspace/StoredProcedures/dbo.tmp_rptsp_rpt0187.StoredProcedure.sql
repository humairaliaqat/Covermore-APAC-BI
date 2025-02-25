USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0187]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_rptsp_rpt0187]  
									@ReportingPeriod varchar(30),
                  @StartDate varchar(10),
                  @EndDate varchar(10)
as

begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0187
--  Author:         Linus Tor
--  Date Created:   20110810
--  Description:    This stored procedure returns multiple claims paid to the same bank account
--
--  Parameters:     @ReportingPeriod: default date range or '_User Defined'
--                  @StartDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--                  @EndDate: if _User Defined enter date value (Format YYYY-MM-DD eg. 2010-01-01).
--  
--  Change History: 20110810 - LT - Created
--                  20111018 - LS - Change claim instance sort: 
--                                  ClaimNo Asc to PaymentDate Desc, ClaimNo Asc
--                  20110821 - LS - Refactor
--                                  Use Name audit table, last name before payment
--                                  group by account number instead of account number + name
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
  @ReportingPeriod = 'Yesterday', 
  @StartDate = null, 
  @EndDate = null
*/

	declare @rptStartDate datetime
	declare @rptEndDate datetime
	declare @sql nvarchar(max)
	declare @thisSession varchar(36)

	set @thisSession = newid()

	/* get reporting dates */
	if @ReportingPeriod = '_User Defined'
		select 
			@rptStartDate = convert(smalldatetime,@StartDate), 
			@rptEndDate = convert(smalldatetime,@EndDate)
	  
	else
		select 
			@rptStartDate = StartDate, 
			@rptEndDate = EndDate
		from [db-au-cmdwh].dbo.vDateRange
		where DateRange = @ReportingPeriod

	--get all direct debit payments in reporting period
	set @sql = 
		'
		set nocount on
		
		OPEN SYMMETRIC KEY BankAccountSymmetricKey
		DECRYPTION BY CERTIFICATE BankAccountCertificate

		if object_id(''tempdb..[##rpt0187_payment_' + @thisSession + ']'') is not null 
			drop table [##rpt0187_payment_' + @thisSession + ']

		select
			s.SECHEQUE_ID as ChequeID,
			s.SECHEQUE as ChequeNo,
			s.SECLAIM as ClaimNo,
			s.SESTATUS as [Status],
			s.SETRANS as TransactionType,
			s.SECURR as Currency,
			s.SETOTAL as Amount,
			s.SEPAYDATE as PaymentDate,
			n.NameID,
			n.Title,
			n.FirstName,
			n.LastName,
			n.AccountName,
			n.AccountNumber
		into [##rpt0187_payment_' + @thisSession + ']
		from
			wills.claims.dbo.SECHEQUE s
			cross apply
			(
				select top 1 
					n.KN_ID as NameID,
					n.KNTITLE as Title,
					n.KNFIRST as FirstName,
					n.KNSURNAME as LastName,
					n.KNACCTNAME as AccountName,
					replace(convert(varchar(256), DecryptByKey(n.KNEncryptBSB)), ''-'', '''') + '' '' + convert(varchar(256), DecryptByKey(n.KNEncryptACCT)) as AccountNumber
				from wills.claims.dbo.AUDIT_KLNAMES n
				where 
					(n.KNPROV_ID = 0 or n.KNPROV_ID is null) and
					s.SECLAIM = n.KNCLAIM_ID and
					s.SEPAYEE_ID = n.KN_ID and 
					n.AUDIT_DATETIME <= s.SEPAYDATE and
					n.KNEncryptBSB is not null
				order by n.AUDIT_DATETIME desc
			) n
		where
			s.SESTATUS = ''PAID'' and
			s.SETRANS = ''DD'' and
			s.SEPAYDATE >= ''' + convert(varchar(10), @rptStartDate, 120) + ''' and 
			s.SEPAYDATE <  dateadd(day, 1, ''' + convert(varchar(10),@rptEndDate,120) + ''')

		' +

	--get all historical Direct Debit Payment bank account and claim numbers from 2000-01-01 and <= @rptEndDate
		'
		if object_id(''tempdb..[##rpt0187_account_' + @thisSession + ']'') is not null 
			drop table [##rpt0187_account_' + @thisSession + ']

		;with cte_ddhistory as
		(
			select
				n.AccountNumber,
				n.AccountName,
				s.SECLAIM as ClaimNo,
				s.SEPAYDATE as PaymentDate
			from
				wills.claims.dbo.SECHEQUE s
				cross apply
				(
					select top 1 
						n.KN_ID as NameID,
						n.KNTITLE as Title,
						n.KNFIRST as FirstName,
						n.KNSURNAME as LastName,
						n.KNACCTNAME as AccountName,
						replace(convert(varchar(256), DecryptByKey(n.KNEncryptBSB)), ''-'', '''') + '' '' + convert(varchar(256), DecryptByKey(n.KNEncryptACCT)) as AccountNumber
					from wills.claims.dbo.AUDIT_KLNAMES n
					where 
						(n.KNPROV_ID = 0 or n.KNPROV_ID is null) and
						s.SECLAIM = n.KNCLAIM_ID and
						s.SEPAYEE_ID = n.KN_ID and 
						n.AUDIT_DATETIME <= s.SEPAYDATE and
						n.KNEncryptBSB is not null
					order by n.AUDIT_DATETIME desc
				) n
			where
				s.SESTATUS = ''PAID'' and
				s.SETRANS = ''DD'' and
				s.SEPAYDATE >= ''2000-01-01'' and 
				s.SEPAYDATE <  dateadd(day, 1, ''' + convert(varchar(10),@rptEndDate,120) + ''')
		)
		select
			AccountNumber,
			AccountName,
			ClaimNo,
			PaymentDate
		into [##rpt0187_account_' + @thisSession + ']
		from cte_ddhistory t
		where exists
			(
				select null
				from [##rpt0187_payment_' + @thisSession + '] r
				where r.AccountNumber = t.AccountNumber
			)

		CLOSE SYMMETRIC KEY BankAccountSymmetricKey;
		
		select * from [##rpt0187_account_' + @thisSession + ']'

	if object_id('tempdb..#rpt0187_account') is not null 
		drop table #rpt0187_account

	create table #rpt0187_account
	(
		AccountNumber varchar(100) null,
		AccountName varchar(80) null,
		ClaimNo int null,
		PaymentDate datetime null
	)

	--print @sql

	insert #rpt0187_account
	exec [WILLS].[Claims].dbo.sp_executesql @statement = @sql

	;with cte_ordered as
	(    
		select distinct
			a.AccountName,
			a.AccountNumber,
			a.ClaimNo,
			row_number() over (partition by a.AccountNumber order by a.PaymentDate desc, a.ClaimNo) as ClaimNoOrder
		from #rpt0187_Account a
		where 
			a.AccountNumber in
			(
				select a.AccountNumber
				from #rpt0187_account a
				group by a.AccountNumber
				having count(a.ClaimNo) > 1
			)
	)
	select 
		AccountNumber,
		(
			select top 1 AccountName
			from cte_ordered n
			where n.AccountNumber = t.AccountNumber
		) AccountName,
		ClaimNo,
		'Claim No. Instance ' + convert(varchar, ClaimNoOrder) as ClaimNoOrder,
		@rptStartDate as rptStartDate,
		@rptEndDate as rptEndDate
	from cte_ordered t
	where ClaimNoOrder < 10

	if object_id('tempdb..#rpt0187_account') is not null 
		drop table #rpt0187_account

end
GO
