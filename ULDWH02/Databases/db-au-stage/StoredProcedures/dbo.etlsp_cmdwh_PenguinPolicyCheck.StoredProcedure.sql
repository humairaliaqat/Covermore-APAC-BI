USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_PenguinPolicyCheck]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
CREATE procedure [dbo].[etlsp_cmdwh_PenguinPolicyCheck]    @ReportingPeriod varchar(30),  
                                                        @StartDate varchar(10),  
                                                        @EndDate varchar(10)  
as  
  
SET NOCOUNT ON  
  
  
/****************************************************************************************************/  
--  Name:           dbo.etlsp_cmdwh_PenguinPolicyCheck  
--  Author:         Linus Tor  
--  Date Created:   20130920  
--  Description:    This stored procedure inserts policy count data between Penguin and Data warehouse  
--  
--  Parameters:  
--                  @ReportingPeriodUpTo: Value is valid date range, used to determine end date  
--                  @StartDate: Enter if @ReportingPeriodUpTo = _User Defined. YYYY-MM-DD eg. 2010-01-01  
--                  @EndDate: Enter if @ReportingPeriodUpTo = _User Defined. YYYY-MM-DD eg. 2010-01-01  
--  
--  Change History: 20130920 - LT - Created  
--  
/****************************************************************************************************/  
  
--uncomment to debug  
/*  
declare @ReportingPeriod varchar(30)  
declare @StartDate varchar(10)  
declare @EndDate varchar(10)  
select @ReportingPeriod = 'Month-To-Date', @StartDate = null, @EndDate = null  
*/  
  
declare @rptStartDate smalldatetime  
declare @rptEndDate smalldatetime  
declare @rptEndPaymentDate smalldatetime  
  
/* get reporting dates */  
if @ReportingPeriod = '_User Defined'  
    select  
        @rptStartDate = convert(smalldatetime, @StartDate),  
        @rptEndDate = convert(smalldatetime, @EndDate)  
else  
    select  
        @rptStartDate = StartDate,  
        @rptEndDate = EndDate  
    from  
        [db-au-cmdwh].dbo.vDateRange  
    where  
        DateRange = @ReportingPeriod  
  
if OBJECT_ID('tempdb..#Data') is not null drop table #Data  
create table #Data  
(  
    [Source] varchar(50) null,  
    Country varchar(5) null,  
    IssueDateUTC datetime null,  
    GrossPremium money null,  
    NumberOfRows int null  
)  
  
insert #Data  
select  
    a.[Source],  
    a.Country,  
    a.IssueDateUTC,  
    a.GrossPremium,  
    a.NumberOfRows  
