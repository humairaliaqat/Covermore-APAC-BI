USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emcMedicalGroup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_emcMedicalGroup]
as
begin

    set nocount on

    exec etlsp_StagingIndex_EMC

    if object_id('[db-au-cmdwh].dbo.emcMedicalGroup') is null
    begin

        create table [db-au-cmdwh].dbo.emcMedicalGroup
        (
            CountryKey varchar(2) not null,
            ApplicationKey varchar(15) not null,
            ApplicationID int not null,
            GroupID int null,
            GroupStatus varchar(20) null,
            GroupScore decimal(18, 2) null
        )

        create clustered index idx_emcMedicalGroup_ApplicationKey on [db-au-cmdwh].dbo.emcMedicalGroup(ApplicationKey)
        create index idx_emcMedicalGroup_ApplicationID on [db-au-cmdwh].dbo.emcMedicalGroup(ApplicationID, CountryKey)
        create index idx_emcMedicalGroup_GroupID on [db-au-cmdwh].dbo.emcMedicalGroup(GroupID) include (ApplicationID,ApplicationKey,CountryKey,GroupStatus,GroupScore)

    end

    if object_id('etl_emcMedicalGroup') is not null
        drop table etl_emcMedicalGroup

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), mcg.ClientID) ApplicationKey,
        mcg.ClientID ApplicationID,
        mcg.Counter GroupID,
        case mcg.DeniedAccepted
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            when 'P' then 'Awaiting Assessment'
            when 'U' then 'Auto Accept'
        end GroupStatus,
        mcg.Score GroupScore
    into etl_emcMedicalGroup
    from
        emc_EMC_tblMedicalConditionsGroup_AU mcg
        outer apply dbo.fn_GetEMCDomainKeys(mcg.ClientID, 'AU') dk

    union

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(12), mcg.ClientID) ApplicationKey,
        mcg.ClientID ApplicationID,
        mcg.Counter GroupID,
        case mcg.DeniedAccepted
            when 'A' then 'Approved'
            when 'D' then 'Denied'
            when 'N' then 'Not Assessed'
            when 'P' then 'Awaiting Assessment'
            when 'U' then 'Auto Accept'
        end GroupStatus,
        mcg.Score GroupScore
    from
        emc_UKEMC_tblMedicalConditionsGroup_UK mcg
        outer apply dbo.fn_GetEMCDomainKeys(mcg.ClientID, 'UK') dk

    delete em
    from
        [db-au-cmdwh].dbo.emcMedicalGroup em
        inner join etl_emcMedicalGroup t on
            t.ApplicationKey = em.ApplicationKey and
            t.GroupID = em.GroupID


    insert into [db-au-cmdwh].dbo.emcMedicalGroup with (tablock)
    (
        CountryKey,
        ApplicationKey,
        ApplicationID,
        GroupID,
        GroupStatus,
        GroupScore
    )
    select
        CountryKey,
        ApplicationKey,
        ApplicationID,
        GroupID,
        GroupStatus,
        GroupScore
    from
        etl_emcMedicalGroup

end
GO
