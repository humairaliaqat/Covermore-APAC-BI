USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entCustomer]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entCustomer]
as
begin
/*
    20160817, LL, create
*/

    set nocount on

    exec etlsp_StagingIndex_EnterpriseMDM

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'EnterpriseMDM ODS',
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

    if object_id('[db-au-cmdwh].dbo.entCustomer') is null
    begin
    
        create table [db-au-cmdwh].dbo.entCustomer
        (
            BIRowID bigint identity(1,1) not null,
            CustomerID bigint not null,
            CreateDate datetime,
            UpdateDate datetime,
            DeleteDate datetime,
            ConsolidationID bigint,
            Status nvarchar(10),
            CustomerName nvarchar(255),
            CustomerRole nvarchar(50),
            Title nvarchar(20),
            FirstName nvarchar(100),
            MidName nvarchar(100),
            LastName nvarchar(100),
            Gender nvarchar(7),
            MaritalStatus nvarchar(15),
            DOB date,
            isDeceased bit,
            CurrentAddress nvarchar(614),
            CurrentEmail nvarchar(255),
            CurrentContact nvarchar(25),
            MergedTo bigint,
            FTS nvarchar(max),
            PrimaryScore int,
            SecondaryScore int,
            SanctionScore int,
            SanctionReference varchar(max),
            UpdateBatchID bigint
        )

        create unique clustered index idx_entCustomer_BIRowID on [db-au-cmdwh].dbo.entCustomer(BIRowID)
        create nonclustered index idx_entCustomer_Address on [db-au-cmdwh].dbo.entCustomer(LastName,CurrentAddress) include (CustomerID,FirstName)
        create nonclustered index idx_entCustomer_CurrentAddress on [db-au-cmdwh].dbo.entCustomer(CurrentAddress) include (BIRowID,CustomerID)
        create nonclustered index idx_entCustomer_CreateDate on [db-au-cmdwh].dbo.entCustomer(CreateDate) include (BIRowID,CustomerID)
        create nonclustered index idx_entCustomer_CustomerID on [db-au-cmdwh].dbo.entCustomer(CustomerID) include (BIRowID,MergedTo,FirstName,CreateDate,UpdateDate,Status,CustomerName,CustomerRole,Title,MidName,LastName,Gender,MaritalStatus,DOB,isDeceased,CurrentAddress,CurrentEmail,CurrentContact)
        create nonclustered index idx_entCustomer_MergedTo on [db-au-cmdwh].dbo.entCustomer(MergedTo) include (BIRowID,CustomerID)
        create nonclustered index idx_name on [db-au-cmdwh].dbo.entCustomer(CustomerName) include (CustomerID)

        --create fulltext catalog FTC as default

        create fulltext index on [db-au-cmdwh].dbo.entCustomer(FTS) key index idx_entCustomer_BIRowID

    end

    
    if object_id('tempdb..#entCustomer') is not null
        drop table #entCustomer

    select --top 1000 
        try_convert(bigint, rtrim(p.ROWID_OBJECT)) CustomerID,
        p.CREATE_DATE CreateDate,
        p.LAST_UPDATE_DATE UpdateDate,
        p.DELETED_DATE DeleteDate,
        p.CONSOLIDATION_IND ConsolidationID,
        STATUS Status,
        PRTY_NM CustomerName,
        PRTY_TYP CustomerRole,
        isnull(id.TITLE, '') Title,
        id.FRST_NM FirstName,
        isnull(MID_NM, '') MidName,
        isnull(LST_NM, '') LastName,
        isnull(GNDR, '') Gender,
        isnull(MARITL_STS, '') MaritalStatus,
        convert(date, DOB) DOB,
        case
            when isnull(IS_DCSED, '') = '' then 0
            else 1
        end isDeceased,
        isnull(a.CurrentAddress, '') CurrentAddress,
        isnull(e.CurrentEmail, '') CurrentEmail,
        isnull(ph.CurrentContact, '') CurrentContact
    into #entCustomer
    from
        ent_C_PARTY_aucm p with(nolock)
        cross apply
        (
            select top 1 
                id.TITLE,
                id.FRST_NM,
                id.MID_NM,
                id.LST_NM,
                id.GNDR,
                id.MARITL_STS,
                id.DOB,
                id.IS_DCSED
            from
                ent_C_PRTY_IND_DTL_aucm id with(nolock)
            where
                id.PRTY_FK = p.ROWID_OBJECT
            order by
                id.CONSOLIDATION_IND,
                id.LAST_UPDATE_DATE desc
        ) id
        outer apply
        (
            select top 1 
                isnull(a.ADDR_LINE1, '') + 
                isnull(' ' + a.ADDR_LINE2, '') +
                isnull(' ' + a.CITY, '') +
                isnull(' ' + a.PRVNCE, '') +
                isnull(' ' + a.POST_CD, '') +
                isnull(', ' + a.CNTRY, '') CurrentAddress
            from
                ent_C_PARTY_ADDRESS_aucm a with(nolock)
            where
                a.PRTY_FK = p.ROWID_OBJECT and
                a.STATUS = 'Valid'
            order by
                a.LAST_UPDATE_DATE desc
        ) a
        outer apply
        (
            select top 1 
                isnull(lower(e.EMAIL_VAL), '') CurrentEmail
            from
                ent_C_PARTY_EMAIL_aucm e with(nolock)
            where
                e.PRTY_FK = p.ROWID_OBJECT and
                e.STATUS = 'Valid'
            order by
                e.LAST_UPDATE_DATE desc
        ) e
        outer apply
        (
            select top 1 
                isnull(lower(ph.FULL_PH_VAL), '') CurrentContact
            from
                ent_C_PARTY_PHONE_aucm ph with(nolock)
            where
                ph.PRTY_FK = p.ROWID_OBJECT and
                ph.STATUS = 'Valid'
            order by
                ph.LAST_UPDATE_DATE desc
        ) ph

