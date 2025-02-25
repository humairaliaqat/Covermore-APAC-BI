USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpIndividualContact]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpIndividualContact
-- =============================================
create PROCEDURE [dbo].[etlsp_ETL083_pnpIndividualContact]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(100),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (
        IndividualID varchar(50),
        ContactTypeID int,
        ContactType nvarchar(50),
        ContactClass nvarchar(50),
        Contact nvarchar(4000),
        ContactExt nvarchar(4000),
        UseContact varchar(5),
        CommInstructions nvarchar(4000),
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

    if object_id('[db-au-dtc].dbo.pnpIndividualContact') is null
    begin
        create table [db-au-dtc].[dbo].[pnpIndividualContact](
            IndividualContactSK int identity(1,1) primary key,
            IsCurrent tinyint,
            StartDate date,
            EndDate date,
            IndividualID varchar(50),
            ContactTypeID int,
            ContactType nvarchar(50),
            ContactClass nvarchar(50),
            Contact nvarchar(4000),
            ContactExt nvarchar(4000),
            UseContact varchar(5),
            CommInstructions nvarchar(4000),
            index idx_pnpIndividualContact_IndividualID nonclustered (IndividualID),
            index idx_pnpIndividualContact_ContactTypeID nonclustered (ContactTypeID)
        )
    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            convert(varchar, ic.kindid) as IndividualID,
            ic.kcontacttypeid as ContactTypeID,
            ct.contacttype as ContactType,
            cc.contactclass as ContactClass,
            --20180607, LL, convert ntext to nvarcahr(4000)
            convert(nvarchar(4000), ic.contact) as Contact,
            convert(nvarchar(4000), ic.contactext) as ContactExt,
            ic.usecontact as UseContact,
            convert(nvarchar(4000), ic.comminstructions) as CommInstructions
        into #src
        from
            penelope_irindcontact_audtc ic
            left join penelope_sacontacttype_audtc ct on ct.kcontacttypeid = ic.kcontacttypeid
            left join penelope_sscontactclass_audtc cc on cc.kcontactclassid = ct.kcontactclassid

        select @sourcecount = count(*) from #src


        -- all non-id fields are type 2 at this stage
        merge [db-au-dtc].dbo.pnpIndividualContact as tgt
        using #src
            on #src.IndividualID = tgt.IndividualID and #src.ContactTypeID = tgt.ContactTypeID
        when not matched by target then
            insert (
                IsCurrent, StartDate, EndDate,
                IndividualID, ContactTypeID, ContactType, ContactClass,
                Contact, ContactExt, UseContact, CommInstructions
            )
            values (
                1, '1900-01-01', '9999-12-31',
                #src.IndividualID, #src.ContactTypeID, #src.ContactType, #src.ContactClass,
                #src.Contact, #src.ContactExt, #src.UseContact, #src.CommInstructions
            )
        when matched
            and tgt.IsCurrent = 1
            and (
                tgt.ContactType <> #src.ContactType
                or tgt.ContactClass <> #src.ContactClass
                or tgt.Contact <> #src.Contact
                or tgt.ContactExt <> #src.ContactExt
                or tgt.UseContact <> #src.UseContact
                or tgt.CommInstructions <> #src.CommInstructions
            )
            then    -- expire current records
            update set
                tgt.IsCurrent = 0,
                tgt.EndDate = dateadd(day, -1, getdate())

        output
            #src.IndividualID, #src.ContactTypeID, #src.ContactType, #src.ContactClass,
            #src.Contact, #src.ContactExt, #src.UseContact, #src.CommInstructions,
            $action as MergeAction
        into @mergeoutput;

        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

        -- insert current records for type 2 changes
        insert into [db-au-dtc]..pnpIndividualContact (
            IsCurrent, StartDate, EndDate,
            IndividualID, ContactTypeID, ContactType, ContactClass,
            Contact, ContactExt, UseContact, CommInstructions
        )
        select
            1, getdate(), '9999-12-31',
            IndividualID, ContactTypeID, ContactType, ContactClass,
            Contact, ContactExt, UseContact, CommInstructions
        from @mergeoutput
        where MergeAction = 'UPDATE'

        select @insertcount = @insertcount + sum(case when MergeAction = 'update' then 1 else 0 end)
        from @mergeoutput


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

END




GO
