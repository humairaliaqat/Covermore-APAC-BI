USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpFunder]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL083_pnpFunder]
as
begin

-- =============================================
-- Author:          Vincent Lam
-- create date:     2017-04-19
-- Description:     Transformation - pnpFunder
--                  20180607 - LL - refactoring
--                                  remove direct calls to source server (Account Manager)
--					20181029 - LT - updated pnpFunder table definition and increased column sizes to avoid truncation string/binary error
-- =============================================


    -- set nocount on added to prevent extra result sets from
    -- interfering with select statements.
    set nocount on;

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(100),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table
    (
        FunderID varchar(50),
        Funder nvarchar(250),
        DisplayName nvarchar(250),
        [Type] nvarchar(60),
        Type2 nvarchar(50),
        Class nvarchar(4000),
        BillType nvarchar(30),
        StatementCycle nvarchar(25),
        TaxSched nvarchar(30),
        TaxSchedShort nvarchar(4),
        TaxSchedNotes nvarchar(4000),
        FunderState nvarchar(25),
        BillTo nvarchar(50),
        AddressLine1 nvarchar(60),
        AddressLine2 nvarchar(60),
        City nvarchar(20),
        [State] nvarchar(20),
        StateShort nvarchar(10),
        Country nvarchar(30),
        CountryShort nvarchar(3),
        Country2CharCode nchar(2),
        Postcode nvarchar(12),
        Phone1 nvarchar(20),
        Phone2 nvarchar(20),
        Fax nvarchar(20),
        [URL] nvarchar(150),
        Notes nvarchar(1000),
        NotesLong nvarchar(MAX),
        CreatedDatetime datetime2,
        UpdatedDatetime datetime2,
        CreatedBy nvarchar(20),
        UpdatedBy nvarchar(20),
        DebtorCode varchar(10),
        KeyAccount varchar(5),
        ABN varchar(50),
        MergeAction varchar(20)
    )

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

    if object_id('[db-au-dtc].dbo.pnpFunder') is null
    begin

        create table [db-au-dtc].dbo.pnpFunder
        (
            [FunderSK] int identity(1, 1) primary key,
			[IsCurrent] [tinyint] NULL,
			[StartDate] [date] NULL,
			[EndDate] [date] NULL,
			[FunderID] [varchar](50) NULL,
			[Funder] [nvarchar](500) NULL,
			[DisplayName] [nvarchar](500) NULL,
			[Type] [nvarchar](200) NULL,
			[Type2] [nvarchar](200) NULL,
			[Class] [nvarchar](max) NULL,
			[BillType] [nvarchar](100) NULL,
			[StatementCycle] [nvarchar](100) NULL,
			[TaxSched] [nvarchar](100) NULL,
			[TaxSchedShort] [nvarchar](50) NULL,
			[TaxSchedNotes] [nvarchar](max) NULL,
			[FunderState] [nvarchar](100) NULL,
			[BillTo] [nvarchar](100) NULL,
			[AddressLine1] [nvarchar](200) NULL,
			[AddressLine2] [nvarchar](200) NULL,
			[City] [nvarchar](200) NULL,
			[State] [nvarchar](200) NULL,
			[StateShort] [nvarchar](100) NULL,
			[Country] [nvarchar](200) NULL,
			[CountryShort] [nvarchar](50) NULL,
			[Country2CharCode] [nchar](50) NULL,
			[Postcode] [nvarchar](100) NULL,
			[Phone1] [nvarchar](100) NULL,
			[Phone2] [nvarchar](100) NULL,
			[Fax] [nvarchar](100) NULL,
			[URL] [nvarchar](400) NULL,
			[Notes] [nvarchar](2000) NULL,
			[NotesLong] [nvarchar](max) NULL,
			[CreatedDatetime] [datetime2](7) NULL,
			[UpdatedDatetime] [datetime2](7) NULL,
			[CreatedBy] [nvarchar](100) NULL,
			[UpdatedBy] [nvarchar](100) NULL,
			[PrimaryIndustry] [nvarchar](400) NULL,
			[DebtorCode] [varchar](100) NULL,
			[KeyAccount] [varchar](100) NULL,
			[ABN] [varchar](200) NULL,
			[AccountManager] [nvarchar](300) NULL,
            index idx_pnpFunder_FunderID nonclustered (FunderID),
            index idx_pnpFunder_IsCurrent nonclustered (IsCurrent),
            index idx_pnpFunder_StartDate nonclustered (StartDate),
            index idx_pnpFunder_EndDate nonclustered (EndDate),
            index idx_pnpFunder_Funder_IsCurrent nonclustered (IsCurrent, Funder),
            index idx_pnpFunder_AccountManager nonclustered (AccountManager)
        )

    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null
            drop table #src

        select
            convert(varchar, f.kfunderid) as FunderID,
            f.funorg as Funder,
            e.fundexp1 as DisplayName,
            ft1.fundertype as [Type],
            ft2.fundertype2 as Type2,
            fc.funderclass as Class,
            bt.billtype as BillType,
            sc.statementcycle as StatementCycle,
            ts.taxschedname as TaxSched,
            ts.taxschedshort as TaxSchedShort,
            ts.taxschednotes as TaxSchedNotes,
            fs.[state] as FunderState,
            f.funbillto as BillTo,
            f.funaddress1 as AddressLine1,
            f.funaddress2 as AddressLine2,
            f.funcity as City,
            ps.provstatename as [State],
            ps.provstateshort as StateShort,
            c.country as Country,
            c.countryshort as CountryShort,
            c.country2charcode as Country2CharCode,
            f.funpczip as Postcode,
            f.funphone1 as Phone1,
            f.funphone2 as Phone2,
            f.funfax as Fax,
            f.funurl as [URL],
            f.funnotes as Notes,
            f.funnoteslong as NotesLong,
            f.slogin as CreatedDatetime,
            f.slogmod as UpdatedDatetime,
            f.sloginby as CreatedBy,
            f.slogmodby as UpdatedBy,
            e.fundexp2 as DebtorCode,
            e.fundexp5 as KeyAccount,
            [db-au-stage].dbo.xfn_StripHTML(e.fundexp9) as ABN
        into #src
        from
            penelope_frfunder_audtc f
            left join penelope_lufundertype_audtc ft1 on ft1.lufundertypeid = f.lufundertypeid
            left join penelope_lufundertype2_audtc ft2 on ft2.lufundertype2id = f.lufundertype2id
            left join penelope_ssfunderclass_audtc fc on fc.kfunderclassid = f.kfunderclassid
            left join penelope_ssbilltype_audtc bt on bt.kbilltypeid = f.kbilltypeid
            left join penelope_lustatementcycle_audtc sc on sc.lustatementcycleid = f.lustatementcycleid
            left join penelope_brtaxsched_audtc ts on ts.ktaxschedid = f.ktaxschedid
            left join penelope_lufunderstate_audtc fs on fs.lustateid = f.lustateid
            left join penelope_luprovstate_audtc ps on ps.luprovstateid = f.lufunprovsateid
            left join penelope_lucountry_audtc c on c.lucountryid = f.lufuncountryid
            left join penelope_frfundexp_audtc e on e.kfunderid = f.kfunderid

        select @sourcecount = count(*) from #src

        -- Handle Type 1 fields
        update [db-au-dtc].dbo.pnpFunder
        set
            Funder = #src.Funder,
            DisplayName = #src.DisplayName,
            [Type] = #src.[Type],
            Type2 = #src.Type2,
            Class = #src.Class,
            BillType = #src.BillType,
            StatementCycle = #src.StatementCycle,
            TaxSched = #src.TaxSched,
            TaxSchedShort = #src.TaxSchedShort,
            TaxSchedNotes = #src.TaxSchedNotes,
            BillTo = #src.BillTo,
            AddressLine1 = #src.AddressLine1,
            AddressLine2 = #src.AddressLine2,
            City = #src.City,
            [State] = #src.[State],
            StateShort = #src.StateShort,
            Country = #src.Country,
            CountryShort = #src.CountryShort,
            Country2CharCode = #src.Country2CharCode,
            Postcode = #src.Postcode,
            Phone1 = #src.Phone1,
            Phone2 = #src.Phone2,
            Fax = #src.Fax,
            [URL] = #src.[URL],
            Notes = #src.Notes,
            NotesLong = #src.NotesLong,
            UpdatedDatetime = #src.UpdatedDatetime,
            UpdatedBy = #src.UpdatedBy,
            DebtorCode = #src.DebtorCode,
            KeyAccount = #src.KeyAccount,
            ABN = #src.ABN
        from
            [db-au-dtc].dbo.pnpFunder tgt inner join #src
                on tgt.FunderID = #src.FunderID
                    and tgt.FunderState = #src.FunderState
        where
            IsCurrent = 1

        select @updatecount = @@ROWCOUNT


        -- Handle Type 2 fields
        merge [db-au-dtc].dbo.pnpFunder as tgt
        using #src
            on #src.FunderID = tgt.FunderID
        when not matched by target then
            insert (
                IsCurrent, StartDate, EndDate,
                FunderID, Funder, DisplayName, [Type], Type2, Class, BillType, StatementCycle, TaxSched, TaxSchedShort, TaxSchedNotes,
                FunderState, BillTo, AddressLine1, AddressLine2, City, [State], StateShort, Country, CountryShort, Country2CharCode,
                Postcode, Phone1, Phone2, Fax, [URL], Notes, NotesLong, CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy,
                DebtorCode, KeyAccount, ABN
            )
            values (
                1, '1900-01-01', '9999-12-31',
                #src.FunderID, #src.Funder, #src.DisplayName, #src.[Type], #src.Type2, #src.Class, #src.BillType, #src.StatementCycle, #src.TaxSched, #src.TaxSchedShort, #src.TaxSchedNotes,
                #src.FunderState, #src.BillTo, #src.AddressLine1, #src.AddressLine2, #src.City, #src.[State], #src.StateShort, #src.Country, #src.CountryShort, #src.Country2CharCode,
                #src.Postcode, #src.Phone1, #src.Phone2, #src.Fax, #src.[URL], #src.Notes, #src.NotesLong, #src.CreatedDatetime, #src.UpdatedDatetime, #src.CreatedBy, #src.UpdatedBy,
                #src.DebtorCode, #src.KeyAccount, #src.ABN
            )
        when matched
            and tgt.IsCurrent = 1
            and tgt.FunderState <> #src.FunderState
        then    -- expire current records
            update set
                tgt.IsCurrent = 0,
                tgt.EndDate = dateadd(day, -1, getdate())

        output
            #src.FunderID, #src.Funder, #src.DisplayName, #src.[Type], #src.Type2, #src.Class, #src.BillType, #src.StatementCycle, #src.TaxSched, #src.TaxSchedShort, #src.TaxSchedNotes,
            #src.FunderState, #src.BillTo, #src.AddressLine1, #src.AddressLine2, #src.City, #src.[State], #src.StateShort, #src.Country, #src.CountryShort, #src.Country2CharCode,
            #src.Postcode, #src.Phone1, #src.Phone2, #src.Fax, #src.[URL], #src.Notes, #src.NotesLong, #src.CreatedDatetime, #src.UpdatedDatetime, #src.CreatedBy, #src.UpdatedBy,
            #src.DebtorCode, #src.KeyAccount, #src.ABN,
            $action as MergeAction
        into @mergeoutput;

        -- insert current records for type 2 changes
        insert into [db-au-dtc].dbo.pnpFunder (
            IsCurrent, StartDate, EndDate,
            FunderID, Funder, DisplayName, [Type], Type2, Class, BillType, StatementCycle, TaxSched, TaxSchedShort, TaxSchedNotes,
            FunderState, BillTo, AddressLine1, AddressLine2, City, [State], StateShort, Country, CountryShort, Country2CharCode,
            Postcode, Phone1, Phone2, Fax, [URL], Notes, NotesLong, CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy,
            DebtorCode, KeyAccount, ABN
            )
        select
            1, getdate(), '9999-12-31',
            FunderID, Funder, DisplayName, [Type], Type2, Class, BillType, StatementCycle, TaxSched, TaxSchedShort, TaxSchedNotes,
            FunderState, BillTo, AddressLine1, AddressLine2, City, [State], StateShort, Country, CountryShort, Country2CharCode,
            Postcode, Phone1, Phone2, Fax, [URL], Notes, NotesLong, CreatedDatetime, UpdatedDatetime, CreatedBy, UpdatedBy,
            DebtorCode, KeyAccount, ABN
        from @mergeoutput
        where MergeAction = 'UPDATE'

        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = @updatecount + sum(case when MergeAction = 'update' then 1 else 0 end)
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

end

GO
