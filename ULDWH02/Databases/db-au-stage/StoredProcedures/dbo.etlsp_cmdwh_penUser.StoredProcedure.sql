USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penUser]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_penUser]  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120125  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    User table contains consultant attribute details.  
                This transformation adds essential key fields and slow changing dimensions  
Change History:  
                20120125 - LT - Procedure created  
                20120522 - LS - Add Accreditation Information  
                20121018 - LT - Added ASICCheck column to penUser  
                20121108 - LS - refactoring & domain related changes  
                20130204 - LS - Case 18219, add consultant's email  
                20130325 - LS - TFS 8016, schema changes  
                20130408 - LS - Case 18432, First & Last Sell Dates  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20130906 - LS - (unexplained bug) fix, binary subquery doesn't work. no explanation yet, changing to left join  
                20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                                not gonna store password anymore  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data  
                20140709 - LT - Removed the last Update statement. This is a bug that updates old history with current data. The history  
                                should not be updated.  
                20141216 - LS - P11.5, login from 50 to 100 nvarchar  
                20150206 - LT - Added OutletAlphaKey column to penUser table  
                20150313 - LT - Added ConsultantType column to penUser table  
    20160317 - LT - Penguin 18.0, added ExternalIdentifier column to penUser table. Also note, as of this release, the Login  
        column will contain email address value for FC USA consultants.  
    20160531 - LT - Penguin 19.0, added isUserClickedLink column to penUser table  
    20180501 - SD - Added Velocity Number column to penUser table  
    20210306, SS, CHG0034615 Add filter for BK.com  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penUser') is not null  
        drop table etl_penUser  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, u.UserID) UserKey,  
        PrefixKey + convert(varchar, u.OutletID) OutletKey,  
        DomainID,  
        convert(varchar(20),null) as UserStatus,  
        convert(datetime,null) as UserStartDate,  
        convert(datetime,null) as UserEndDate,  
        convert(binary,null) as UserHashKey,  
        u.UserID,  
        u.OutletID,  
        u.FirstName,  
        u.LastName,  
        u.[Login],  
        null [Password],  
        u.Initial,  
        u.ASICNumber,  
        dbo.xfn_ConvertUTCtoLocal(u.AgreementDate, TimeZone) AgreementDate,  
        u.AccessLevel,  
        dbo.fn_GetReferenceValueByID(u.AccessLevel, CompanyKey, CountrySet) AccessLevelName,  
        u.AccreditationNumber,  
        u.AllowAdjustPricing,  
        case  
            when u.[Status] is null then 'Active'  
            else 'Inactive'  
        end as [Status],  
        dbo.xfn_ConvertUTCtoLocal(u.[Status], TimeZone) InactiveDate,  
        u.AgentCode,  
        acc.RefereeName,  
        acc.ReasonableChecksMade,  
        dbo.xfn_ConvertUTCtoLocal(acc.AccreditationDate, TimeZone) AccreditationDate,  
        dbo.xfn_ConvertUTCtoLocal(acc.DeclaredDate, TimeZone) DeclaredDate,  
        acc.PreviouslyKnownAs,  
        acc.YearsOfExperience,  
        dbo.xfn_ConvertUTCtoLocal(u.DateOfBirth, TimeZone) DateOfBirth,  
        dbo.fn_GetReferenceValueByID(u.ASICCheck, CompanyKey, CountrySet) ASICCheck,  
        u.Email,  
        dbo.xfn_ConvertUTCtoLocal(u.CreateDateTime, TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(u.UpdateDateTime, TimeZone) UpdateDateTime,  
        u.MustChangePassword,  
        u.AccountLocked,  
        u.LoginFailedTimes,  
        u.IsSuperUser,  
        u.LastUpdateUserId,  
        u.LastUpdateCrmUserId,  
        dbo.xfn_ConvertUTCtoLocal(u.LastLoggedInDateTime, TimeZone) LastLoggedIn,  
        u.LastLoggedInDateTime LastLoggedInUTC,  
        convert(nvarchar(50),'') as ConsultantType,  
  u.ExternalIdentifier,  
  u.isUserClickedLink,  
  u.VelocityNumber  
    into etl_penUser  
    from  
        penguin_tblUser_aucm u  
        cross apply dbo.fn_GetOutletDomainKeys(u.OutletId, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                RefereeName,  
                ReasonableChecksMade,  
                RefereedDate AccreditationDate,  
                DeclaredDate,  
                PreviouslyKnownAs,  
                YearsOfExperience  
            from  
                penguin_tblUserAccreditationApplication_aucm acc  
            where  
                acc.UserId = u.UserId  
            order by  
                CreateDateTime desc  
        ) acc  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, u.UserID) UserKey,  
        PrefixKey + convert(varchar, u.OutletID) OutletKey,  
        DomainID,  
        convert(varchar(20),null) as UserStatus,  
        convert(datetime,null) as UserStartDate,  
        convert(datetime,null) as UserEndDate,  
        convert(binary,null) as UserHashKey,  
        u.UserID,  
        u.OutletID,  
        u.FirstName,  
        u.LastName,  
        u.[Login],  
        null [Password],  
        u.Initial,  
        u.ASICNumber,  
        dbo.xfn_ConvertUTCtoLocal(u.AgreementDate, TimeZone) AgreementDate,  
        u.AccessLevel,  
        dbo.fn_GetReferenceValueByID(u.AccessLevel, CompanyKey, CountrySet) AccessLevelName,  
        u.AccreditationNumber,  
        u.AllowAdjustPricing,  
        case  
            when u.[Status] is null then 'Active'  
            else 'Inactive'  
        end as [Status],  
        dbo.xfn_ConvertUTCtoLocal(u.[Status], TimeZone) InactiveDate,  
        u.AgentCode,  
        acc.RefereeName,  
        acc.ReasonableChecksMade,  
        dbo.xfn_ConvertUTCtoLocal(acc.AccreditationDate, TimeZone) AccreditationDate,  
        dbo.xfn_ConvertUTCtoLocal(acc.DeclaredDate, TimeZone) DeclaredDate,  
        acc.PreviouslyKnownAs,  
        acc.YearsOfExperience,  
        dbo.xfn_ConvertUTCtoLocal(u.DateOfBirth, TimeZone) DateOfBirth,  
        dbo.fn_GetReferenceValueByID(u.ASICCheck, CompanyKey, CountrySet) ASICCheck,  
        u.Email,  
        dbo.xfn_ConvertUTCtoLocal(u.CreateDateTime, TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(u.UpdateDateTime, TimeZone) UpdateDateTime,  
        u.MustChangePassword,  
        u.AccountLocked,  
        u.LoginFailedTimes,  
        u.IsSuperUser,  
        u.LastUpdateUserId,  
        u.LastUpdateCrmUserId,  
        dbo.xfn_ConvertUTCtoLocal(u.LastLoggedInDateTime, TimeZone) LastLoggedIn,  
        u.LastLoggedInDateTime LastLoggedInUTC,  
        convert(nvarchar(50),'') as ConsultantType,  
  u.ExternalIdentifier,  
  u.isUserClickedLink,  
  u.VelocityNumber  
    from  
        penguin_tblUser_autp u  
        cross apply dbo.fn_GetOutletDomainKeys(u.OutletId, 'TIP', 'AU') dk  
        outer apply  
        (  
            select top 1  
                RefereeName,  
                ReasonableChecksMade,  
                RefereedDate AccreditationDate,  
                DeclaredDate,  
                PreviouslyKnownAs,  
                YearsOfExperience  
            from  
                penguin_tblUserAccreditationApplication_autp acc  
            where  
                acc.UserId = u.UserId  
            order by  
                CreateDateTime desc  
        ) acc  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, u.UserID) UserKey,  
        PrefixKey + convert(varchar, u.OutletID) OutletKey,  
        DomainID,  
        convert(varchar(20),null) as UserStatus,  
        convert(datetime,null) as UserStartDate,  
        convert(datetime,null) as UserEndDate,  
        convert(binary,null) as UserHashKey,  
        u.UserID,  
        u.OutletID,  
        u.FirstName,  
        u.LastName,  
        u.[Login],  
        null [Password],  
        u.Initial,  
        u.ASICNumber,  
        dbo.xfn_ConvertUTCtoLocal(u.AgreementDate, TimeZone) AgreementDate,  
        u.AccessLevel,  
        dbo.fn_GetReferenceValueByID(u.AccessLevel, CompanyKey, CountrySet) AccessLevelName,  
        u.AccreditationNumber,  
        u.AllowAdjustPricing,  
        case  
            when u.[Status] is null then 'Active'  
            else 'Inactive'  
        end as [Status],  
        dbo.xfn_ConvertUTCtoLocal(u.[Status], TimeZone) InactiveDate,  
        u.AgentCode,  
        acc.RefereeName,  
        acc.ReasonableChecksMade,  
        dbo.xfn_ConvertUTCtoLocal(acc.AccreditationDate, TimeZone) AccreditationDate,  
        dbo.xfn_ConvertUTCtoLocal(acc.DeclaredDate, TimeZone) DeclaredDate,  
        acc.PreviouslyKnownAs,  
        acc.YearsOfExperience,  
        dbo.xfn_ConvertUTCtoLocal(u.DateOfBirth, TimeZone) DateOfBirth,  
        dbo.fn_GetReferenceValueByID(u.ASICCheck, CompanyKey, CountrySet) ASICCheck,  
        u.Email,  
        dbo.xfn_ConvertUTCtoLocal(u.CreateDateTime, TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(u.UpdateDateTime, TimeZone) UpdateDateTime,  
        u.MustChangePassword,  
        u.AccountLocked,  
        u.LoginFailedTimes,  
        u.IsSuperUser,  
        u.LastUpdateUserId,  
        u.LastUpdateCrmUserId,  
        dbo.xfn_ConvertUTCtoLocal(u.LastLoggedInDateTime, TimeZone) LastLoggedIn,  
        u.LastLoggedInDateTime LastLoggedInUTC,  
        convert(nvarchar(50),'') as ConsultantType,  
  u.ExternalIdentifier,  
  u.isUserClickedLink,  
  u.VelocityNumber  
    from  
        penguin_tblUser_ukcm u  
        cross apply dbo.fn_GetOutletDomainKeys(u.OutletId, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                RefereeName,  
                ReasonableChecksMade,  
                RefereedDate AccreditationDate,  
                DeclaredDate,  
                PreviouslyKnownAs,  
                YearsOfExperience  
            from  
                penguin_tblUserAccreditationApplication_ukcm acc  
            where  
                acc.UserId = u.UserId  
            order by  
                CreateDateTime desc  
        ) acc  
    where convert(varchar, u.OutletID) not in (select OutletId from penguin_tblOutlet_ukcm where AlphaCode like 'BK%')      -----Adding BK.com filter

    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        PrefixKey + convert(varchar, u.UserID) UserKey,  
        PrefixKey + convert(varchar, u.OutletID) OutletKey,  
        DomainID,  
        convert(varchar(20),null) as UserStatus,  
        convert(datetime,null) as UserStartDate,  
        convert(datetime,null) as UserEndDate,  
        convert(binary,null) as UserHashKey,  
        u.UserID,  
        u.OutletID,  
        u.FirstName,  
        u.LastName,  
        u.[Login],  
        null [Password],  
        u.Initial,  
        u.ASICNumber,  
        dbo.xfn_ConvertUTCtoLocal(u.AgreementDate, TimeZone) AgreementDate,  
        u.AccessLevel,  
        dbo.fn_GetReferenceValueByID(u.AccessLevel, CompanyKey, CountrySet) AccessLevelName,  
        u.AccreditationNumber,  
        u.AllowAdjustPricing,  
        case  
            when u.[Status] is null then 'Active'  
            else 'Inactive'  
        end as [Status],  
        dbo.xfn_ConvertUTCtoLocal(u.[Status], TimeZone) InactiveDate,  
        u.AgentCode,  
        acc.RefereeName,  
        acc.ReasonableChecksMade,  
        dbo.xfn_ConvertUTCtoLocal(acc.AccreditationDate, TimeZone) AccreditationDate,  
        dbo.xfn_ConvertUTCtoLocal(acc.DeclaredDate, TimeZone) DeclaredDate,  
        acc.PreviouslyKnownAs,  
        acc.YearsOfExperience,  
        dbo.xfn_ConvertUTCtoLocal(u.DateOfBirth, TimeZone) DateOfBirth,  
        dbo.fn_GetReferenceValueByID(u.ASICCheck, CompanyKey, CountrySet) ASICCheck,  
        u.Email,  
        dbo.xfn_ConvertUTCtoLocal(u.CreateDateTime, TimeZone) CreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(u.UpdateDateTime, TimeZone) UpdateDateTime,  
        u.MustChangePassword,  
        u.AccountLocked,  
        u.LoginFailedTimes,  
        u.IsSuperUser,  
        u.LastUpdateUserId,  
        u.LastUpdateCrmUserId,  
        dbo.xfn_ConvertUTCtoLocal(u.LastLoggedInDateTime, TimeZone) LastLoggedIn,  
        u.LastLoggedInDateTime LastLoggedInUTC,  
        convert(nvarchar(50),'') as ConsultantType,  
  u.ExternalIdentifier,  
  u.isUserClickedLink,  
  u.VelocityNumber  
    from  
        penguin_tblUser_uscm u  
        cross apply dbo.fn_GetOutletDomainKeys(u.OutletId, 'CM', 'US') dk  
        outer apply  
        (  
            select top 1  
                RefereeName,  
                ReasonableChecksMade,  
                RefereedDate AccreditationDate,  
                DeclaredDate,  
                PreviouslyKnownAs,  
                YearsOfExperience  
            from  
                penguin_tblUserAccreditationApplication_uscm acc  
            where  
                acc.UserId = u.UserId  
            order by  
                CreateDateTime desc  
        ) acc  
  
    create clustered index idx_main on etl_penUser(Userkey)  
  
    --Update Users with UserHashKey values  
    update etl_penUser  
    set UserHashKey =  
        binary_checksum(  
            CountryKey,  
            DomainID,  
            UserID,  
            OutletID,  
            FirstName,  
            LastName,  
            [Login],  
            Initial,  
            ASICNumber,  
            AgreementDate,  
            AccessLevel,  
            AccreditationNumber,  
            AllowAdjustPricing,  
            [Status],  
            InactiveDate,  
            AgentCode,  
            UpdateDateTime,  
   ExternalIdentifier,  
   isUserClickedLink,  
   VelocityNumber  
        )  
  
    --Update consultant type  
    update c  
    set c.ConsultantType = case when ltrim(rtrim(c.FirstName)) + ' ' + ltrim(rtrim(c.LastName)) = cc.ConsultantName then 'Internal' else 'External' end  
    from  
        etl_penUser c  
        left join  
        (  
            select  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) as ConsultantName  
            from  
                etl_penUser  
            where  
                replace(ltrim(rtrim(Firstname)),'-','') + replace(ltrim(rtrim(Lastname)),'-','')  like 'CoverMore%' or  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) like 'admin%' or  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) like '%system%' or  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) like '%SysUser%' or  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) like 'Test%' or  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) like 'Webuser%' or  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) like '%training%' or  
    ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) like '%learning%' or  
                ltrim(rtrim(FirstName)) like '%UAT%' or  
                ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName)) in ('Web account only','Web Sales','web user','Websales Admin','website website','WEB USER (DO NOT DELETE)')  
            group by ltrim(rtrim(FirstName)) + ' ' + ltrim(rtrim(LastName))  
        ) cc on ltrim(rtrim(c.FirstName)) + ' ' + ltrim(rtrim(c.LastName)) = cc.ConsultantName  
  
  
    if object_id('[db-au-cmdwh].dbo.penUser') is null  
    begin  
  
        create table [db-au-cmdwh].dbo.[penUser]  
        (  
            [CountryKey] varchar(2) not null,  
            [CompanyKey] varchar(5) not null,  
            [UserKey] varchar(41) not null,  
            [OutletKey] varchar(41) not null,  
            [UserSKey] bigint not null identity(1,1),  
            [UserStatus] varchar(20) not null,  
            [UserStartDate] datetime not null,  
            [UserEndDate] datetime null,  
            [UserHashKey] binary(30) null,  
            [UserID] int not null,  
            [OutletID] int not null,  
            [FirstName] nvarchar(50) not null,  
            [LastName] nvarchar(50) not null,  
            [Login] nvarchar(200) not null,  
            [Password] varchar(255) null,  
            [Initial] nvarchar(50) null,  
            [ASICNumber] int null,  
            [AgreementDate] datetime null,  
            [AccessLevel] int not null,  
            [AccessLevelName] nvarchar(50) null,  
            [AccreditationNumber] varchar(50) null,  
            [AllowAdjustPricing] bit null,  
            [Status] varchar(20) null,  
            [InactiveDate] datetime null,  
            [AgentCode] nvarchar(50) null,  
            [RefereeName] nvarchar(255) null,  
            [ReasonableChecksMade] bit null,  
            [AccreditationDate] datetime null,  
            [DeclaredDate] datetime null,  
            [PreviouslyKnownAs] nvarchar(100) null,  
            [YearsOfExperience] varchar(15) null,  
            [DateOfBirth] datetime null,  
            [ASICCheck] nvarchar(50) null,  
            [DomainKey] varchar(41) null,  
            [DomainID] int null,  
            [Email] nvarchar(200) null,  
            [CreateDateTime] datetime null,  
            [UpdateDateTime] datetime null,  
            [MustChangePassword] bit null,  
            [AccountLocked] bit null,  
            [IsSuperUser] bit null,  
            [LoginFailedTimes] int null,  
            [LastUpdateUserID] int null,  
            [LastUpdateCRMUserID] int null,  
            [LastLoggedIn] datetime null,  
            [LastLoggedInUTC] datetime null,  
            [FirstSellDate] datetime null,  
            [LastSellDate] datetime null,  
            [OutletAlphaKey] nvarchar(50) null,  
            [ConsultantType] nvarchar(50) null,  
   [ExternalIdentifier] nvarchar(100) null,  
   [isUserClickedLink] bit null,  
   [VelocityNumber] nvarchar(50) null  
        )  
  
        create clustered index idx_penUser_UserKey on [db-au-cmdwh].dbo.penUser(UserKey,UserStatus)  
        create nonclustered index idx_penUser_CountryKey on [db-au-cmdwh].dbo.penUser(CountryKey)  
        create nonclustered index idx_penUser_Login on [db-au-cmdwh].dbo.penUser(Login,UserStatus) include (UserKey,OutletKey)  
        create nonclustered index idx_penUser_OutletID on [db-au-cmdwh].dbo.penUser(OutletID)  
        create nonclustered index idx_penUser_OutletKey on [db-au-cmdwh].dbo.penUser(OutletKey,Initial)  
        create nonclustered index idx_penUser_UserHashKey on [db-au-cmdwh].dbo.penUser(UserHashKey)  
        create nonclustered index idx_penUser_UserID on [db-au-cmdwh].dbo.penUser(UserID)  
        create nonclustered index idx_penUser_UserKeyStatus on [db-au-cmdwh].dbo.penUser(UserKey,UserStatus) include (FirstName,LastName,Login)  
        create nonclustered index idx_penUser_UserSKey on [db-au-cmdwh].dbo.penUser(UserSKey)  
        create nonclustered index idx_penUser_OutletAlphaKey on [db-au-cmdwh].dbo.penUser(OutletAlphaKey)  
  
    end  
  
  
     --get users that are new or had userhashkey changed since last ETL run  
    if object_id('tempdb..#etl_user') is not null  
        drop table #etl_user  
  
    --20130906, LS, change to left join ('not exists' also an option, it works)  
    select  
        u.*  
    into #etl_user  
    from  
        etl_penUser u  
        left join [db-au-cmdwh].dbo.penUser r on  
            r.UserStatus = 'Current' and  
            r.CountryKey = u.CountryKey and  
            r.UserHashKey = u.UserHashKey  
    where  
        r.UserKey is null  
  
    create clustered index idx_main on #etl_user(UserKey)  
    create index idx_secondary on #etl_user(UserHashKey)  
  
    --update user to Not Current, and set the UserEndDate to 2 days before ETL run date  
    update [db-au-cmdwh].dbo.penUser  
    set  
        UserStatus = 'Not Current',  
        UserEndDate = convert(datetime,convert(varchar(10),dateadd(d,-2,getdate()),120))  
    where  
        UserKey in  
        (  
            select UserKey  
            from  
                #etl_user  
        ) and  
        UserStatus = 'Current'  
  
  
    insert into [db-au-cmdwh].dbo.penUser with(tablockx)  
    (  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        UserKey,  
        OutletKey,  
        DomainID,  
        UserStatus,  
        UserStartDate,  
        UserEndDate,  
        UserHashKey,  
        UserID,  
        OutletID,  
        FirstName,  
        LastName,  
        [Login],  
        [Password],  
        Initial,  
        ASICNumber,  
        AgreementDate,  
        AccessLevel,  
        AccessLevelName,  
        AccreditationNumber,  
        AllowAdjustPricing,  
        [Status],  
        InactiveDate,  
        AgentCode,  
        RefereeName,  
        ReasonableChecksMade,  
        AccreditationDate,  
        DeclaredDate,  
        PreviouslyKnownAs,  
        YearsOfExperience,  
        DateOfBirth,  
        ASICCheck,  
        Email,  
        CreateDateTime,  
        UpdateDateTime,  
        MustChangePassword,  
        AccountLocked,  
        LoginFailedTimes,  
        IsSuperUser,  
        LastUpdateUserID,  
        LastUpdateCRMUserID,  
        LastLoggedIn,  
        LastLoggedInUTC,  
        OutletAlphaKey,  
        ConsultantType,  
  ExternalIdentifier,  
  isUserClickedLink,  
  VelocityNumber  
    )  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        UserKey,  
        OutletKey,  
        DomainID,  
        'Current' as UserStatus,  
        convert(datetime,convert(varchar(10),dateadd(d,-1,getdate()),120)) as UserStartDate,  
        null as UserEndDate,  
        UserHashKey,  
        UserID,  
        OutletID,  
        FirstName,  
        LastName,  
        [Login],  
        [Password],  
        Initial,  
        ASICNumber,  
        AgreementDate,  
        AccessLevel,  
        AccessLevelName,  
        AccreditationNumber,  
        AllowAdjustPricing,  
        [Status],  
        InactiveDate,  
        AgentCode,  
        RefereeName,  
        ReasonableChecksMade,  
        AccreditationDate,  
        DeclaredDate,  
        PreviouslyKnownAs,  
        YearsOfExperience,  
        DateOfBirth,  
        ASICCheck,  
        Email,  
        CreateDateTime,  
        UpdateDateTime,  
        MustChangePassword,  
        AccountLocked,  
        LoginFailedTimes,  
        IsSuperUser,  
        LastUpdateUserID,  
        LastUpdateCRMUserID,  
        LastLoggedIn,  
        LastLoggedInUTC,  
        o.OutletAlphaKey,  
        ConsultantType,  
  ExternalIdentifier,  
  isUserClickedLink,  
  VelocityNumber  
    from  
        etl_penUser  
        outer apply  
        (  
            select top 1 OutletAlphaKey  
            from [db-au-cmdwh].dbo.penOutlet  
            where  
                OutletKey = etl_penUser.OutletKey and  
                OutletStatus = 'Current'  
        ) o  
    where  
        UserKey in  
        (  
            select UserKey  
            from  
                #etl_User  
        )  
  
  
    if exists  
        (  
            select null  
            from  
                [db-au-cmdwh].INFORMATION_SCHEMA.TABLES  
            where  
                TABLE_NAME = 'penPolicyTransSummary'  
        )  
    begin  
  
        --update first sell date  
        update u  
        set  
            u.FirstSellDate = p.FirstSell  
        from  
            [db-au-cmdwh].dbo.penUser u  
            cross apply  
            (  
                select  
                    min(IssueDate) FirstSell  
                from  
                    [db-au-cmdwh].dbo.penPolicyTransSummary p  
                where  
                    p.UserKey = u.UserKey  
            ) p  
        where  
            u.FirstSellDate is null and  
            p.FirstSell is not null  
  
        --update last sell date  
        update u  
        set  
            u.LastSellDate = p.LastSell  
        from  
            [db-au-cmdwh].dbo.penUser u  
            cross apply  
            (  
                select  
                    max(IssueDate) LastSell  
                from  
                    [db-au-cmdwh].dbo.penPolicyTransSummary p  
                where  
                    p.UserKey = u.UserKey  
            ) p  
        where  
            p.LastSell is not null  
  
    end  
  
    drop table #etl_user  
  
    exec etlsp_cmdwh_penUserAudit  
  
end
GO
