USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpInvoice]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpInvoice]
AS

-- =============================================
-- Author:			Vincent Lam
-- create date:		2017-04-19
-- Description:    Transformation - pnpInvoice
-- Change History:
--		20180313 - DM - Included lines to create the "header" of a Credit from Penelope. The "invoice number" will be the Credit number inverse (negative).
--		20180314 - SD - Commented changes made on previous day, as it was giving duplicate invoice records for Invoice ID 280
--		20180314 - DM - Issue fixed as above error. The InvoiceLine modification date was different for Invoice ID 280. Adjusted this date to be the slogin date this is not required (and Credit cannot be changed)
--		20181207 - LT - Added PersonInvoiceID, SummaryInvoiceID columns
--		20181211 - LT - Added BluebookItemSK
--
-- =============================================


BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    if object_id('[db-au-dtc].dbo.pnpInvoice') is null
    begin
        create table [db-au-dtc].[dbo].[pnpInvoice](
            InvoiceSK int identity(1,1) primary key,
            IndividualSK int,
            FunderSK int,
            InvoiceID varchar(50),
            IndividualID varchar(50),
            FunderID varchar(50),
            kfunagreid int,
            InvoiceDate datetime2,
            BillTo nvarchar(100),
            BillToOverwrite nvarchar(100),
            [Name] nvarchar(100),
            AddressLine1 nvarchar(60),
            AddressLine2 nvarchar(60),
            City nvarchar(20),
            [State] nvarchar(20),
            Country nvarchar(30),
            Postcode nvarchar(12),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreatedBy nvarchar(20),
            UpdatedBy nvarchar(20),
            InvoicePosted varchar(5),
            BatchNumber varchar(50),
            PaymentTermsDue date,
            InvoiceFullApplied varchar(5),
            InvoicePartApplied varchar(5),
            InvoiceFullAppliedDate date,
            CurrencyCode nvarchar(10),
            CurrencyCountry nvarchar(30),
            CurrencySign nvarchar(10),
            Properties nvarchar(max),
            BatchName nvarchar(100),
            BatchPosted varchar(5),
            BatchDate datetime2,
            BatchPostDate datetime2,
            BatchCreatedDatetime datetime2,
            BatchUpdatedDatetime datetime2,
            BatchCreatedBy nvarchar(20),
            BatchUpdatedBy nvarchar(20),
            BatchSite nvarchar(30),
            BatchType nvarchar(10),
            InvoiceNumber varchar(50),
            OnHold tinyint,
            FeeBasisCode varchar(10),
            FeeBasis nvarchar(50),
            ApplyTo varchar(20),
            Amount money,
            TaxAmount money,
            TotalAmount money,
            DeletedDatetime datetime2,
            InvoiceReleaseDate datetime,
            VoidFlag bit default 0,
			PersonInvoiceID varchar(50) null,
			SummaryInvoiceID varchar(50) null,
            index idx_pnpInvoice_IndividualSK nonclustered (IndividualSK),
            index idx_pnpInvoice_FunderSK nonclustered (FunderSK),
            index idx_pnpInvoice_InvoiceID nonclustered (InvoiceID),
            index idx_pnpInvoice_IndividualID nonclustered (IndividualID),
            index idx_pnpInvoice_FunderID nonclustered (FunderID),
            index idx_pnpInvoice_BatchNumber nonclustered (BatchNumber),
            index idx_pnpInvoice_InvoicePosted nonclustered (InvoicePosted),
            index idx_pnpInvoice_BatchPosted nonclustered (BatchPosted),
            index idx_pnpInvoice_InvoiceDate_InvoiceSK nonclustered (InvoiceDate, InvoiceSK),
            index idx_pnpInvoice_InvoiceID_FeeBasisCode nonclustered (InvoiceID, FeeBasisCode)
        )
    end;

    if object_id('[db-au-stage].dbo.penelope_btinvoice_audtc') is null
        goto Finish

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(100),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Penelope',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            i.IndividualSK,
            f.FunderSK,
            convert(varchar, inv.kinvoicenoid) as InvoiceID,
            convert(varchar, inv.kindid) as IndividualID,
            convert(varchar, inv.kfunderid) as FunderID,
            inv.kfunagreid as kfunagreid,
            inv.sinvdate as InvoiceDate,
            inv.invbillto as BillTo,
            inv.invname as [Name],
            inv.invaddress1 as AddressLine1,
            inv.invaddress2 as AddressLine2,
            inv.invcity as City,
            inv.invprovstate as [State],
            inv.invcountry as Country,
            inv.invpczip as Postcode,
            inv.slogin as CreatedDatetime,
            inv.slogmod as UpdatedDatetime,
            inv.sloginby as CreatedBy,
            inv.slogmodby as UpdatedBy,
            inv.invposted as InvoicePosted,
            inv.batchno as BatchNumber,
            inv.paymenttermsdue as PaymentTermsDue,
            inv.invfullapplied as InvoiceFullApplied,
            inv.invpartapplied as InvoicePartApplied,
            inv.invfullapplieddate as InvoiceFullAppliedDate,
            ic.currencycode as CurrencyCode,
            ic.country as CurrencyCountry,
            ic.currencysign as CurrencySign,
            inv.Properties as Properties,
            b.batchname as BatchName,
            b.batchposted as BatchPosted,
            b.batchdate as BatchDate,
            b.batchpostdate as BatchPostDate,
            b.slogin as BatchCreatedDatetime,
            b.slogmod as BatchUpdatedDatetime,
            b.sloginby as BatchCreatedBy,
            b.slogmodby as BatchUpdatedBy,
            s.sitename as BatchSite,
            convert(varchar, inv.kinvoicenoid) as InvoiceNumber,
            dateadd(
                day,
                case
                    when datename(dw, b.batchpostdate) = 'Friday' then 3
                    when datename(dw, b.batchpostdate) = 'Saturday' then 2
                    else 1
                end,
                b.batchpostdate
            ) as InvoiceReleaseDate,
			convert(varchar(50),null) as PersonInvoiceID,
			convert(varchar(50),null) as SummaryInvoiceID,
			convert(int,null) as BlueBookSK
        into #src
        from
            penelope_btinvoice_audtc inv
            left join penelope_btbatchinfo_audtc b on b.batchno = inv.batchno
            left join penelope_sasite_audtc s on s.ksiteid = b.ksiteidbatchedat
            left join penelope_sainvoicecurrencysign_audtc ic
                on ic.kinvoicecurrencysignid = inv.kinvoicecurrencysignid
            outer apply 
			(
                select top 1 IndividualSK
                from [db-au-dtc].dbo.pnpIndividual
                where IndividualID = convert(varchar, inv.kindid)
                    and IsCurrent = 1
            ) i
            outer apply 
			(
                select top 1 FunderSK
                from [db-au-dtc].dbo.pnpFunder
                where FunderID = convert(varchar, inv.kfunderid) and IsCurrent = 1
            ) f
			

        --ADJ 20180313 - New code for Credit headers.
        INSERT INTO #src
        select DISTINCT i.IndividualSK,
            f.FunderSK,
            convert(varchar, CIL.kreceiptidret * -1) as InvoiceID,
            convert(varchar, inv.kindid) as IndividualID,
            convert(varchar, inv.kfunderid) as FunderID,
            inv.kfunagreid as kfunagreid,
            CIL.slogin as InvoiceDate,
            convert(nvarchar(max), inv.invbillto) as BillTo,
            convert(nvarchar(max), inv.invname) as [Name],
            convert(nvarchar(max), inv.invaddress1) as AddressLine1,
            convert(nvarchar(max), inv.invaddress2) as AddressLine2,
            convert(nvarchar(max), inv.invcity) as City,
            convert(nvarchar(max), inv.invprovstate) as [State],
            convert(nvarchar(max), inv.invcountry) as Country,
            convert(nvarchar(max), inv.invpczip) as Postcode,
            CIL.slogin as CreatedDatetime,
            null as UpdatedDatetime,
            convert(nvarchar(max), CIL.sloginby) as CreatedBy,
            convert(nvarchar(max), CIL.slogmodby) as UpdatedBy,
            CIL.invposted as InvoicePosted,
            CIL.kreceiptidret * -1 as BatchNumber,
            null as PaymentTermsDue,
            null as InvoiceFullApplied,
            null as InvoicePartApplied,
            null as InvoiceFullAppliedDate,
            convert(nvarchar(max), ic.currencycode) as CurrencyCode,
            convert(nvarchar(max), ic.country) as CurrencyCountry,
            ic.currencysign as CurrencySign,
            convert(nvarchar(max), inv.Properties) as Properties,
            'Credit' as BatchName,
            1 as BatchPosted,
            CIL.slogin as BatchDate,
            CIL.slogin as BatchPostDate,
            CIL.slogin as BatchCreatedDatetime,
            null  as BatchUpdatedDatetime,
            CIL.sloginby as BatchCreatedBy,
            CIL.slogmodby as BatchUpdatedBy,
            s.sitename as BatchSite,
            convert(varchar, CIL.kreceiptidret * -1) as InvoiceNumber,
            dateadd(
                day,
                case
                    when datename(dw, CIL.slogin) = 'Friday' then 3
                    when datename(dw, CIL.slogin) = 'Saturday' then 2
                    else 1
                end,
                CIL.slogin
            ) as InvoiceReleaseDate,
			convert(varchar(50),null) as PersonInvoiceID,
			convert(varchar(50),null) as SummaryInvoiceID,
			convert(int,null) as BlueBookSK
        from penelope_btinvline_audtc CIL
        JOIN penelope_btinvline_audtc IL ON CIL.kinvlineidret = IL.kinvlineid
        JOIN penelope_btinvoice_audtc inv ON IL.kinvoicenoid = inv.kinvoicenoid
        left join penelope_btbatchinfo_audtc b on b.batchno = inv.batchno
        left join penelope_sasite_audtc s on s.ksiteid = b.ksiteidbatchedat
        left join penelope_sainvoicecurrencysign_audtc ic
            on ic.kinvoicecurrencysignid = inv.kinvoicecurrencysignid
        outer apply (
            select top 1 IndividualSK
            from [db-au-dtc].dbo.pnpIndividual
            where IndividualID = convert(varchar, inv.kindid)
                and IsCurrent = 1
        ) i
        outer apply (
            select top 1 FunderSK
            from [db-au-dtc].dbo.pnpFunder
            where FunderID = convert(varchar, inv.kfunderid) and IsCurrent = 1
        ) f
        where CIL.kreceiptidret is not null

		--20181207 - LT - update #src table with PersonInvoiceID and SummaryInvoiceID
		--20181211 - LT -  update #src table with BlueBookSK
		update src
		set src.PersonInvoiceID = pinv.PersonInvoiceID,
			src.SummaryInvoiceID = pinv.SummaryInvoiceID,
			src.BlueBookSK = pinv.BlueBookSK
		from
			#src src
			outer apply
			(
				select top 1 
					i.PersonInvoiceID,
					i.SummaryInvoiceID,
					bb.BlueBookSK
				from
					[db-au-stage].[dbo].PenelopeDataMart_Invoice_InvoiceData_audtc i
					outer apply
					(
						select top 1 BlueBookSK
						from [db-au-dtc].dbo.pnpBlueBook
						where BluebookID = i.PersonInvoiceID
					) bb
				where
					i.InvoiceID = src.InvoiceID
			) pinv

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpInvoice as tgt
        using #src
            on #src.InvoiceID = tgt.InvoiceID
        when matched then
            update set
                tgt.IndividualSK = #src.IndividualSK,
                tgt.FunderSK = #src.FunderSK,
                tgt.IndividualID = #src.IndividualID,
                tgt.FunderID = #src.FunderID,
                tgt.kfunagreid = #src.kfunagreid,
                tgt.InvoiceDate = #src.InvoiceDate,
                tgt.BillTo = #src.BillTo,
                tgt.[Name] = #src.[Name],
                tgt.AddressLine1 = #src.AddressLine1,
                tgt.AddressLine2 = #src.AddressLine2,
                tgt.City = #src.City,
                tgt.[State] = #src.[State],
                tgt.Country = #src.Country,
                tgt.Postcode = #src.Postcode,
                tgt.UpdatedDatetime = #src.UpdatedDatetime,
                tgt.UpdatedBy = #src.UpdatedBy,
                tgt.InvoicePosted = #src.InvoicePosted,
                tgt.BatchNumber = #src.BatchNumber,
                tgt.PaymentTermsDue = #src.PaymentTermsDue,
                tgt.InvoiceFullApplied = #src.InvoiceFullApplied,
                tgt.InvoicePartApplied = #src.InvoicePartApplied,
                tgt.InvoiceFullAppliedDate = #src.InvoiceFullAppliedDate,
                tgt.CurrencyCode = #src.CurrencyCode,
                tgt.CurrencyCountry = #src.CurrencyCountry,
                tgt.CurrencySign = #src.CurrencySign,
                tgt.Properties = #src.Properties,
                tgt.BatchName = #src.BatchName,
                tgt.BatchPosted = #src.BatchPosted,
                tgt.BatchDate = #src.BatchDate,
                tgt.BatchPostDate = #src.BatchPostDate,
                tgt.BatchCreatedDatetime = #src.BatchCreatedDatetime,
                tgt.BatchUpdatedDatetime = #src.BatchUpdatedDatetime,
                tgt.BatchCreatedBy = #src.BatchCreatedBy,
                tgt.BatchUpdatedBy = #src.BatchUpdatedBy,
                tgt.BatchSite = #src.BatchSite,
                tgt.InvoiceNumber = #src.InvoiceNumber,
                tgt.InvoiceReleaseDate = #src.InvoiceReleaseDate,
                tgt.DeletedDatetime = null,
				tgt.PersonInvoiceID = #src.PersonInvoiceID,
				tgt.SummaryInvoiceID = #src.SummaryInvoiceID,
				tgt.BlueBookSK = #src.BlueBookSK
        when not matched by target then
            insert (
                IndividualSK,
                FunderSK,
                InvoiceID,
                IndividualID,
                kfunagreid,
                InvoiceDate,
                BillTo,
                [Name],
                AddressLine1,
                AddressLine2,
                City,
                [State],
                Country,
                Postcode,
                CreatedDatetime,
                UpdatedDatetime,
                CreatedBy,
                UpdatedBy,
                FunderID,
                InvoicePosted,
                BatchNumber,
                PaymentTermsDue,
                InvoiceFullApplied,
                InvoicePartApplied,
                InvoiceFullAppliedDate,
                CurrencyCode,
                CurrencyCountry,
                CurrencySign,
                Properties,
                BatchName,
                BatchPosted,
                BatchDate,
                BatchPostDate,
                BatchCreatedDatetime,
                BatchUpdatedDatetime,
                BatchCreatedBy,
                BatchUpdatedBy,
                BatchSite,
                InvoiceNumber,
                InvoiceReleaseDate,
				PersonInvoiceID,
				SummaryInvoiceID,
				BlueBookSK
            )
            values (
                #src.IndividualSK,
                #src.FunderSK,
                #src.InvoiceID,
                #src.IndividualID,
                #src.kfunagreid,
                #src.InvoiceDate,
                #src.BillTo,
                #src.[Name],
                #src.AddressLine1,
                #src.AddressLine2,
                #src.City,
                #src.[State],
                #src.Country,
                #src.Postcode,
                #src.CreatedDatetime,
                #src.UpdatedDatetime,
                #src.CreatedBy,
                #src.UpdatedBy,
                #src.FunderID,
                #src.InvoicePosted,
                #src.BatchNumber,
                #src.PaymentTermsDue,
                #src.InvoiceFullApplied,
                #src.InvoicePartApplied,
                #src.InvoiceFullAppliedDate,
                #src.CurrencyCode,
                #src.CurrencyCountry,
                #src.CurrencySign,
                #src.Properties,
                #src.BatchName,
                #src.BatchPosted,
                #src.BatchDate,
                #src.BatchPostDate,
                #src.BatchCreatedDatetime,
                #src.BatchUpdatedDatetime,
                #src.BatchCreatedBy,
                #src.BatchUpdatedBy,
                #src.BatchSite,
                #src.InvoiceNumber,
                #src.InvoiceReleaseDate,
				#src.PersonInvoiceID,
				#src.SummaryInvoiceID,
				#src.BlueBookSK
            )
        --20180812 - LL - change Deleted logic, reading the new id table
        --when not matched by source and left(tgt.InvoiceID,3) <> 'CLI' then
        --    update set
        --        tgt.DeletedDatetime = current_timestamp

        output $action into @mergeoutput;

        --20180812 - LL - change Deleted logic, reading the new id table
        --20180614, LL, safety check
        declare 
            @new int, 
            @old int

        select 
            @new = count(*)
        from
            penelope_btinvoice_audtc_id

        select 
            @old = count(*)
        from
            [db-au-dtc].dbo.pnpInvoice t
        where
            t.InvoiceID not like 'CLI_%' and
            t.InvoiceID not like 'DUMMY%' and
            try_convert(bigint, t.InvoiceID) > 0 and
            t.DeletedDatetime is null 

        select @old, @new

        update t
        set
            DeletedDateTime = null
        from
            [db-au-dtc].dbo.pnpInvoice t
        where
            t.InvoiceID not like 'CLI_%' and
            t.InvoiceID not like 'DUMMY%' and
            t.DeletedDatetime is not null and
            exists
            (
                select
                    null
                from
                    penelope_btinvoice_audtc_id id
                where
                    id.kinvoicenoid = try_convert(bigint, t.InvoiceID)
            ) and
            try_convert(bigint, t.InvoiceID) > 0

        begin

            update t
            set
                DeletedDateTime = current_timestamp
            from
                [db-au-dtc].dbo.pnpInvoice t
            where
                t.InvoiceID not like 'CLI_%' and
                t.InvoiceID not like 'DUMMY%' and
                t.DeletedDatetime is null and
                not exists
                (
                    select
                        null
                    from
                        penelope_btinvoice_audtc_id id
                    where
                        id.kinvoicenoid = try_convert(bigint, t.InvoiceID)
                ) and

                try_convert(bigint, t.InvoiceID) > 0

             end


        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

Finish:
END
GO
