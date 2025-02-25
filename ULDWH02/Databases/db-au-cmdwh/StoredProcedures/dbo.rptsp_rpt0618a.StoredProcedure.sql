USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0618a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt0618a] @DateRange varchar(30),
                                        @StartDate datetime,
                                        @EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0618
--  Author:         Linus Tor
--  Date Created:   20160920
--  Description:    This stored procedure returns FCTG consultants and their international policy count
--                    for the reporting period. This will be used for incentive campaign.
--  Parameters:     @DateRange: Value is valid date range
--                  @StartDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @DateRange = _User Defined. YYYY-MM-DD eg. 2010-01-01
--
--  Change History: 20160920 - LT - Created
--                    20161115 - LT - Added FLQ1822 outlet
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Yesterday', @StartDate = '2016-10-01', @EndDate = '2016-10-03'
*/

declare @rptStartDate datetime
declare    @rptEndDate datetime
declare @rptMonthStart datetime

--get reporting dates
if @DateRange = '_User Defined'
    select @rptStartDate = @StartDate, @rptEndDate = @EndDate
else
    select
        @rptStartDate = StartDate,
        @rptEndDate = EndDate
    from
        vDateRange
    where
        DateRange = @DateRange

--if end date is Sunday, then set start date to last friday
if datepart(dw,@rptEndDate) = 1
    select @rptStartDate = dateadd(day,-2,@rptStartDate)

--for first time run, the start and end dates are 01/10/2016 to 02/10/2016
if @rptEndDate = '2016-10-02'
    select @rptStartDate = '2016-10-01',
           @rptEndDate = '2016-10-02'

select @rptMonthStart = convert(datetime,convert(varchar(8),@rptStartDate,120)+'01')


if object_id('tempdb..#ConsultantTemp') is not null drop table #ConsultantTemp
select distinct
    o.OutletAlphaKey,
    o.ExtID as T3,
    u.UserKey,
    u.[Login] as T4,
    u.FirstName,
    u.LastName,
    u.Email
into #ConsultantTemp
from
    penPolicy p
    inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey
    inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
    inner join penUser u on pts.UserKey = u.UserKey
where
    o.SuperGroupName = 'Flight Centre' and
    o.CountryKey = 'AU' and
    (
        o.EGMNation in ('Flight Centre Brand','Niche Brands') or
        o.AlphaCode = 'FLQ1822'
    ) and
    u.UserStatus = 'Current' and
    o.OutletStatus = 'Current' and
    u.ConsultantType = 'External' and
    u.Status = 'Active' and
    p.IssueDate >= '2016-10-01' and
    p.IssueDate < dateadd(day,1,@rptEndDate) and
    pts.PostingDate >= @rptMonthStart and
    pts.PostingDate <= @rptEndDate


if object_id('tempdb..#Consultant') is not null drop table #Consultant
select
    c.OutletAlphaKey,
    c.UserKey,
    c.T4,
    c.T3,
    t.FirstName,
    t.LastName,
    t.Email
into #Consultant
from
    #ConsultantTemp c
    outer apply
    (
        select top 1 T4, FirstName, LastName, Email
        from usrFLEmployee
        where T4 = c.T4
    ) t
where
    t.T4 is not null


if object_id('tempdb..#PolicyCount') is not null drop table #PolicyCount
select
    oo.ExtID as T3,
    isnull(ou.[Login],u.[Login]) as T4,
    sum(ptss.BasePolicyCount) as BasePolicyCount
into #PolicyCount
from
    penPolicy pp
    inner join penPolicyTransSummary ptss on pp.PolicyKey = ptss.PolicyKey
    inner join penUser u on ptss.UserKey = u.UserKey and u.UserStatus = 'Current'
    inner join penOutlet oo on pp.OutletAlphaKey = oo.OutletAlphaKey and oo.OutletStatus = 'Current'
    outer apply                                                    --original consultant
    (
        select top 1 uu.UserKey, [Login], FirstName, LastName
        from
            penUser uu
            inner join penPolicyTransSummary ptt on
                uu.UserKey = ptt.UserKey and
                uu.OutletAlphaKey = ptt.OutletAlphaKey and
                uu.UserStatus = 'Current'
        where
            ptt.PolicyKey = pp.PolicyKey and
            ptt.TransactionType = 'Base' and
            ptt.TransactionStatus = 'Active'
    ) ou
where
    oo.CountryKey = 'AU' and
    oo.SuperGroupName = 'Flight Centre' and
    pp.AreaType = 'International' and
    pp.IssueDate >= '2016-10-01' and                        --start of competition
    pp.IssueDate < dateadd(day,1,@rptEndDate) and
    ptss.IssueDate >= @rptStartDate and
    ptss.IssueDate < dateadd(day,1,@rptEndDate)
group by
    oo.ExtID,
    isnull(ou.[Login],u.[Login])

if object_id('tempdb..#TotalPolicyCount') is not null drop table #TotalPolicyCount

