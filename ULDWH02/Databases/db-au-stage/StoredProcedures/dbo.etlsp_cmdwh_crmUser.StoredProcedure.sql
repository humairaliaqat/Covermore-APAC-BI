USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_crmUser]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[etlsp_cmdwh_crmUser]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:
Prerequisite:
Description:
Change History:
                20130129 - LS - case 18180, NZ: use the same TRIPS schema as AU

*************************************************************************************************************************************/

    set nocount on

    if object_id('[db-au-cmdwh].dbo.crmUser') is null
    begin
        create table [db-au-cmdwh].dbo.crmUser
        (
            CountryKey varchar(2) NOT NULL,
            CRMUserID numeric(18, 0) NOT NULL,
            Name varchar(50) NULL,
            Initial varchar(10) NULL,
            UserName varchar(50) NOT NULL,
            [Password] varchar(50) NULL,
            RepType varchar(15) NULL,
            AccessLevel int NULL,
            LastLogin datetime NULL,
            Active bit NULL,
            isAdmin bit NULL
        )
    end
    else truncate table [db-au-cmdwh].dbo.crmUser

    insert into [db-au-cmdwh].dbo.crmUser with (tablock)
    (
        CountryKey,
        CRMUserID,
        Name,
        Initial,
        UserName,
        [Password],
        RepType,
        AccessLevel,
        LastLogin,
        Active,
        isAdmin
    )
    select
        'AU' as CountryKey,
        CRMUserID,
        Name,
        Initial,
        UserName,
        [Password],
        RepType,
        AccessLevel,
        LastLogin,
        Active,
        null as isAdmin
    from
        [db-au-stage].dbo.trips_CRMUser_au

    union all

    select
        'NZ' as CountryKey,
        CRMUserID,
        Name,
        Initial,
        UserName,
        [Password],
        RepType,
        AccessLevel,
        LastLogin,
        Active,
        null isAdmin
    from
        [db-au-stage].dbo.trips_CRMUser_nz

    union all

    select
        'UK' as CountryKey,
        CRMUserID,
        Name,
        Initial,
        UserName,
        [Password],
        RepType,
        AccessLevel,
        LastLogin,
        null as Active,
        null as isAdmin
    from
        [db-au-stage].dbo.trips_CRMUser_uk

    union all

    select
        'MY' as CountryKey,
        CRMUserID,
        Name,
        Initial,
        UserName,
        [Password],
        RepType,
        AccessLevel,
        LastLogin,
        Active,
        null as isAdmin
    from
        [db-au-stage].dbo.trips_CRMUser_my

    union all

    select
        'SG' as CountryKey,
        CRMUserID,
        Name,
        Initial,
        UserName,
        [Password],
        RepType,
        AccessLevel,
        LastLogin,
        Active,
        null as isAdmin
    from
        [db-au-stage].dbo.trips_CRMUser_sg

end


GO