--select
--    COLUMN_NAME + ' ' + DATA_TYPE + isnull('(' + convert(varchar, CHARACTER_MAXIMUM_LENGTH) + ')', '') + ',',
--    COLUMN_NAME + ',',
--    COLUMN_NAME + ' = s.' + COLUMN_NAME + ','
--from
--    tempdb.INFORMATION_SCHEMA.COLUMNS
--where
--    table_name like '#entCustomer%'

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.entCustomer t
        using #entCustomer s on
            s.CustomerID = t.CustomerID

        when matched then

            update
            set
                CreateDate = s.CreateDate,
                UpdateDate = s.UpdateDate,
                DeleteDate = s.DeleteDate,
                ConsolidationID = s.ConsolidationID,
                Status = s.Status,
                CustomerName = s.CustomerName,
                CustomerRole = s.CustomerRole,
                Title = s.Title,
                FirstName = s.FirstName,
                MidName = s.MidName,
                LastName = s.LastName,
                Gender = s.Gender,
                MaritalStatus = s.MaritalStatus,
                DOB = s.DOB,
                isDeceased = s.isDeceased,
                CurrentAddress = s.CurrentAddress,
                CurrentEmail = s.CurrentEmail,
                CurrentContact = s.CurrentContact,
                FTS =
                    convert(nvarchar(max), s.CustomerID) + ' ' +
                    s.FirstName + ' ' + 
                    s.LastName + ' ' + 
                    isnull(datename(mm, s.DOB) + ' ', '') + 
                    isnull(convert(varchar(10), s.DOB, 120), '') + ' ' + 
                    isnull(s.CurrentEmail, '') + ' ' + 
                    isnull(s.CurrentContact, '') + ' ' + 
                    isnull(s.CurrentAddress, ''),
                MergedTo = s.CustomerID,
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                CustomerID,
                CreateDate,
                UpdateDate,
                DeleteDate,
                ConsolidationID,
                Status,
                CustomerName,
                CustomerRole,
                Title,
                FirstName,
                MidName,
                LastName,
                Gender,
                MaritalStatus,
                DOB,
                isDeceased,
                CurrentAddress,
                CurrentEmail,
                CurrentContact,
                FTS,
                MergedTo,
                UpdateBatchID
            )
            values
            (
                s.CustomerID,
                s.CreateDate,
                s.UpdateDate,
                s.DeleteDate,
                s.ConsolidationID,
                s.Status,
                s.CustomerName,
                s.CustomerRole,
                s.Title,
                s.FirstName,
                s.MidName,
                s.LastName,
                s.Gender,
                s.MaritalStatus,
                s.DOB,
                s.isDeceased,
                s.CurrentAddress,
                s.CurrentEmail,
                s.CurrentContact,
                convert(nvarchar(max), s.CustomerID) + ' ' +
                    s.FirstName + ' ' + 
                    s.LastName + ' ' + 
                    isnull(datename(mm, s.DOB) + ' ', '') + 
                    isnull(convert(varchar(10), s.DOB, 120), '') + ' ' + 
                    isnull(s.CurrentEmail, '') + ' ' + 
                    isnull(s.CurrentContact, '') + ' ' + 
                    isnull(s.CurrentAddress, ''),
                s.CustomerID,
                @batchid
            )

        output $action into @mergeoutput
        ;

        select
            @insertcount =
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount =
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
        from
            @mergeoutput


        --sanction check
        if object_id('tempdb..#sanction') is not null
            drop table #sanction

        select 
            ec.CustomerID,
            ec.CustomerName,
            ec.DOB,
            ns.Reference,
            ns.NameScore,
            isnull(ds.DOBScore, 0) DOBScore,
            ns.NameScore * ds.DOBScore Score
        into #sanction
        from
            (
                select 
                    ec.CustomerID,
                    ec.CustomerName,
                    ec.DOB
                from
                    [db-au-cmdwh]..entCustomer ec
                where
                    CustomerID in
                    (
                        select
                            CustomerID
                        from
                            #entCustomer ec
                    ) and
                    SanctionReference is null
            ) ec
            cross apply
            (
                select
                    esn.Country,
                    esn.Reference,
                    sum
                    (
                        case
                            when esn.LastName = 1 and nf.LastName = 1 then 5
                            else 1
                        end 
                    ) NameScore
                from
                    (
                        select
                            NameFragment,
                            max(LastName) LastName
                        from
                            (
                                select
                                    isnull([db-au-workspace].dbo.fn_RemoveSpecialChars(r.Item), r.Item) NameFragment,
                                    case
                                        when r.ItemNumber = max(r.ItemNumber) over () then 1
                                        else 0
                                    end LastName
                                from
                                    [db-au-cmdwh].dbo.fn_DelimitedSplit8K(replace(ec.CustomerName, '-', ''), ' ')  r
                            ) nf
                        group by
                            NameFragment
                    ) nf
                    inner join [db-au-cmdwh]..entSanctionedNames esn on
                        esn.Country = 'AU' and
                        esn.NameFragment = nf.NameFragment
                group by
                    esn.Country,
                    esn.Reference

            ) ns
            outer apply
            (
                select top 1
                    case
                        when datediff(day, ec.DOB, esd.DOB) = 0 then 5
                        when abs(datediff(day, ec.DOB, esd.DOB)) = 1 then 3
                        when datepart(month, ec.DOB) = esd.MOB then 2
                        else 1
                    end DOBScore
                from
                    [db-au-cmdwh]..entSanctionedDOB esd 
                where
                    esd.Country = ns.Country and
                    esd.Reference = ns.Reference and
                    esd.YOBStart <= datepart(year, ec.DOB) and
                    esd.YOBEnd >= datepart(year, ec.DOB)
                order by DOBScore desc
            ) ds

        if object_id('tempdb..#sanctionresult') is not null
            drop table #sanctionresult

        select 
            CustomerID,
            CustomerName,
            DOB,
            Score,
            case
                when Score < 10 then 'Low risk, matched last name and year of birth'
                when Score < 15 then 'Low risk, matched last name, year and month of birth'
                when Score < 25 then 'Low risk, matched combination of names, within 1 day variance of date of birth'
                when Score < 30 then 'Medium risk, matched last name, same date of birth'
                else 'High risk, matched combination of names, same data of birth'
            end Risk,
            (
                select distinct
                    Reference + ','
                from
                    #sanction r
                where
                    r.CustomerID = t.CustomerID and
                    Score >= 5
                for xml path('')
            ) Refs
        into #sanctionresult
        from
            (
                select 
                    CustomerID,
                    CustomerName,
                    DOB,
                    max(Score) Score
                from
                    #sanction
                where
                    Score >= 5
                group by
                    CustomerID,
                    CustomerName,
                    DOB
            ) t
        
        update ec
        set
            SanctionScore = r.Score,
            SanctionReference = r.Refs
        from
            [db-au-cmdwh]..entCustomer ec
            inner join #sanctionresult r on
                r.CustomerID = ec.CustomerID

        --merged records
        update o
        set
            o.MergedTo = try_convert(bigint, rtrim(n.ROWID_OBJECT))
        from
            ent_vC_PARTY_XREF_aucm n
            inner join [db-au-cmdwh].dbo.entCustomer o on
                o.CustomerID = try_convert(bigint, rtrim(n.ORIG_ROWID_OBJECT))

		--moved to etlsp_ETL077_EnterpriseMDM_CleanMerged
        --update claim flags for merged records
        --update cf
        --set
        --    cf.CustomerID = try_convert(bigint, rtrim(n.ROWID_OBJECT))
        --from
        --    ent_vC_PARTY_XREF_aucm n
        --    inner join [db-au-cmdwh].dbo.clmClaimFlags cf on
        --        cf.CustomerID = try_convert(bigint, rtrim(n.ORIG_ROWID_OBJECT))


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
            @SourceInfo = 'entCustomer data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction


end






GO