select
    oo.ExtID as T3,
    isnull(ou.[Login],u.[Login]) as T4,
    sum(ptss.BasePolicyCount) as TotalPolicyCount                                    --get accumulative policy count for the month
into #TotalPolicyCount
from
    penPolicy pp
    inner join penPolicyTransSummary ptss on pp.PolicyKey = ptss.PolicyKey
    inner join penOutlet oo on ptss.OutletAlphaKey = oo.OutletAlphaKey and oo.OutletStatus = 'Current'
    inner join penUser u on ptss.UserKey = u.UserKey and u.UserStatus = 'Current'
    outer apply                                                    --original consultant
    (
        select top 1 uu.UserKey, [Login], FirstName, LastName
        from
            penUser uu
            inner join penPolicyTransSummary ptt on
                uu.UserKey = ptt.UserKey and
                uu.OutletAlphaKey = ptt.OutletAlphaKey and
                uu.UserStatus = 'Current'
        where
            ptt.PolicyKey = pp.PolicyKey and
            ptt.TransactionType = 'Base' and
            ptt.TransactionStatus = 'Active'
    ) ou
where
    oo.CountryKey = 'AU' and
    oo.SuperGroupName = 'Flight Centre' and
    pp.AreaType = 'International' and
    pp.IssueDate >= '2016-10-01' and                        --start of competition
    pp.IssueDate < dateadd(day,1,@rptEndDate) and
    ptss.PostingDate >= @rptMonthStart and                    --competition period month start
    ptss.PostingDate <= @rptEndDate
group by
    oo.ExtID,
    isnull(ou.[Login],u.[Login])


if object_id('tempdb..#Final') is not null drop table #final
select
    convert(varchar(25),@rptEndDate,120) as [Previous Day],
    left(c.T4,50) as T4,
    left(c.FirstName,100) as [First Name],
    left(c.LastName,100) as [Last Name],
    left(c.Email,250) as Email,
    convert(varchar(50),isnull(sum(p.BasePolicyCount),0)) as [Policy Count],
    convert(varchar(50),isnull(sum(tp.TotalPolicyCount),0)) as [Total Policy Count]
into #final
from
    #Consultant c
    outer apply
    (
        select sum(BasePolicyCount) as BasePolicyCount
        from #PolicyCount
        where T4 = c.T4 and T3 = c.T3
    ) p
    outer apply
    (
        select sum(TotalPolicyCount) as TotalPolicyCount
        from #TotalPolicyCount
        where T4 = c.T4 and T3 = c.T3
    ) tp
group by
    left(c.T4,50),
    left(c.FirstName,100),
    left(c.LastName,100),
    left(c.Email,250)



if object_id('tempdb..##rpt0618a') is not null drop table ##rpt0618a

create table ##rpt0618a
(
    [Previous Day] varchar(50) null,
    T4 varchar(50) null,
    [First Name] varchar(100) null,
    [Last Name] varchar(100) null,
    [Email] varchar(250) null,
    [Policy Count] varchar(50) null,
    [Total Policy Count] varchar(50) null
)

--insert column header
insert ##rpt0618a values('Previous Day','T4','First Name','Last Name','Email','Policy Count','Total Policy Count')

--insert data
insert ##rpt0618a
select
    [Previous Day],
    T4,
    [First Name],
    [Last Name],
    Email,
    [Policy Count],
    [Total Policy Count]
from
    #Final


declare @SQL varchar(8000)
declare @Filename varchar(200)
declare @Path varchar(200)
declare @recipientText varchar(200)
declare @cctext varchar(200)
declare @SubjectText varchar(200)
declare @FileAttachmentText varchar(500)

select @Filename = 'rpt0618a_Flight_Centre_Poker_Machine_Incentive_' + convert(varchar(8),getdate(),112),
       @Path = 'e:\ETL\Data\'


----export to csv file
select @SQL = 'bcp ##rpt0618a out ' + @Path + @Filename + '.csv -c -t "," -T -S ULDWH02'
exec master..xp_cmdshell @SQL

--zip file
select @SQL = '"c:\program files (x86)\7-zip\7z.exe" a -p%CMaf65) ' + @Path + @Filename + '.zip ' + @Path + @Filename + '.csv'
execute master..xp_cmdshell @SQL


--email file
select @recipienttext = 'data@feed.slot2trot.com'
select @cctext = 'linus.tor@covermore.com; rebecca.mulholland@covermore.com; rebecca.hurley@covermore.com; marianela.fernandez@covermore.com'
select @SubjectText = 're: ' + @Filename
select @FileAttachmentText = 'E:\\ETL\Data\' + @Filename + '.zip'

EXEC msdb.dbo.sp_send_dbmail @profile_name='covermorereport',
                             @recipients=@RecipientText,
                             @copy_recipients=@cctext,
                             @subject= @SubjectText,
                             @body='Please find attached Flight Centre Poker Machine Incentive data file.',
                             @file_attachments=@FileAttachmentText

drop table ##rpt0618a
drop table #ConsultantTemp
drop table #Consultant
drop table #PolicyCount
drop table #TotalPolicyCount
drop table #Final


GO
