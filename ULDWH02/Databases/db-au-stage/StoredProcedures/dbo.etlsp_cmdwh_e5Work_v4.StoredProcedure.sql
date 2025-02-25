USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_e5Work_v4]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_e5Work_v4]
as
begin
/*
    20130411 - LS - Case 18422, Add custom properties for Phone Call work type
    20130719 - LT - Added e5Work_v4Type and e5Work_v4Group tables
    20130813 - LS - Add staging index
    20150227 - LS - prefer the non deleted LDAP accounts
    20150708 - LS - T16817, NZ e5 v3
    20151016 - LS - error on claim number as string 'c' 
    20160315 - LS - error on claim number, too long, error on int conversion
	20160726 - LT - error on claim number where claim number like '0.%'
	20190415 - LT - error on claim number conversion from wcp
	20190726 - LT - e5 v4 upgrade
*/


    set nocount on

    exec etlsp_StagingIndex_e5_v4

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

	begin try
	
		exec syssp_getrunningbatch
			@SubjectArea = 'e5 ODS v4',
			@BatchID = @batchid out,
			@StartDate = @start out,
			@EndDate = @end out
			
	end try
	
	begin catch
		
		set @batchid = -1
	
	end catch

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'


    if object_id('[db-au-cmdwh].dbo.e5Work_v4') is null
    begin

        create table [db-au-cmdwh].[dbo].e5Work_v4
        (
            [BIRowID] bigint not null identity(1,1),
            [Domain] varchar(5) null,
            [Country] varchar(5) null,
            [Work_ID] varchar(50),
            [Original_Work_ID] uniqueidentifier not null,
            [Parent_ID] varchar(50),
            [Original_Parent_ID] uniqueidentifier null,
            [OriginWork_ID] uniqueidentifier null,
            [Reference] int null,
            [ClaimKey] varchar(40) null,
            [AgencyCode] nvarchar(20) null,
            [ClaimNumber] int null,
            [PolicyNumber] varchar(50) null,
            [OnlineClaim] bit null,
            [ClaimType] nvarchar(255) null,
            [ClaimDescription] nvarchar(255) null,
            [SectionCheckList] nvarchar(512) null,
            [ClaimantTitle] nvarchar(50) null,
            [ClaimantFirstName] nvarchar(100) null,
            [ClaimantSurname] nvarchar(100) null,
            [WorkClassName] nvarchar(100) null,
            [BusinessName] nvarchar(100) null,
            [WorkType] nvarchar(100) null,
            [GroupType] nvarchar(100) null,
            [StatusName] nvarchar(100) null,
            [AssignedDate] datetime null,
            [AssignedUserID] nvarchar(100) null,
            [AssignedUser] nvarchar(445) null,
            [CreationDate] datetime not null,
            [CreationUserID] nvarchar(100) null,
            [CreationUser] nvarchar(445) null,
            [CompletionDate] datetime null,
            [CompletionUserID] nvarchar(100) null,
            [CompletionUser] nvarchar(445) null,
            [DiarisedToDate] datetime null,
            [DueDate] datetime null,
            [SLAStartDate] datetime null,
            [SLAExpiryDate] datetime null,
            [SiteGroup] int null,
            [CreateBatchID] int,
            [UpdateBatchID] int,
            [DeleteBatchID] int
        )

        create clustered index idx_e5Work_v4_BIRowID on [db-au-cmdwh].dbo.e5Work_v4(BIRowID)
        create nonclustered index idx_e5Work_v4_ID on [db-au-cmdwh].dbo.e5Work_v4(Work_ID) include(Reference,ClaimKey,ClaimNumber,Country,Original_Work_ID)
        create nonclustered index idx_e5Work_v4_Assigned on [db-au-cmdwh].dbo.e5Work_v4(AssignedUser,StatusName) include (Work_ID,CompletionDate,SLAExpiryDate,ClaimNumber,ClaimKey,Country)
        create nonclustered index idx_e5Work_v4_Claim on [db-au-cmdwh].dbo.e5Work_v4(ClaimKey,WorkType) include (Work_ID,CreationDate,Reference,AssignedUser,Country)
        create nonclustered index idx_e5Work_v4_ClaimNumber on [db-au-cmdwh].dbo.e5Work_v4(ClaimNumber) include(Work_ID,Country,WorkType)
        create nonclustered index idx_e5Work_v4_CreationDate on [db-au-cmdwh].dbo.e5Work_v4(CreationDate) include (Work_ID,WorkType,Country,ClaimKey,ClaimNumber)
        create nonclustered index idx_e5Work_v4_Reference on [db-au-cmdwh].dbo.e5Work_v4(Reference) include(Work_ID,Country,WorkType,ClaimKey,ClaimNumber)
        create nonclustered index idx_e5Work_v4_WorkType on [db-au-cmdwh].dbo.e5Work_v4(WorkType,StatusName) include (Original_Work_ID,Domain,Work_ID,AssignedUser,CompletionDate,SLAExpiryDate,ClaimNumber,ClaimKey,GroupType,CreationDate,SLAStartDate,Reference,AssignedDate)
        create nonclustered index idx_e5Work_v4_Parent on [db-au-cmdwh].dbo.e5Work_v4(Parent_ID,Domain) include (Work_ID)
        create nonclustered index idx_e5Work_v4_OriginalID on [db-au-cmdwh].dbo.e5Work_v4(Original_Work_ID) include (Work_ID,SLAStartDate,SLAExpiryDate)


    end

    if object_id('tempdb..#e5Work_v4') is not null
        drop table #e5Work_v4

    select
        Domain,
        Country,
        Country + Domain + convert(varchar(40), w.ID) Work_ID,
        w.ID Original_Work_ID,
        Country + Domain + convert(varchar(40), w.Parent_Id) Parent_Id,
        w.Parent_Id Original_Parent_ID,
        w.Origin_ID OriginWork_ID,
        w.Reference,
        isnull(cl.ClaimKey, Country + '-' + convert(varchar(37), wcp.ClaimNumber) collate database_default) ClaimKey,
        convert(varchar(20), wcp.AgencyCode) collate database_default AgencyCode,
        case
            when len(ltrim(rtrim(convert(varchar(max), wcp.ClaimNumber)))) > 8 then null
			when convert(varchar(max),wcp.ClaimNumber) like  '0.%' then null
            when isnumeric(convert(varchar(max), wcp.ClaimNumber)) = 1 then convert(int, replace(convert(varchar,wcp.ClaimNumber),'.',''))
            else null
        end ClaimNumber,
        convert(varchar(50), wcp.PolicyNumber) collate database_default PolicyNumber,
        isnull(convert(bit, wcp.OnlineClaim), 0) OnlineClaim,
        convert(nvarchar(255), wcp.ClaimType) collate database_default ClaimType,
        convert(nvarchar(255), wcp.ClaimDescription) collate database_default ClaimDescription,
        convert(nvarchar(512), wcp.SectionChecklist) collate database_default SectionChecklist,
        convert(nvarchar(50), wcp.ClaimantTitle) collate database_default ClaimantTitle,
        convert(nvarchar(100), wcp.ClaimantFirstName) collate database_default ClaimantFirstName,
        convert(nvarchar(100), wcp.ClaimantSurname) collate database_default ClaimantSurname,
        (
            select top 1
                [Name] collate database_default
            from
                e5_WorkClass_v4
            where
                Id = w.WorkClass_ID
        ) WorkClassName,
        bn.[Name] BusinessName,
        (
            select top 1
                [Name] collate database_default
            from
                e5_Category2_v4
            where
                Id = w.Category2_Id
        ) WorkType,
        (
            select top 1
                [Name] collate database_default
            from
                e5_Category3_v4
            where
                Id = w.Category3_Id
        ) GroupType,
        (
            select top 1
                [Name] collate database_default
            from
                e5_Status_v4
            where
                Id = w.Status_ID
        ) StatusName,
        w.AssignedDate,
        w.AssignedUser collate database_default AssignedUserID,
        (
            select top 1
                l.DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(w.AssignedUser, 'covermore\', '') collate database_default 
            order by
                case
                    when DeleteDateTime is null then 0
                    else 1
                end
        ) AssignedUser,
        w.CreationDate,
        w.CreationUser collate database_default CreationUserID,
        (
            select top 1
                l.DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(w.CreationUser, 'covermore\', '') collate database_default 
            order by
                case
                    when DeleteDateTime is null then 0
                    else 1
                end
        ) CreationUser,
        w.CompletionDate,
        w.CompletionUser collate database_default CompletionUserID,
        (
            select top 1
                l.DisplayName
            from
                [db-au-cmdwh]..usrLDAP l
            where
                l.UserName = replace(w.CompletionUser, 'covermore\', '') collate database_default 
            order by
                case
                    when DeleteDateTime is null then 0
                    else 1
                end
        ) CompletionUser,
        isnull(convert(datetime, wcp.DiarisedToDate), w.StatusEventDate) DiarisedToDate,
        isnull(convert(datetime, wcp.DueDate), w.SLAExpiryDate) DueDate,
        convert(datetime, wcp.SLAStartDate) SLAStartDate,
        w.SLAExpiryDate,
        null SiteGroup
    into #e5Work_v4
    from
        e5_Work_v4 w
        cross apply
        (
            select top 1
                [Code] collate database_default [Code],
                [Name] collate database_default [Name]
            from
                e5_Category1_v4
            where
                Id = w.Category1_Id
        ) bn
        cross apply
        (
            select
                'V3' Domain,
                bn.Code Country
        ) dm
        outer apply
        (
            select
                max(
                    case
                        when Property_Id = 'AgentAlpha' then PropertyValue
                        else null
                    end
                ) AgencyCode,
                max(
                    case
                        when Property_Id = 'PolicyNumber' then PropertyValue
                        else null
                    end
                ) PolicyNumber,
                max(
                    case
                        when Property_Id = 'StatusEventDate' then PropertyValue
                        else null
                    end
                ) DiarisedToDate,
                max(
                    case
                        when Property_Id = 'SLAStartDate' then PropertyValue
                        else null
                    end
                ) SLAStartDate,
                max(
                    case
                        when Property_Id = 'SLAExpiryDate' then PropertyValue
                        else null
                    end
                ) DueDate,
                max(
                    case
                        when Property_Id in ('OnlineClaim', 'LaunchedByOnlineClaims') then PropertyValue
                        else null
                    end
                ) OnlineClaim,
                max(
                    case
                        when Property_Id = 'ClaimNumber' then PropertyValue
                        else null
                    end
                ) ClaimNumber,
                max(
                    case
                        when Property_Id = 'EventType' then PropertyValue
                        else null
                    end
                ) ClaimType,
                max(
                    case
                        when Property_Id = 'ClaimDescription' then PropertyValue
                        else null
                    end
                ) ClaimDescription,
                max(
                    case
                        when Property_Id = 'SectionChecklist' then PropertyValue
                        else null
                    end
                ) SectionChecklist,
                max(
                    case
                        when Property_Id = 'TitleClaimant1' then PropertyValue
                        else null
                    end
                ) ClaimantTitle,
                max(
                    case
                        when Property_Id = 'FirstNameClaimant1' then PropertyValue
                        else null
                    end
                ) ClaimantFirstName,
                max(
                    case
                        when Property_Id = 'SurnameClaimant1' then PropertyValue
                        else null
                    end
                ) ClaimantSurname
            from
                e5_WorkProperty_v4 wp
            where
                wp.Work_Id = w.Id and
                Property_Id in
                (
                    'AgentAlpha',
                    'PolicyNumber',
                    'StatusEventDate',
                    'SLAStartDate',
                    'SLAExpiryDate',
                    'LaunchedByOnlineClaims',
                    'OnlineClaim',
                    'ClaimNumber',
                    'EventType',
                    'ClaimDescription',
                    'SectionChecklist',
                    'TitleClaimant1',
                    'FirstNameClaimant1',
                    'SurnameClaimant1'
                )
        ) wcp
        outer apply
        (
            select top 1
                ClaimKey
            from
                [db-au-cmdwh]..clmClaim cl
            where
                cl.ClaimNo = 
                    case
                        when len(ltrim(rtrim(convert(varchar(max), wcp.ClaimNumber)))) > 8 then null
						when convert(varchar(max),wcp.ClaimNumber) like  '0.%' then null
                        when isnumeric(convert(varchar(max), wcp.ClaimNumber)) = 1 then convert(int, replace(convert(varchar,wcp.ClaimNumber),'.',''))
                        else null
                    end and
                cl.CountryKey = dm.Country collate database_default
        ) cl


    set @sourcecount = @@rowcount


    begin transaction

    begin try

        merge into [db-au-cmdwh].[dbo].[e5Work_v4] with(tablock) t
        using #e5Work_v4 s on
            s.Work_ID = t.Work_ID

        when matched then

            update
            set
                Domain = s.Domain,
                Country = s.Country,
                Original_Work_ID = s.Original_Work_ID,
                Parent_ID = s.Parent_ID,
                Original_Parent_ID = s.Original_Parent_ID,
                OriginWork_ID = s.OriginWork_ID,
                Reference = s.Reference,
                ClaimKey = s.ClaimKey,
                AgencyCode = s.AgencyCode,
                ClaimNumber = s.ClaimNumber,
                PolicyNumber = s.PolicyNumber,
                OnlineClaim = s.OnlineClaim,
                ClaimType = s.ClaimType,
                ClaimDescription = s.ClaimDescription,
                SectionCheckList = s.SectionCheckList,
                ClaimantTitle = s.ClaimantTitle,
                ClaimantFirstName = s.ClaimantFirstName,
                ClaimantSurname = s.ClaimantSurname,
                WorkClassName = s.WorkClassName,
                BusinessName = s.BusinessName,
                WorkType = s.WorkType,
                GroupType = s.GroupType,
                StatusName = s.StatusName,
                AssignedDate = s.AssignedDate,
                AssignedUserID = s.AssignedUserID,
                AssignedUser = s.AssignedUser,
                CreationDate = s.CreationDate,
                CreationUserID = s.CreationUserID,
                CreationUser = s.CreationUser,
                CompletionDate = s.CompletionDate,
                CompletionUserID = s.CompletionUserID,
                CompletionUser = s.CompletionUser,
                DiarisedToDate = s.DiarisedToDate,
                DueDate = s.DueDate,
                SLAExpiryDate = s.SLAExpiryDate,
                SiteGroup = s.SiteGroup,
                UpdateBatchID = @batchid,
                DeleteBatchID = null

        when not matched by target then
            insert
            (
                Domain,
                Country,
                Work_ID,
                Original_Work_ID,
                Parent_ID,
                Original_Parent_ID,
                OriginWork_ID,
                Reference,
                ClaimKey,
                AgencyCode,
                ClaimNumber,
                PolicyNumber,
                OnlineClaim,
                ClaimType,
                ClaimDescription,
                SectionCheckList,
                ClaimantTitle,
                ClaimantFirstName,
                ClaimantSurname,
                WorkClassName,
                BusinessName,
                WorkType,
                GroupType,
                StatusName,
                AssignedDate,
                AssignedUserID,
                AssignedUser,
                CreationDate,
                CreationUserID,
                CreationUser,
                CompletionDate,
                CompletionUserID,
                CompletionUser,
                DiarisedToDate,
                DueDate,
                SLAExpiryDate,
                SiteGroup,
                CreateBatchID
            )
            values
            (
                s.Domain,
                s.Country,
                s.Work_ID,
                s.Original_Work_ID,
                s.Parent_ID,
                s.Original_Parent_ID,
                s.OriginWork_ID,
                s.Reference,
                s.ClaimKey,
                s.AgencyCode,
                s.ClaimNumber,
                s.PolicyNumber,
                s.OnlineClaim,
                s.ClaimType,
                s.ClaimDescription,
                s.SectionCheckList,
                s.ClaimantTitle,
                s.ClaimantFirstName,
                s.ClaimantSurname,
                s.WorkClassName,
                s.BusinessName,
                s.WorkType,
                s.GroupType,
                s.StatusName,
                s.AssignedDate,
                s.AssignedUserID,
                s.AssignedUser,
                s.CreationDate,
                s.CreationUserID,
                s.CreationUser,
                s.CompletionDate,
                s.CompletionUserID,
                s.CompletionUser,
                s.DiarisedToDate,
                s.DueDate,
                s.SLAExpiryDate,
                s.SiteGroup,
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
            @SourceInfo = 'e5Work_v4 data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
