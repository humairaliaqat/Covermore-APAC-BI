USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbUser]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cbUser]
as
begin
/*
20140715, LS,   TFS12109
                use transaction (as carebase has intra-day refreshes)
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('[db-au-cmdwh].dbo.cbUser') is null
    begin

        create table [db-au-cmdwh].dbo.cbUser
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [UserKey] nvarchar(35) not null,
            [UserID] nvarchar(30) not null,
            [FirstName] nvarchar(20) null,
            [Surname] nvarchar(30) null,
            [SecurityGroup] nvarchar(10) null,
            [IsDisplayed] bit null
        )

        create clustered index idx_cbUser_BIRowID on [db-au-cmdwh].dbo.cbUser(BIRowID)
        create nonclustered index idx_cbUser_UserID on [db-au-cmdwh].dbo.cbUser(UserID,CountryKey)
        create nonclustered index idx_cbUser_UserKey on [db-au-cmdwh].dbo.cbUser(UserKey)

    end

    begin transaction cbUser

    begin try

        delete
        from [db-au-cmdwh].dbo.cbUser
        where
            UserKey in
            (
                select
                    left('AU-' + UserID, 35) collate database_default
                from
                    carebase_ADM_USER_aucm
            )

        insert into [db-au-cmdwh].dbo.cbUser with(tablock)
        (
            CountryKey,
            UserKey,
            UserID,
            FirstName,
            Surname,
            SecurityGroup,
            IsDisplayed
        )
        select
            'AU' CountryKey,
            left('AU-' + UserID, 35) UserKey,
            UserID,
            PREF_NAME FirstName,
            Surname,
            SEC_GROUP SecurityGroup,
            Display IsDisplayed
        from
            carebase_ADM_USER_aucm

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbUser

        exec syssp_genericerrorhandler 'cbUser data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbUser


    if object_id('[db-au-cmdwh].dbo.cbUserTeam') is null
    begin

        create table [db-au-cmdwh].dbo.cbUserTeam
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [UserKey] nvarchar(35) not null,
            [UserID] nvarchar(30) not null,
            [TeamID] nvarchar(10) null,
            [UserName] nvarchar(50) null,
            [TeamName] nvarchar(50) null
        )

        create clustered index idx_cbUserTeam_BIRowID on [db-au-cmdwh].dbo.cbUserTeam(BIRowID)
        create nonclustered index idx_cbUserTeam_TeamName on [db-au-cmdwh].dbo.cbUserTeam(TeamName)
        create nonclustered index idx_cbUserTeam_UserKey on [db-au-cmdwh].dbo.cbUserTeam(UserKey)

    end

    begin transaction cbUserTeam

    begin try

        delete
        from [db-au-cmdwh].dbo.cbUserTeam
        where
            UserKey in
            (
                select
                    left('AU-' + UserID, 35) collate database_default
                from
                    carebase_ADM_USER_aucm
            )

        insert [db-au-cmdwh].dbo.cbUserTeam
        (
            CountryKey,
            UserKey,
            UserID,
            TeamID,
            UserName,
            TeamName
        )
        select
            'AU' CountryKey,
            left('AU-' + u.UserID, 35) UserKey,
            u.USERID,
            ut.TEAM_ID TeamID,
            u.PREF_NAME + ' ' + u.SURNAME UserName,
            t.TEAM_DESC TeamName
        from
            carebase_tblUserTeams_aucm ut
            inner join carebase_ADM_USER_aucm u on
                u.USERID = ut.USERID
            inner join carebase_TEAMS_aucm t on
                t.TEAM_ID = ut.TEAM_ID

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbUserTeam

        exec syssp_genericerrorhandler 'cbUserTeam data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbUserTeam

end

GO
