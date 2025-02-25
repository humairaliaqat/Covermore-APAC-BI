USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0420]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0420]
    @Country varchar(20),
    @Company varchar(5) = '',
    @AgencyCode varchar(20) = '',
    @ReportingPeriod varchar(30),
    @StartDate datetime = '2013-01-01',
    @EndDate datetime = '2013-01-01'

as
begin

/****************************************************************************************************/
--  Name:           rptsp_rpt0420
--  Author:         Leonardus Setyabudi
--  Date Created:   20130403
--  Description:    This stored procedure returns consultant's audit trail
--
--  Change History:
--                  20130403 - LS - Created
--
/****************************************************************************************************/

--uncoment to debug
--declare
--    @Country varchar(2),
--    @Company varchar(5),
--    @AgencyCode varchar(20),
--    @ReportingPeriod varchar(39),
--    @StartDate datetime,
--    @EndDate datetime
--select
--    @Country = 'AU',
--    @Company = 'TIP',
--    @AgencyCode = '',
--    @ReportingPeriod = 'Last Month',
--    @StartDate = '',
--    @EndDate = ''

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @ReportingPeriod

    if object_id('tempdb..#useraudit') is not null
        drop table #useraudit

    select
        ua.UserKey,
        ua.AuditDateTime,
        o.AlphaCode,
        ua.Login,
        ua.Status,
        ua.FirstName,
        ua.LastName,
        ua.Initial,
        ua.ASICNumber,
        ua.ASICCheck,
        ua.AgreementDate,
        ua.AccessLevelName,
        ua.AccreditationNumber,
        ua.AllowAdjustPricing,
        ua.AccountLocked,
        ua.LoginFailedTimes,
        ua.IsSuperUser,
        binary_checksum(
            o.AlphaCode,
            ua.Status,
            ua.FirstName,
            ua.LastName,
            ua.Initial,
            ua.ASICNumber,
            ua.ASICCheck,
            ua.AgreementDate,
            ua.AccessLevelName,
            ua.AccreditationNumber,
            ua.AllowAdjustPricing,
            ua.AccountLocked,
            ua.LoginFailedTimes,
            ua.IsSuperUser
        ) HashedKey
    into #useraudit
    from
        penUserAudit ua
        inner join penOutlet o on
            o.OutletKey = ua.OutletKey and
            o.OutletStatus = 'Current'
    where
        AuditDateTime >= @rptStartDate and
        AuditDateTime <  dateadd(day, 1, @rptEndDate) and
        (
            @AgencyCode = '' or
            o.AlphaCode = @AgencyCode
        )

    insert into #useraudit
    select
        u.UserKey,
        isnull(u.UpdateDateTime, getdate()),
        o.AlphaCode,
        u.Login,
        u.Status,
        u.FirstName,
        u.LastName,
        u.Initial,
        u.ASICNumber,
        u.ASICCheck,
        u.AgreementDate,
        u.AccessLevelName,
        u.AccreditationNumber,
        u.AllowAdjustPricing,
        u.AccountLocked,
        u.LoginFailedTimes,
        u.IsSuperUser,
        binary_checksum(
            o.AlphaCode,
            u.Status,
            u.FirstName,
            u.LastName,
            u.Initial,
            u.ASICNumber,
            u.ASICCheck,
            u.AgreementDate,
            u.AccessLevelName,
            u.AccreditationNumber,
            u.AllowAdjustPricing,
            u.AccountLocked,
            u.LoginFailedTimes,
            u.IsSuperUser
        ) HashedKey
    from
        penUser u
        inner join penOutlet o on
            o.OutletKey = u.OutletKey and
            o.OutletStatus = 'Current'
    where
        u.UserKey in
        (
            select
                t.UserKey
            from
                #useraudit t
        ) and
        UserStatus = 'Current'

    select
        AuditDateTime,
        AlphaCode,
        Login,
        Status,
        FirstName,
        LastName,
        Initial,
        ASICNumber,
        ASICCheck,
        AgreementDate,
        AccessLevelName,
        AccreditationNumber,
        AllowAdjustPricing,
        AccountLocked,
        LoginFailedTimes,
        IsSuperUser,
        @rptStartDate StartDate,
        @rptEndDate EndDate
    from
        #useraudit
    where
        UserKey in
        (
            select
                UserKey
            from
                #useraudit
            group by
                UserKey
            having
                count(distinct Hashedkey) > 1
        )
    order by
        UserKey,
        AuditDateTime


--select *
--from openrowset(
--    'SQLNCLI',
--    'server=localhost;uid=devuser;pwd=developer',
--    '
--    set fmtonly off
--    exec [db-au-cmdwh-Preprod]..rptsp_rpt0420
--        @Country = '@Prompt('Country', 'A', 'Agency\Country', Mono, Constrained, Persistent, {'AU'}, User:1)',
--        @Company = '@Prompt('Company', 'A', 'Agency\Company', Mono, Free, Persistent, {''}, User:2)',
--        @AgencyCode = '@Prompt('Agency Code', 'A', 'Agency\Agency Code', Mono, Free, Not_Persistent, {''}, User:3)',
--        @ReportingPeriod = '@prompt('Date Range','A','Consultant Revocation Calendar\Date Range',Mono,Free,Persistent,,User:4)',
--        @StartDate = '@Prompt('Start Date (optional, set for User Defined Date Range)', 'D', , Mono, Free, Not_Persistent, {'01/01/2013 12:00:00 AM'}, User:5)',
--        @EndDate = '@Prompt('End Date (optional, set for User Defined Date Range)', 'D', , Mono, Free, Not_Persistent, {'01/01/2013 12:00:00 AM'}, User:6)'
--    '
--)


end

GO
