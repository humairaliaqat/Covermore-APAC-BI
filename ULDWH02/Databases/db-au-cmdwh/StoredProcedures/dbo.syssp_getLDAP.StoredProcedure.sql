USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[syssp_getLDAP]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[syssp_getLDAP]
    @NamePrefix varchar(5)

as
begin
/****************************************************************************************************/
--  Name:           syssp_getLDAP
--  Author:         Leonardus Setyabudi
--  Date Created:   20140516
--  Description:    This stored procedure fetch LDAP accounts
--  Parameters:     @NamePrefix, work around for LDAP 1,000 rows limitation
--  
--  Change History:  
--                  20140516 - LS - Created
--
/****************************************************************************************************/

    set nocount on
    
    declare @sql varchar(max)

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
            --UserAccountControl,
            case
                when UserAccountControl & 2 = 2 then 0 --second bit enabled means disabled user
                else 1
            end isActive
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
                    userAccountControl
                from 
                    ''''LDAP://DC=aust,DC=covermore,DC=com,DC=au'''' 
                where 
                    objectCategory = ''''person'''' and 
                    objectClass = ''''user'''' and 
                    cn=''''' + @NamePrefix + '*''''
                ''
            )
        '

    exec(@sql)


--truncate table usrLDAP

--declare 
--    @index int,
--    @prefix varchar
--set @index = 97

--while @index <= 122
--begin

--    set @prefix = char(@index)
        
--    insert into usrLDAP
--    (
--        UserID,
--        UserName,
--        Manager,
--        EmailAddress,
--        FirstName,
--        LastName,
--        DisplayName,
--        CommonName,
--        Department,
--        Company,
--        JobTitle,
--        isActive
--    )
--    exec syssp_getLDAP 
--        @NamePrefix = @prefix

--    set @index = @index + 1
    
--end
    
end

GO
