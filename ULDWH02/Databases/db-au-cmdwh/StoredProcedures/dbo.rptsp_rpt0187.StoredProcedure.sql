USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0187]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt0187]
    @Country varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null

as
begin

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
--                  20111021 - LS - Refactor
--                                  Use Name audit table, last name before payment
--                                  group by account number instead of account number + name
--                  20111025 - LS - add n.KNPAYMENTMETHODID = 1 filter in audit lookup
--                     10:09 - LS - remove it, it actually shows suspicious activity in audit data
--                  20120510 - LS - WILLS setting changed, unable to use insert exec (distributed transaction)
--                                  use tempbackup to store temporary tables instead
--                  20140410 - LS - Claims.Net 7.0, move to ULSQLAGR03
--                  20140814 - LS - use BI's data
--
/****************************************************************************************************/

--uncomment to debug
--declare
--    @Country varchar(2),
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10)
--select
--    @Country = 'AU',
--    @ReportingPeriod = 'yesterday',
--    @StartDate = null,
--    @EndDate = null

    set nocount on

    declare
        @rptStartDate datetime,
        @rptEndDate datetime,
        @sql nvarchar(max)

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod

    /* cleanup temporary table */
    if object_id('tempdb..#allpayment') is not null
        drop table #allpayment

    create table #allpayment
    (
        ChequeID int,
        ChequeNo bigint,
        ClaimNo int,
        Status varchar(10),
        TransactionType varchar(4),
        Currency varchar(4),
        Amount money,
        PaymentDate datetime,
        NameID int,
        Title nvarchar(50),
        Firstname nvarchar(100),
        Surname nvarchar(100),
        AccountName nvarchar(100),
        AccountNo nvarchar(500)
    )

    /* need to run this on [db-au-stage] context due to Key & Certificate for claim encryption are in there */
    /* it's there in the first place due to conflict with EMC key having same Id different algorithm */
    set @sql =
        '
        select
            cq.ChequeID,
            cq.ChequeNo,
            cq.ClaimNo,
            cq.Status,
            cq.TransactionType,
            cq.Currency,
            cq.Amount,
            convert(date, cq.PaymentDate) PaymentDate,
            cn.NameID,
            cn.Title,
            cn.Firstname,
            cn.Surname,
            cn.AccountName,
            cn.AccountNo
        from
            [db-au-cmdwh]..clmSecheque cq
            cross apply
            (
                select top 1
                    NameID,
                    Title,
                    Firstname,
                    Surname,
                    replace(
                        convert(varchar(250), decryptbykeyautocert(cert_id(''ClaimsCertificate''), null, EncryptBSB, 0, null)),
                        ''-'',
                        ''''
                    ) + '' '' +
                    convert(varchar(250), decryptbykeyautocert(cert_id(''ClaimsCertificate''), null, EncryptAccount, 0, null)) AccountNo,
                    AccountName
                from
                    [db-au-cmdwh]..clmAuditName cn
                where
                    cn.ClaimKey = cq.ClaimKey and
                    cn.NameID = cq.PayeeID and
                    isnull(cn.ProviderID, 0) = 0 and
                    cn.AuditDateTime <= cq.PaymentDate and
                    cn.EncryptBSB is not null
                order by
                    cn.AuditDateTime desc
            ) cn
        where
            cq.CountryKey = ''' + @Country + ''' and
            Status = ''Paid'' and
            TransactionType = ''DD'' and
            PaymentDate >= ''2000-01-01'' and
            PaymentDate <  ''' + convert(varchar(10), dateadd(day, 1, @rptEndDate), 120) + '''
        '

    insert into #allpayment
    exec [db-au-stage]..sp_executesql @sql

    alter table #allpayment add BIRowID bigint not null identity(1,1)
    create clustered index idx_main on #allpayment(BIRowID)
    create nonclustered index idx_account on #allpayment(AccountNo) include(ClaimNo, PaymentDate)

    select
        *
    from
        #allpayment
    where
        AccountNo in
        (
            select
                AccountNo
            from
                #allpayment
            group by
                AccountNo
            having
                count(distinct ClaimNo) > 1
        ) and
        AccountNo in
        (
            select
                AccountNo
            from
                #allpayment
            where
                PaymentDate >= @rptStartDate and
                PaymentDate <  dateadd(day, 1, @rptEndDate)
        )
    order by
        AccountNo,
        ClaimNo

end

GO
