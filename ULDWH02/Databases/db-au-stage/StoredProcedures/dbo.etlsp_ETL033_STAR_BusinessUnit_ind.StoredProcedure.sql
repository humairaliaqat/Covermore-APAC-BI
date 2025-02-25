USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_BusinessUnit_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_STAR_BusinessUnit_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load business unit dimension
Change History:
                20160512 - LL - created
				20180423 - LT - created for SUN GL INDIA
    
*************************************************************************************************************************************/

    set nocount on

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
        @SubjectArea = 'SUN GL INDIA',
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

    if object_id('[db-au-star]..Dim_Business_Unit_ind') is null
    begin

        create table [db-au-star]..Dim_Business_Unit_ind
        (
            [Business_Unit_SK] int not null identity(1,1),
            [Business_Unit_Code] varchar(50) not null,
            [Business_Unit_Desc] varchar(200) null,
            [Parent_Business_Unit_SK] int null,
            [Country_Code] varchar(50) not null,
            [Country_Desc] varchar(200) null,
            [Region_Code] varchar(50) not null,
            [Region_Desc] varchar(200) null,
            [Type_of_Entity_Code] varchar(50) not null,
            [Type_of_Entity_Desc] varchar(200) null,
            [Type_of_Business_Code] varchar(50) not null,
            [Type_of_Business_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_Business_Unit_PK_ind on [db-au-star].dbo.Dim_Business_Unit_ind(Business_Unit_SK)
        create nonclustered index IX01_Dim_Business_Unit_ind on [db-au-star].dbo.Dim_Business_Unit_ind(Business_Unit_Code)

        set identity_insert [db-au-star]..Dim_Business_Unit_ind on

        insert into [db-au-star]..Dim_Business_Unit_ind
        (
            [Business_Unit_SK],
            [Business_Unit_Code],
            [Business_Unit_Desc],
            [Parent_Business_Unit_SK],
            [Country_Code],
            [Country_Desc],
            [Region_Code],
            [Region_Desc],
            [Type_of_Entity_Code],
            [Type_of_Entity_Desc],
            [Type_of_Business_Code],
            [Type_of_Business_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Business_Unit_SK],
            'UNKNOWN' [Business_Unit_Code],
            'UNKNOWN' [Business_Unit_Desc],
            null [Parent_Business_Unit_SK],
            'UNKNOWN' [Country_Code],
            'UNKNOWN' [Country_Desc],
            'UNKNOWN' [Region_Code],
            'UNKNOWN' [Region_Desc],
            'UNKNOWN' [Type_of_Entity_Code],
            'UNKNOWN' [Type_of_Entity_Desc],
            'UNKNOWN' [Type_of_Business_Code],
            'UNKNOWN' [Type_of_Business_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_Business_Unit_ind off

    end

    if object_id('tempdb..#Dim_Business_Unit_ind') is not null
        drop table #Dim_Business_Unit_ind

    select *
    into #Dim_Business_Unit_ind
    from
        [db-au-star]..Dim_Business_Unit_ind
    where
        1 = 0

    insert into #Dim_Business_Unit_ind
    (
        [Business_Unit_Code],
        [Business_Unit_Desc],
        [Parent_Business_Unit_SK],
        [Country_Code],
        [Country_Desc],
        [Region_Code],
        [Region_Desc],
        [Type_of_Entity_Code],
        [Type_of_Entity_Desc],
        [Type_of_Business_Code],
        [Type_of_Business_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.BusinessUnitCode,
        s.BusinessUnitDescription,
        case
            when s.ParentBusinessUnitCode is null then 0
            else isnull(p.Business_Unit_SK, -1)
        end,
        s.CountryCode,
        s.CountryDescription,
        s.RegionCode,
        s.RegionDescription,
        s.TypeOfEntityCode,
        s.TypeOfEntityDescription,
        s.TypeOfBusinessCode,
        s.TypeOfBusinessDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glBusinessUnits_ind s
        outer apply
        (
            select top 1 
                Business_Unit_SK
            from
                [db-au-star]..Dim_Business_Unit_ind p
            where
                p.Business_Unit_CODE = s.ParentBusinessUnitCode
        ) p

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Business_Unit_ind with(tablock) t
        using #Dim_Business_Unit_ind s on
            s.[Business_Unit_Code] = t.[Business_Unit_Code]

        when 
            matched and
            binary_checksum(t.[Business_Unit_Desc],t.[Country_Code],t.[Country_Desc],t.[Region_Code],t.[Region_Desc],t.[Type_of_Entity_Code],t.[Type_of_Entity_Desc],t.[Type_of_Business_Code],t.[Type_of_Business_Desc],t.[Parent_Business_Unit_SK]) <>
            binary_checksum(s.[Business_Unit_Desc],s.[Country_Code],s.[Country_Desc],s.[Region_Code],s.[Region_Desc],s.[Type_of_Entity_Code],s.[Type_of_Entity_Desc],s.[Type_of_Business_Code],s.[Type_of_Business_Desc],s.[Parent_Business_Unit_SK]) 
        then

            update
            set
                [Business_Unit_Desc] = s.[Business_Unit_Desc],
                [Country_Code] = s.[Country_Code],
                [Country_Desc] = s.[Country_Desc],
                [Region_Code] = s.[Region_Code],
                [Region_Desc] = s.[Region_Desc],
                [Type_of_Entity_Code] = s.[Type_of_Entity_Code],
                [Type_of_Entity_Desc] = s.[Type_of_Entity_Desc],
                [Type_of_Business_Code] = s.[Type_of_Business_Code],
                [Type_of_Business_Desc] = s.[Type_of_Business_Desc],
                [Parent_Business_Unit_SK] = s.[Parent_Business_Unit_SK],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Business_Unit_Code],
                [Business_Unit_Desc],
                [Parent_Business_Unit_SK],
                [Country_Code],
                [Country_Desc],
                [Region_Code],
                [Region_Desc],
                [Type_of_Entity_Code],
                [Type_of_Entity_Desc],
                [Type_of_Business_Code],
                [Type_of_Business_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Business_Unit_Code],
                s.[Business_Unit_Desc],
                s.[Parent_Business_Unit_SK],
                s.[Country_Code],
                s.[Country_Desc],
                s.[Region_Code],
                s.[Region_Desc],
                s.[Type_of_Entity_Code],
                s.[Type_of_Entity_Desc],
                s.[Type_of_Business_Code],
                s.[Type_of_Business_Desc],
                getdate(),
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
                        when MergeAction = 'delete' then 1
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
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Error'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