from  
(  
select  
    'Penguin CM' as [Source],  
    case when p.DomainID = 7 then 'AU'  
         when p.DomainID = 8 then 'NZ'  
         when p.DomainID = 9 then 'MY'  
         when p.DomainID = 10 then 'SG'  
         when p.DomainID = 11 then 'UK'  
         else ''  
    end as Country,  
    convert(varchar(10),pt.IssueDate,120) as IssueDateUTC,  
    sum(pt.GrossPremium) as GrossPremium,  
    count(*) as NumberOfRows  
from  
    [db-au-penguinsharp.aust.covermore.com.au].AU_PenguinSharp_Active.dbo.tblPolicy p  
    join [db-au-penguinsharp.aust.covermore.com.au].AU_PenguinSharp_Active.dbo.tblPolicyTransaction pt on p.PolicyID = pt.PolicyID  
where  
    convert(varchar(10),pt.IssueDate,120) between @rptStartDate and @rptEndDate  
group by  
    case when p.DomainID = 7 then 'AU'  
         when p.DomainID = 8 then 'NZ'  
         when p.DomainID = 9 then 'MY'  
         when p.DomainID = 10 then 'SG'  
         when p.DomainID = 11 then 'UK'  
         else ''  
    end,  
    convert(varchar(10),pt.IssueDate,120)  
  
union all  
  
select  
    'Penguin TIP' as [Source],  
    case when p.DomainID = 7 then 'AU'  
         when p.DomainID = 8 then 'NZ'  
         when p.DomainID = 9 then 'MY'  
         when p.DomainID = 10 then 'SG'  
         when p.DomainID = 11 then 'UK'  
         else ''  
    end as Country,  
    convert(varchar(10),pt.IssueDate,120) as IssueDateUTC,  
    sum(pt.GrossPremium) as GrossPremium,  
    count(*) as NumberOfRows  
from  
    [db-au-penguinsharp.aust.covermore.com.au].AU_TIP_PenguinSharp_Active.dbo.tblPolicy p  
    join [db-au-penguinsharp.aust.covermore.com.au].AU_TIP_PenguinSharp_Active.dbo.tblPolicyTransaction pt on p.PolicyID = pt.PolicyID  
where  
    convert(varchar(10),pt.IssueDate,120) between @rptStartDate and @rptEndDate  
group by  
    case when p.DomainID = 7 then 'AU'  
         when p.DomainID = 8 then 'NZ'  
         when p.DomainID = 9 then 'MY'  
         when p.DomainID = 10 then 'SG'  
         when p.DomainID = 11 then 'UK'  
         else ''  
    end,  
    convert(varchar(10),pt.IssueDate,120)  
  
union all  
  
select  
    'Penguin UK' as [Source],  
    case when p.DomainID = 7 then 'AU'  
         when p.DomainID = 8 then 'NZ'  
         when p.DomainID = 9 then 'MY'  
         when p.DomainID = 10 then 'SG'  
         when p.DomainID = 11 then 'UK'  
         else ''  
    end as Country,  
    convert(varchar(10),pt.IssueDate,120) as IssueDateUTC,  
    sum(pt.GrossPremium) as GrossPremium,  
    count(*) as NumberOfRows  
from  
    SQLIREPRODAGL01.UK_PenguinSharp_Active.dbo.tblPolicy p  
    join SQLIREPRODAGL01.UK_PenguinSharp_Active.dbo.tblPolicyTransaction pt on p.PolicyID = pt.PolicyID  
where  
  convert(varchar(10),pt.IssueDate,120) between @rptStartDate and @rptEndDate  
group by  
    case when p.DomainID = 7 then 'AU'  
         when p.DomainID = 8 then 'NZ'  
         when p.DomainID = 9 then 'MY'  
         when p.DomainID = 10 then 'SG'  
         when p.DomainID = 11 then 'UK'  
         else ''  
    end,  
    convert(varchar(10),pt.IssueDate,120)  
) a  
  
  
insert #Data  
select  
    case when p.CountryKey = 'AU' and p.CompanyKey = 'TIP' then 'DWH TIP'  
         when p.CountryKey = 'UK' then 'DWH UK'  
         else 'DWH CM'  
    end as [Source],  
    p.CountryKey as Country,  
    CONVERT(varchar(10),pt.IssueDateUTC,120) as IssueDateUTC,  
    sum(pt.GrossPremium) as GrossPremium,  
    count(*) as NumberOfRows  
from  
    [db-au-cmdwh].dbo.penPolicy p  
    join [db-au-cmdwh].dbo.penPolicyTransaction pt on p.PolicyKey = pt.PolicyKey  
where  
    convert(varchar(10),pt.IssueDateUTC,120) between @rptStartDate and @rptEndDate  
group by  
    case when p.CountryKey = 'AU' and p.CompanyKey = 'TIP' then 'DWH TIP'  
         when p.CountryKey = 'UK' then 'DWH UK'  
         else 'DWH CM'  
    end,  
    p.CountryKey,  
    CONVERT(varchar(10),pt.IssueDateUTC,120)  
  
if object_id('[db-au-stage].dbo.etl_PenguinPolicyCheck') is null  
begin  
    create table [db-au-stage].dbo.etl_PenguinPolicyCheck  
    (  
        CheckDateAEST datetime null,  
        [Source] varchar(20) null,  
        Country varchar(10) null,  
        IssueDateUTC datetime null,  
        GrossPremium money null,  
        NumberOfRows int null  
    )  
    create index idx_PenguinPolicyCheck_CheckDateAEST on [db-au-stage].dbo.etl_PenguinPolicyCheck(CheckDateAEST)  
    create index idx_PenguinPolicyCheck_IssueDateUTC on [db-au-stage].dbo.etl_PenguinPolicyCheck(IssueDateUTC)  
  
end  
else  
begin  
    delete [db-au-stage].dbo.etl_PenguinPolicyCheck  
    from [db-au-stage].dbo.etl_PenguinPolicyCheck  
    where IssueDateUTC between @rptStartDate and @rptEndDate  
end  
  
insert [db-au-stage].dbo.etl_PenguinPolicyCheck  
select  
    convert(varchar(10),getdate(),120) as CheckDateAEST,  
    [Source],  
    Country,  
    IssueDateUTC,  
    GrossPremium,  
    NumberOfRows  
from #Data  
order by  
    convert(varchar(10),getdate(),120),  
    [Source],  
    [Country],  
    [IssueDateUTC]  
  
drop table #Data  
GO
