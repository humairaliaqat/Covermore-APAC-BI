USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_usrLDAP_test2]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec [etlsp_cmdwh_usrLDAP_test2]


CREATE procedure [dbo].[etlsp_cmdwh_usrLDAP_test2]
as
begin
/****************************************************************************************************/
--  Name:           etlsp_cmdwh_usrLDAP
--  Author:         LS
--  Date Created:   20140516
--  Description:    fetch LDAP accounts
--  Parameters:     
--  
--  Change History:  
--                  20140516 - LS - Created
--                  20141202 - LS - changed from [db-au-cmdwh]..syssp_getLDAP to proper etl
--                  20150128 - LS - pull more info
--                  20150324 - LS - add history
--					20220819 - HL - The letter 's*' appears to have greater than 901 users in LDAP. A custom logic was created specifically for the letter ‘s’
--									which is no longer working.
--									Separating out logic for 'srv*' from 's*' to resolve the issue. But this requires to be redesigned with a more permanent solution.
/****************************************************************************************************/

    set nocount on
    
    declare 
        @sql varchar(max),
        @sql_1 varchar(max),
		@sql_2 varchar(max),
        @index int,
        @prefix varchar(5),
		@filter varchar(200),
		@rowcount int

    if object_id('[db-au-cmdwh]..usrLDAPtest') is null
    begin

        create table [db-au-cmdwh]..usrLDAPtest
        (
            [BIRowID] bigint not null identity(1,1),
            [UserID] nvarchar(320) null,
            [UserName] nvarchar(320) null,
            [ManagerID] nvarchar(320) null,
            [Manager] nvarchar(320) null,
            [EmailAddress] nvarchar(320) null,
            [FirstName] nvarchar(320) null,
            [LastName] nvarchar(320) null,
            [DisplayName] nvarchar(445) null,
            [PreviousName] nvarchar(640) null,
            [CommonName] nvarchar(640) null,
            [Department] nvarchar(255) null,
            [Company] nvarchar(255) null,
            [JobTitle] nvarchar(255) null,
            [Phone] nvarchar(255) null,
            [Extension] nvarchar(255) null,
            [Mobile] nvarchar(255) null,
            [isActive] bit null,
            [isLocked] bit null,
            [isPasswordRequired] bit null,
            [isUnableToChangePassword] bit null,
            [isPasswordNeverExpired] bit null,
            [isPasswordExpired] bit null,
            [isTemporaryAccount] bit null,
            [isNormalAccount] bit null,
            [isInterDomainTrust] bit null,
            [isWorkstationTrust] bit null,
            [isServerTrust] bit null,
            [isTrustedForDelegation] bit null,
            [isTrustedToAuthDelegation] bit null,
            [AdminCount] int null,
            [CreateTimeStamp] datetime null,
            [ModifyTimeStamp] datetime null,
            [PasswordLastSet] datetime null,
            [AccountLockedOutTime] datetime null,
            [LastLogon] datetime null,
            [LogonCount] int null,
            [BadPasswordCount] int null,
            [LastBadPassword] datetime null,
            [CreateDateTime] datetime null,
            [UpdateDateTime] datetime null,
            [DeleteDateTime] datetime null
        )
        
        create clustered index idx_usrLDAP_BIRowID on [db-au-cmdwh]..usrLDAPtest (BIRowID)
        create nonclustered index idx_usrLDAP_UserID on [db-au-cmdwh]..usrLDAPtest (UserID)
        create nonclustered index idx_usrLDAP_UserName on [db-au-cmdwh]..usrLDAPtest (UserName) include(UserID,DisplayName,PreviousName,DeleteDateTime)
        create nonclustered index idx_usrLDAP_FirstName on [db-au-cmdwh]..usrLDAPtest (FirstName)
        create nonclustered index idx_usrLDAP_LastName on [db-au-cmdwh]..usrLDAPtest (LastName)
        create nonclustered index idx_usrLDAP_EmailAddress on [db-au-cmdwh]..usrLDAPtest (EmailAddress)
        create nonclustered index idx_usrLDAP_Department on [db-au-cmdwh]..usrLDAPtest (Department)
        create nonclustered index idx_usrLDAP_DisplayName on [db-au-cmdwh]..usrLDAPtest (DisplayName) include(UserID,UserName,Company,Department,JobTitle)

        insert into [db-au-cmdwh]..usrLDAPtest (UserID, UserName, Manager, FirstName, LastName,DisplayName, CommonName, Department, Company, JobTitle, isActive)
        values ('-1', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 0)

    end

    --if object_id('[db-au-cmdwh]..usrLDAPHistory') is null
    --begin

    --    create table [db-au-cmdwh]..usrLDAPHistory
    --    (
    --        [BIRowID] bigint not null identity(1,1),
    --        [UserID] nvarchar(320) null,
    --        [FirstName] nvarchar(320) null,
    --        [LastName] nvarchar(320) null,
    --        [DisplayName] nvarchar(445) null,
    --        [Department] nvarchar(255) null,
    --        [Company] nvarchar(255) null,
    --        [JobTitle] nvarchar(255) null,
    --        [CreateDateTime] datetime null
    --    )
        
    --    create clustered index idx_usrLDAPHistory_BIRowID on [db-au-cmdwh]..usrLDAPHistory (BIRowID)
    --    create nonclustered index idx_usrLDAPHistory_UserID on [db-au-cmdwh]..usrLDAPHistory (UserID,CreateDateTime desc) include(FirstName,LastName,Company,Department,JobTitle)
    --    create nonclustered index idx_usrLDAPHistory_DisplayName on [db-au-cmdwh]..usrLDAPHistory (DisplayName) include(UserID,Company,Department,JobTitle)

    --end

    if object_id('tempdb..#LDAPtest') is not null
        drop table #LDAPtest

    create table #LDAPtest
    (
        [UserID] nvarchar(320) null,
        [UserName] nvarchar(320) null,
        [ManagerID] nvarchar(320) null,
        [EmailAddress] nvarchar(320) null,
        [FirstName] nvarchar(320) null,
        [LastName] nvarchar(320) null,
        [DisplayName] nvarchar(640) null,
        [CommonName] nvarchar(640) null,
        [Department] nvarchar(255) null,
        [Company] nvarchar(255) null,
        [JobTitle] nvarchar(255) null,
        [Phone] nvarchar(255) null,
        [Extension] nvarchar(255) null,
        [Mobile] nvarchar(255) null,
        [isActive] bit null,
        [isLocked] bit null,
        [isPasswordRequired] bit null,
        [isUnableToChangePassword] bit null,
        [isPasswordNeverExpired] bit null,
        [isPasswordExpired] bit null,
        [isTemporaryAccount] bit null,
        [isNormalAccount] bit null,
        [isInterDomainTrust] bit null,
        [isWorkstationTrust] bit null,
        [isServerTrust] bit null,
        [isTrustedForDelegation] bit null,
        [isTrustedToAuthDelegation] bit null,
        [AdminCount] int null,
        [CreateTimeStamp] datetime null,
        [ModifyTimeStamp] datetime null,
        [PasswordLastSet] datetime null,
        [AccountLockedOutTime] datetime null,
        [LastLogon] datetime null,
        [LogonCount] int null,
        [BadPasswordCount] int null,
        [LastBadPassword] datetime null,
		usnCreated int
    )

    set @index = 97        
    while @index <= 122
    begin

        set @prefix = char(@index)
        if @prefix <> 's'
        begin    
        set @sql=
            '
            select 
                userPrincipalName UserID,
                sAMAccountName UserName,
                Manager,
                mail EmailAddress,
                givenname FirstName,
                sn LastName,
                DisplayName,
                cn CommonName,
                Department,
                Company,
                title JobTitle,
                telephoneNumber Phone,
                ipPhone Extension,
                Mobile,
                case
                    when UserAccountControl & 2 = 2 then 0
                    else 1
                end isActive,
                case
                    when UserAccountControl & 16 = 16 then 1
                    else 0
                end isLocked,
                case
                    when UserAccountControl & 32 = 32 then 0
                    else 1
                end isPasswordRequired,
                case
                    when UserAccountControl & 64 = 64 then 1
                    else 0
                end isUnableToChangePassword,
                case
                    when UserAccountControl & 65536 = 65536 then 1
                    else 0
                end isPasswordNeverExpired,
                case
                    when UserAccountControl & 8388608 = 8388608 then 1
                    else 0
                end isPasswordExpired,
                case
                    when UserAccountControl & 256 = 256 then 1
                    else 0
                end isTemporaryAccount,
                case
                    when UserAccountControl & 512 = 512 then 1
                    else 0
                end isNormalAccount,
                case
                    when UserAccountControl & 2048 = 2048 then 1
                    else 0
                end isInterDomainTrust,
                case
                    when UserAccountControl & 4096 = 4096 then 1
                    else 0
                end isWorkstationTrust,
                case
                    when UserAccountControl & 8192 = 8192 then 1
                    else 0
                end isServerTrust,
                case
                    when UserAccountControl & 524288 = 524288 then 1
                    else 0
                end isTrustedForDelegation,
                case
                    when UserAccountControl & 16777216 = 16777216 then 1
                    else 0
                end isTrustedToAuthDelegation,
                isnull(adminCount, 0) AdminCount,
                dbo.xfn_ConvertUTCtoLocal(CreateTimeStamp, ''AUS Eastern Standard Time'') CreateTimeStamp,
                dbo.xfn_ConvertUTCtoLocal(ModifyTimeStamp, ''AUS Eastern Standard Time'') ModifyTimeStamp,
                dbo.xfn_ConvertUTCtoLocal(
                    case
                        when isnull(pwdLastSet, ''0'') = ''0'' then null
                        else convert(datetime, (convert(bigint, pwdLastSet) / 864000000000) - 109207)
                    end,
                    ''AUS Eastern Standard Time''
                ) PasswordLastSet,
                dbo.xfn_ConvertUTCtoLocal(
                    case
                        when isnull(lockoutTime, ''0'') = ''0'' then null
                        else convert(datetime, (convert(bigint, lockoutTime) / 864000000000) - 109207)
                    end,
                    ''AUS Eastern Standard Time''
                ) AccountLockedOutTime,
                dbo.xfn_ConvertUTCtoLocal(
                    case
                        when isnull(lastLogon, ''0'') = ''0'' then null
                        else convert(datetime, (convert(bigint, lastLogon) / 864000000000) - 109207)
                    end,
                    ''AUS Eastern Standard Time''
                ) LastLogon,
                isnull(LogonCount, 0) LogonCount,
                isnull(badPwdCount, 0) BadPasswordCount,
                dbo.xfn_ConvertUTCtoLocal(
                    case
                        when isnull(badPasswordTime, ''0'') = ''0'' then null
                        else convert(datetime, (convert(bigint, badPasswordTime) / 864000000000) - 109207)
                    end,
                    ''AUS Eastern Standard Time''
                ) LastBadPassword,
				usnCreated
            from 
                openquery(
                    ADSI,
                    ''
                    select 
                        sAMAccountName,
                        title, 
                        cn,
                        company,
                        department,
                        displayname,
                        givenname,
                        sn,
                        mail,
                        manager,
                        userPrincipalName,
                        userAccountControl,
                        accountExpires,
                        adminCount,
                        badPasswordTime,
                        badPwdCount,
                        createTimeStamp,
                        ipPhone,
                        lastLogon,
                        lockoutTime,
                        logonCount,
                        mobile,
                        modifyTimeStamp,
                        pwdLastSet,
                        telephoneNumber,
						usnCreated
                    from 
                        ''''LDAP://DC=aust,DC=covermore,DC=com,DC=au'''' 
                    where 
                        objectCategory = ''''person'''' and 
                        objectClass = ''''user'''' and 
                        cn=''''' + @prefix + '*''''
                    ''
                )
            '
            end

    --        --else if @prefix = 's'
        insert into #LDAPtest
        exec(@sql)
        
        set @index = @index + 1
        
    end

    
    select @filter = ''
    
    	While ISNULL(@rowcount,901) = 901
		begin
		set @sql_1=
				'
				select top 901
					userPrincipalName UserID,
					sAMAccountName UserName,
					Manager,
					mail EmailAddress,
					givenname FirstName,
					sn LastName,
					DisplayName,
					cn CommonName,
					Department,
					Company,
					title JobTitle,
					telephoneNumber Phone,
					ipPhone Extension,
					Mobile,
					case
						when UserAccountControl & 2 = 2 then 0
						else 1
					end isActive,
					case
						when UserAccountControl & 16 = 16 then 1
						else 0
					end isLocked,
					case
						when UserAccountControl & 32 = 32 then 0
						else 1
					end isPasswordRequired,
					case
						when UserAccountControl & 64 = 64 then 1
						else 0
					end isUnableToChangePassword,
					case
						when UserAccountControl & 65536 = 65536 then 1
						else 0
					end isPasswordNeverExpired,
					case
						when UserAccountControl & 8388608 = 8388608 then 1
						else 0
					end isPasswordExpired,
					case
						when UserAccountControl & 256 = 256 then 1
						else 0
					end isTemporaryAccount,
					case
						when UserAccountControl & 512 = 512 then 1
						else 0
					end isNormalAccount,
					case
						when UserAccountControl & 2048 = 2048 then 1
						else 0
					end isInterDomainTrust,
					case
						when UserAccountControl & 4096 = 4096 then 1
						else 0
					end isWorkstationTrust,
					case
						when UserAccountControl & 8192 = 8192 then 1
						else 0
					end isServerTrust,
					case
						when UserAccountControl & 524288 = 524288 then 1
						else 0
					end isTrustedForDelegation,
					case
						when UserAccountControl & 16777216 = 16777216 then 1
						else 0
					end isTrustedToAuthDelegation,
					isnull(adminCount, 0) AdminCount,
					dbo.xfn_ConvertUTCtoLocal(CreateTimeStamp, ''AUS Eastern Standard Time'') CreateTimeStamp,
					dbo.xfn_ConvertUTCtoLocal(ModifyTimeStamp, ''AUS Eastern Standard Time'') ModifyTimeStamp,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(pwdLastSet, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, pwdLastSet) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) PasswordLastSet,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(lockoutTime, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, lockoutTime) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) AccountLockedOutTime,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(lastLogon, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, lastLogon) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) LastLogon,
					isnull(LogonCount, 0) LogonCount,
					isnull(badPwdCount, 0) BadPasswordCount,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(badPasswordTime, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, badPasswordTime) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) LastBadPassword,
					usnCreated
				from 
					openquery(
						ADSI,
						''
						select 
							sAMAccountName,
							title, 
							cn,
							company,
							department,
							displayname,
							givenname,
							sn,
							mail,
							manager,
							userPrincipalName,
							userAccountControl,
							accountExpires,
							adminCount,
							badPasswordTime,
							badPwdCount,
							createTimeStamp,
							ipPhone,
							lastLogon,
							lockoutTime,
							logonCount,
							mobile,
							modifyTimeStamp,
							pwdLastSet,
							telephoneNumber,
							usnCreated
						from 
							''''LDAP://DC=aust,DC=covermore,DC=com,DC=au'''' 
						where 
							objectCategory = ''''person'''' and 
							objectClass = ''''user'''' and 
							cn=''''s*''''  and cn<>''''srv*'''' 
							'+ @filter +'
						 order by usnCreated
						''
					)
				'

			print(@sql_1)
			insert into #LDAPtest
			exec(@sql_1)
			set @index = @index + 1
			select @rowcount = @@ROWCOUNT
			select @filter = 'and usnCreated > '+ LTRIM(STR((SELECT MAX(usnCreated) FROM #LDAPtest)))
	end

	 select @filter = ''
    
    	begin
		set @sql_2=
				'
				select 
					userPrincipalName UserID,
					sAMAccountName UserName,
					Manager,
					mail EmailAddress,
					givenname FirstName,
					sn LastName,
					DisplayName,
					cn CommonName,
					Department,
					Company,
					title JobTitle,
					telephoneNumber Phone,
					ipPhone Extension,
					Mobile,
					case
						when UserAccountControl & 2 = 2 then 0
						else 1
					end isActive,
					case
						when UserAccountControl & 16 = 16 then 1
						else 0
					end isLocked,
					case
						when UserAccountControl & 32 = 32 then 0
						else 1
					end isPasswordRequired,
					case
						when UserAccountControl & 64 = 64 then 1
						else 0
					end isUnableToChangePassword,
					case
						when UserAccountControl & 65536 = 65536 then 1
						else 0
					end isPasswordNeverExpired,
					case
						when UserAccountControl & 8388608 = 8388608 then 1
						else 0
					end isPasswordExpired,
					case
						when UserAccountControl & 256 = 256 then 1
						else 0
					end isTemporaryAccount,
					case
						when UserAccountControl & 512 = 512 then 1
						else 0
					end isNormalAccount,
					case
						when UserAccountControl & 2048 = 2048 then 1
						else 0
					end isInterDomainTrust,
					case
						when UserAccountControl & 4096 = 4096 then 1
						else 0
					end isWorkstationTrust,
					case
						when UserAccountControl & 8192 = 8192 then 1
						else 0
					end isServerTrust,
					case
						when UserAccountControl & 524288 = 524288 then 1
						else 0
					end isTrustedForDelegation,
					case
						when UserAccountControl & 16777216 = 16777216 then 1
						else 0
					end isTrustedToAuthDelegation,
					isnull(adminCount, 0) AdminCount,
					dbo.xfn_ConvertUTCtoLocal(CreateTimeStamp, ''AUS Eastern Standard Time'') CreateTimeStamp,
					dbo.xfn_ConvertUTCtoLocal(ModifyTimeStamp, ''AUS Eastern Standard Time'') ModifyTimeStamp,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(pwdLastSet, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, pwdLastSet) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) PasswordLastSet,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(lockoutTime, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, lockoutTime) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) AccountLockedOutTime,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(lastLogon, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, lastLogon) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) LastLogon,
					isnull(LogonCount, 0) LogonCount,
					isnull(badPwdCount, 0) BadPasswordCount,
					dbo.xfn_ConvertUTCtoLocal(
						case
							when isnull(badPasswordTime, ''0'') = ''0'' then null
							else convert(datetime, (convert(bigint, badPasswordTime) / 864000000000) - 109207)
						end,
						''AUS Eastern Standard Time''
					) LastBadPassword,
					usnCreated
				from 
					openquery(
						ADSI,
						''
						select 
							sAMAccountName,
							title, 
							cn,
							company,
							department,
							displayname,
							givenname,
							sn,
							mail,
							manager,
							userPrincipalName,
							userAccountControl,
							accountExpires,
							adminCount,
							badPasswordTime,
							badPwdCount,
							createTimeStamp,
							ipPhone,
							lastLogon,
							lockoutTime,
							logonCount,
							mobile,
							modifyTimeStamp,
							pwdLastSet,
							telephoneNumber,
							usnCreated
						from 
							''''LDAP://DC=aust,DC=covermore,DC=com,DC=au'''' 
						where 
							objectCategory = ''''person'''' and 
							objectClass = ''''user'''' and 
							cn=''''srv*'''' 
							'+ @filter +'
						 order by usnCreated
						''
					)
				'

			print(@sql_2)
			insert into #LDAPtest
			exec(@sql_2)

			select @rowcount = @@ROWCOUNT
			select @filter = 'and usnCreated > '+ LTRIM(STR((SELECT MAX(usnCreated) FROM #LDAPtest)))
	end

    if object_id('tempdb..#usrLDAPtest') is not null
        drop table #usrLDAPtest

    select distinct
        isnull(t.UserID, t.UserName + '@aust.covermore.com.au') UserID,
        t.UserName,
        mi.ManagerID,
        m.ManagerName Manager,
        t.EmailAddress,
        t.FirstName,
        t.LastName,
        t.DisplayName,
        t.CommonName,
        t.Department,
        t.Company,
        t.JobTitle,
        t.Phone,
        t.Extension,
        t.Mobile,
        t.isActive,
        t.isLocked,
        t.isPasswordRequired,
        t.isUnableToChangePassword,
        t.isPasswordNeverExpired,
        t.isPasswordExpired,
        t.isTemporaryAccount,
        t.isNormalAccount,
        t.isInterDomainTrust,
        t.isWorkstationTrust,
        t.isServerTrust,
        t.isTrustedForDelegation,
        t.isTrustedToAuthDelegation,
        t.AdminCount,
        t.CreateTimeStamp,
        t.ModifyTimeStamp,
        t.PasswordLastSet,
        t.AccountLockedOutTime,
        t.LastLogon,
        t.LogonCount,
        t.BadPasswordCount,
        t.LastBadPassword
    into #usrLDAPtest
    from
        #LDAPtest t
        outer apply 
        (
            select top 1
                replace(m.Item, 'CN=', '') ManagerName
            from
                dbo.fn_DelimitedSplit8K(ManagerID, ',') m 
            where
                m.ItemNumber = 1
        ) m
        outer apply 
        (
            select top 1 
                UserID ManagerID
            from
                #LDAPtest r
            where
                r.CommonName = m.ManagerName
        ) mi

    --insert into [db-au-cmdwh]..usrLDAPHistory
    --(
    --    UserID,
    --    FirstName,
    --    LastName,
    --    DisplayName,
    --    Department,
    --    Company,
    --    JobTitle,
    --    CreateDateTime
    --)        
    --select 
    --    t.UserID,
    --    t.FirstName,
    --    t.LastName,
    --    t.DisplayName,
    --    t.Department,
    --    t.Company,
    --    t.JobTitle,
    --    getdate()
    --from
    --    #usrLDAP t
    --    left join [db-au-cmdwh]..usrLDAP l on
    --        l.UserID = t.UserID and
    --        isnull(l.FirstName, '') = isnull(t.FirstName, '') and
    --        isnull(l.LastName, '') = isnull(t.LastName, '') and
    --        isnull(l.DisplayName, '') = isnull(t.DisplayName, '') and
    --        isnull(l.Department, '') = isnull(t.Department, '') and
    --        isnull(l.Company, '') = isnull(t.Company, '') and
    --        isnull(l.JobTitle, '') = isnull(t.JobTitle, '')
    --where
    --    l.UserID is null

    begin transaction
    
    begin try

        merge into [db-au-cmdwh].dbo.usrLDAPtest with(tablock) t
        using #usrLDAPtest s on
            s.UserID = t.UserID and
            s.UserName not like '$%'
            
        when matched then
            update
            set
                UserID = s.UserID,
                UserName = s.UserName,
                ManagerID = s.ManagerID,
                Manager = s.Manager,
                EmailAddress = s.EmailAddress,
                FirstName = s.FirstName,
                LastName = s.LastName,
                DisplayName = s.DisplayName,
                CommonName = s.CommonName,
                Department = s.Department,
                Company = s.Company,
                JobTitle = s.JobTitle,
                Phone = s.Phone,
                Extension = s.Extension,
                Mobile = s.Mobile,
                isActive = s.isActive,
                isLocked = s.isLocked,
                isPasswordRequired = s.isPasswordRequired,
                isUnableToChangePassword = s.isUnableToChangePassword,
                isPasswordNeverExpired = s.isPasswordNeverExpired,
                isPasswordExpired = s.isPasswordExpired,
                isTemporaryAccount = s.isTemporaryAccount,
                isNormalAccount = s.isNormalAccount,
                isInterDomainTrust = s.isInterDomainTrust,
                isWorkstationTrust = s.isWorkstationTrust,
                isServerTrust = s.isServerTrust,
                isTrustedForDelegation = s.isTrustedForDelegation,
                isTrustedToAuthDelegation = s.isTrustedToAuthDelegation,
                AdminCount = s.AdminCount,
                CreateTimeStamp = s.CreateTimeStamp,
                ModifyTimeStamp = s.ModifyTimeStamp,
                PasswordLastSet = s.PasswordLastSet,
                AccountLockedOutTime = s.AccountLockedOutTime,
                LastLogon = s.LastLogon,
                LogonCount = s.LogonCount,
                BadPasswordCount = s.BadPasswordCount,
                LastBadPassword = s.LastBadPassword,
                UpdateDateTime = getdate(),
                DeleteDateTime = null,
                PreviousName =
                    case
                        when s.DisplayName <> t.DisplayName then t.DisplayName
                        else t.PreviousName
                    end
   
        when not matched by target then
            insert
            (
                UserID,
                UserName,
                ManagerID,
                Manager,
                EmailAddress,
                FirstName,
                LastName,
                DisplayName,
                CommonName,
                Department,
                Company,
                JobTitle,
                Phone,
                Extension,
                Mobile,
                isActive,
                isLocked,
                isPasswordRequired,
                isUnableToChangePassword,
                isPasswordNeverExpired,
                isPasswordExpired,
                isTemporaryAccount,
                isNormalAccount,
                isInterDomainTrust,
                isWorkstationTrust,
                isServerTrust,
                isTrustedForDelegation,
                isTrustedToAuthDelegation,
                AdminCount,
                CreateTimeStamp,
                ModifyTimeStamp,
                PasswordLastSet,
                AccountLockedOutTime,
                LastLogon,
                LogonCount,
                BadPasswordCount,
                LastBadPassword,
                CreateDateTime
            )
            values
            (
                s.UserID,
                s.UserName,
                s.ManagerID,
                s.Manager,
                s.EmailAddress,
                s.FirstName,
                s.LastName,
                s.DisplayName,
                s.CommonName,
                s.Department,
                s.Company,
                s.JobTitle,
                s.Phone,
                s.Extension,
                s.Mobile,
                s.isActive,
                s.isLocked,
                s.isPasswordRequired,
                s.isUnableToChangePassword,
                s.isPasswordNeverExpired,
                s.isPasswordExpired,
                s.isTemporaryAccount,
                s.isNormalAccount,
                s.isInterDomainTrust,
                s.isWorkstationTrust,
                s.isServerTrust,
                s.isTrustedForDelegation,
                s.isTrustedToAuthDelegation,
                s.AdminCount,
                s.CreateTimeStamp,
                s.ModifyTimeStamp,
                s.PasswordLastSet,
                s.AccountLockedOutTime,
                s.LastLogon,
                s.LogonCount,
                s.BadPasswordCount,
                s.LastBadPassword,
                getdate()
            )

        when 
            not matched by source and
            DeleteDateTime is null
        then
            update
            set
                DeleteDateTime = getdate(),
                isActive = 0
                
        ;
   
    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        --exec syssp_genericerrorhandler
        --    @SourceInfo = 'usrLDAPtest data refresh failed',
        --    @LogToTable = 1,
        --    @ErrorCode = '-100',
        --    @BatchID = -1,
        --    @PackageID = 'usrLDAPtest'

    end catch

    if @@trancount > 0
        commit transaction
    
end



GO
