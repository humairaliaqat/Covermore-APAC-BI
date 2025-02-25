USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoAgent]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL041_CiscoAgent]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131115
Prerequisite:   Requires CISCO Informix database.                
Description:    populates cisAgent table in [db-au-cmdwh]
Parameters:        
Change History:
                20140828 - LT - Procedure created
                20140910 - LS - refactoring
                                add batch
                                index
                20150227 - LS - prioritise the non deleted LDAP accounts
                
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
        @SubjectArea = 'CISCO ODS',
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
        
    --create table if not exists
    if object_id('[db-au-cmdwh].dbo.cisAgent') is null
    begin
    
        create table [db-au-cmdwh].dbo.cisAgent
        (
            BIRowID bigint not null identity(1,1),
            AgentKey nvarchar(50) not null,
            AgentID int not null,
            ProfileID int not null,
            AgentLogin nvarchar(50) not null,
            AgentFirstName nvarchar(50) not null,
            AgentLastName nvarchar(50) not null,
            AgentName nvarchar(50) not null,
            TeamName nvarchar(50) not null,
            JobTitle nvarchar(4000) not null,            
            Manager nvarchar(4000) not null,
            EmailAddress nvarchar(4000) not null,
            Department nvarchar(4000) not null,
            Company nvarchar(4000) not null,
            isActive bit not null,
            DateInactive datetime null,
            isAutoAvail bit not null,
            Extension nvarchar(50) not null,
            CreateBatchID int null,
            UpdateBatchID int null
        ) 
        
        create clustered index idx_cisAgent_BIRowID on [db-au-cmdwh].dbo.cisAgent (BIRowID)
        create nonclustered index idx_cisAgent_AgentLogin on [db-au-cmdwh].dbo.cisAgent(AgentLogin) include (AgentKey,AgentID,AgentName,TeamName)
        create nonclustered index idx_cisAgent_AgentKey on [db-au-cmdwh].dbo.cisAgent(AgentKey) include (AgentLogin,AgentID,AgentName,TeamName)
        create nonclustered index idx_cisAgent_Extension on [db-au-cmdwh].dbo.cisAgent(Extension,DateInactive) include (AgentLogin,AgentID,AgentName,TeamName)
        
        --populate agent with default unknown values
        insert [db-au-cmdwh].dbo.cisAgent
        (
            AgentKey,
            AgentID,
            ProfileID,
            AgentLogin,
            AgentFirstName,
            AgentLastName,
            AgentName,
            TeamName,
            JobTitle,            
            Manager,
            EmailAddress,
            Department,
            Company,
            isActive,
            isAutoAvail,
            Extension,
            CreateBatchID
        )
        values
        (
            'AU-CM1-0',
            0,
            1,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            1,
            0,
            '',
            @batchid
        )
        
    end 
    
    if object_id('tempdb..#cisAgent') is not null
        drop table #cisAgent
    
    select
        'AU-CM' + convert(nvarchar,isnull(a.ProfileID,0)) + '-' + convert(nvarchar,isnull(a.ResourceID,0)) as AgentKey,            --following penguing country + '-' + company + domain + '-' + id
        isnull(a.ResourceID,0) as AgentID,
        isnull(a.ProfileID,0) as ProfileID,
        isnull(a.ResourceLoginID,0) as AgentLogin,
        isnull(a.ResourceFirstName,'') as AgentFirstName,
        isnull(a.ResourceLastName,'') as AgentLastName,
        isnull(a.ResourceName,'') as AgentName,
        isnull(a.TeamName,'') as TeamName,
        isnull(ldap.Manager,'') as Manager,
        isnull(ldap.EmailAddress,'') as EmailAddress,
        isnull(ldap.Department,'') as Department,
        isnull(ldap.Company,'') as Company,
        isnull(ldap.JobTitle,'') as JobTitle,    
        isnull(a.Active,0) as isActive,
        convert(datetime, a.DateInactive) as DateInactive,
        isnull(a.AutoAvail,0) as isAutoAvail,
        isnull(a.Extension,'') as Extension
    into #cisAgent
    from 
        openquery(
            CISCO,
            '
                select 
                    tea.teamname,
                    res.resourceid,
                    res.profileid,
                    res.resourceloginid,
                    res.resourceskillmapid,
                    res.assignedteamid,
                    res.resourcename,
                    res.resourcefirstname,        
                    res.resourcelastname,    
                    res.resourcegroupid,
                    res.resourcetype,
                    res.active,
                    res.autoavail,
                    res.extension,
                    res.dateinactive
                from 
                    resource res
                    left outer join team tea on 
                        res.assignedteamid = tea.teamid
            ' 
        ) a
        outer apply
        (
            select top 1
                Manager,
                EmailAddress,
                Department,
                Company,
                JobTitle,
                isActive
            from
                [db-au-cmdwh].dbo.usrLDAP
            where
                UserName = a.ResourceLoginID
            order by 
                case
                    when DeleteDateTime is null then 0
                    else 1
                end                 
        ) ldap 
        
    select 
        @sourcecount = count(*)
    from
        #cisAgent   

    --insert data
    begin transaction

    begin try
        
        merge into [db-au-cmdwh].dbo.cisAgent with(tablock) t
        using #cisAgent s on 
            s.AgentKey = t.AgentKey
            
        when 
            matched and
            binary_checksum(
                t.AgentName,
                t.TeamName,
                t.isActive,
                t.DateInactive,
                t.isAutoAvail,
                t.Extension
            ) <>
            binary_checksum(
                s.AgentName,
                s.TeamName,
                s.isActive,
                s.DateInactive,
                s.isAutoAvail,
                s.Extension
            )
        then
        
            update
            set
                AgentLogin = s.AgentLogin,
                AgentName = s.AgentName,
                TeamName = s.TeamName,
                Manager = s.Manager,
                EmailAddress = s.EmailAddress,
                Department = s.Department,
                Company = s.Company,
                JobTitle = s.JobTitle,
                isActive = s.isActive,
                DateInactive = s.DateInactive,
                isAutoAvail = s.isAutoAvail,
                Extension = s.Extension,
                UpdateBatchID = @batchid
                
        when not matched by target then
            insert 
            (
                AgentKey,
                AgentID,
                ProfileID,
                AgentLogin,
                AgentFirstName,
                AgentLastName,
                AgentName,
                TeamName,
                Manager,
                EmailAddress,
                Department,
                Company,
                JobTitle,
                isActive,
                DateInactive,
                isAutoAvail,
                Extension,
                CreateBatchID
            )
            values
            (
                s.AgentKey,
                s.AgentID,
                s.ProfileID,
                s.AgentLogin,
                s.AgentFirstName,
                s.AgentLastName,
                s.AgentName,
                s.TeamName,
                s.Manager,
                s.EmailAddress,
                s.Department,
                s.Company,
                s.JobTitle,
                s.isActive,
                s.DateInactive,
                s.isAutoAvail,
                s.Extension,
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
            @SourceInfo = 'cisAgent data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
        
    end catch    

    if @@trancount > 0
        commit transaction

end
GO
