USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_policy_tias_nz]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_policy_tias_nz]    @RunMode varchar(10),        --HOURLY or DAILY or MANUAL
                                                    @StartDate varchar(10),        --Format: YYYY-MM-DD
                                                    @EndDate varchar(10)        --Format: YYYY-MM-DD
as

SET NOCOUNT ON


--uncomment to debug
/*
declare @RunMode varchar(10)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @RunMode = 'HOURLY', @StartDate = null, @EndDate = null
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

if @RunMode = 'HOURLY'                                    --picks up policy create date from start of last FY to today
begin
    select @rptStartDate = StartDate
    from [db-au-cmdwh].dbo.vDateRange
    where DateRange = 'Current Fiscal Month'

    select @rptEndDate = convert(varchar(10),getdate(),120)
end
else if @RunMode = 'DAILY'
begin
    select @rptStartDate = StartDate
    from [db-au-cmdwh].dbo.vDateRange
    where DateRange = 'Last Fiscal Year'

    select @rptEndDate = convert(varchar(10),getdate(),120)
end
else
    select @rptStartDate = @StartDate,
           @rptEndDate = @EndDate

select @rptStartDate, @rptEndDate, dateadd(year,-1,@rptStartDate) as LYStart, dateadd(year,-1,@rptEndDate) as LYEnd



/**********************************/
-- set dates for TY and LY

if object_id('tempdb..#policy_tias_nz_dates1') is not null drop table #policy_tias_nz_dates1
select
  d.[Date] as CreateDate
into #policy_tias_nz_dates1
from
  [db-au-cmdwh].dbo.Calendar d
where
  d.[Date] between @rptStartDate and @rptEndDate

if object_id('tempdb..#policy_tias_nz_dates2') is not null drop table #policy_tias_nz_dates2
select
  d.[Date] as CreateDate
into #policy_tias_nz_dates2
from
  [db-au-cmdwh].dbo.Calendar d
where
  d.[Date] between dateadd(year,-1,@rptStartDate) and dateadd(year,-1,@rptEndDate)


if object_id('[db-au-cmdwh].dbo.Policy_TIAS_NZ') is null
begin
    create table [db-au-cmdwh].dbo.Policy_TIAS_NZ
    (
        CountryKey varchar(2) NULL,
        AgencySuperGroup varchar(25) NULL,
        AgencyGroup varchar(25) null,
        BDM varchar(20) NULL,
        CreateDate datetime NULL,
        B2BPolicy int null,
        B2BSellPrice money null,
        B2BNetPrice money null,
        B2CPolicy int null,
        B2CSellPrice money null,
        B2CNetPrice money null,
        Policy int NULL,
        SellPrice money NULL,
        NetPrice money NULL,
        LYPolicy int NULL,
        LYSellPrice money NULL,
        LYNetPrice money NULL,
        DailyTargetVal money null
    )
  if exists(select name from sys.indexes where name = 'idx_policy_tias_nz_CountryKey')
    drop index idx_policy_tias_nz_CountryKey on policy_tias_nz.CountryKey

  if exists(select name from sys.indexes where name = 'idx_policy_tias_nz_CreateDate')
    drop index dx_policy_tias_nz_CreateDate on policy_tias_nz.CreateDate

  create index idx_policy_tias_nz_CountryKey on [db-au-cmdwh].dbo.policy_tias_nz(CountryKey)
  create index idx_policy_tias_nz_CreateDate on [db-au-cmdwh].dbo.policy_tias_nz(CreateDate)
end
else
  delete [db-au-cmdwh].dbo.policy_tias_nz
  where CreateDate between @rptStartDate and @rptEndDate

if object_id('[db-au-stage].dbo.tmp_policy_tias_nz1') is not null drop table [db-au-stage].dbo.tmp_policy_tias_nz1
select
    p.CountryKey,
    a.AgencySuperGroupName,
    case when a.AgencyGroupCode = 'FL' then 'Flight Centre'
     when a.AgencyGroupCode in ('AA','TS','TM') then 'Independents'
     when a.AgencyGroupCode in ('HS') then 'Harvey World'
     when a.AgencyGroupCode in ('AT') then 'APX'
     when a.AgencyGroupCode in ('GO') then 'GO Holidays'
     when a.AgencyGroupCode in ('ST') then 'STA'
     else a.AgencyGroupName
    end as AgencyGroupName,
    case when a.BDMName like '%Jason%' then 'Jason'
         when a.BDMName like '%Ross%' then 'Ross'
         when a.BDMName like '%Rochelle%' then 'Rochelle'
         else a.BDMName
    end as BDM,
    p.CreateDate as CreateDate,
    sum(case when right(p.BatchNo,2) <> 'BC' then
                case when p.PolicyType in ('N','E') then 1
                     when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
                     else 0
                end
             else 0
    end) as B2BPolicy,
    sum(case when right(p.BatchNo,2) <> 'BC' then p.GrossPremiumExGSTBeforeDiscount else 0 end) as B2BSellPrice,
    sum(case when right(p.BatchNo,2) <> 'BC' then p.NetPremium else 0 end) as B2BNetPrice,
    sum(case when right(p.BatchNo,2) = 'BC' then
                case when p.PolicyType in ('N','E') then 1
                     when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
                     else 0
                end
             else 0
    end) as B2CPolicy,
    sum(case when right(p.BatchNo,2) = 'BC' then p.GrossPremiumExGSTBeforeDiscount else 0 end) as B2CSellPrice,
    sum(case when right(p.BatchNo,2) = 'BC' then p.NetPremium else 0 end) as B2CNetPrice,
    sum(case when p.PolicyType in ('N','E') then 1
             when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
             else 0
        end) as Policy,
    sum(p.GrossPremiumExGSTBeforeDiscount) as SellPrice,
    sum(p.GrossPremiumExGSTBeforeDiscount + p.GSTonGrossPremium - p.CommissionAmount - p.GSTOnCommission) as NetPrice
into [db-au-stage].dbo.tmp_policy_tias_nz1
from
    [db-au-cmdwh].dbo.Policy p
    join [db-au-cmdwh].dbo.Agency a on
        p.CountryKey = a.CountryKey and
        p.AgencyKey = a.AgencyKey and
        a.AgencyStatus = 'Current'
where
    p.CreateDate between @rptStartDate and @rptEnddate and
    p.CountryKey = 'NZ' and
    a.AgencySuperGroupName is not null and
    a.BDMName <> 'Internal'
group by
    p.CountryKey,
    a.AgencySuperGroupName,
    case when a.AgencyGroupCode = 'FL' then 'Flight Centre'
     when a.AgencyGroupCode in ('AA','TS','TM') then 'Independents'
     when a.AgencyGroupCode in ('HS') then 'Harvey World'
     when a.AgencyGroupCode in ('AT') then 'APX'
     when a.AgencyGroupCode in ('GO') then 'GO Holidays'
     when a.AgencyGroupCode in ('ST') then 'STA'
     else a.AgencyGroupName
    end,
    case when a.BDMName like '%Jason%' then 'Jason'
         when a.BDMName like '%Ross%' then 'Ross'
         when a.BDMName like '%Rochelle%' then 'Rochelle'
         else a.BDMName
    end,
    p.CreateDate
order by
    p.CountryKey,
    a.AgencySuperGroupName,
    case when a.AgencyGroupCode = 'FL' then 'Flight Centre'
     when a.AgencyGroupCode in ('AA','TS','TM') then 'Independents'
     when a.AgencyGroupCode in ('HS') then 'Harvey World'
     when a.AgencyGroupCode in ('AT') then 'APX'
     when a.AgencyGroupCode in ('GO') then 'GO Holidays'
     when a.AgencyGroupCode in ('ST') then 'STA'
     else a.AgencyGroupName
    end,
    case when a.BDMName like '%Jason%' then 'Jason'
         when a.BDMName like '%Ross%' then 'Ross'
         when a.BDMName like '%Rochelle%' then 'Rochelle'
         else a.BDMName
    end,
    p.CreateDate


if object_id('tempdb..#policy_tias_nz1_main') is not null drop table #policy_tias_nz1_main
select
  a.CountryKey,
  a.AgencySuperGroupName,
  a.AgencyGroupName,
  a.BDM,
  d.CreateDate
into #policy_tias_nz1_main
from
  [db-au-stage].dbo.tmp_policy_tias_nz1 a
  cross join #policy_tias_nz_dates1 d

if object_id('[db-au-stage].dbo.tmp_policy_tias_nz1_main') is not null drop table [db-au-stage].dbo.tmp_policy_tias_nz1_main
select distinct
  m.CountryKey,
  m.AgencySuperGroupName,
  m.AgencyGroupName,
  m.BDM,
  m.CreateDate,
  a.B2BPolicy,
  a.B2BSellPrice,
  a.B2BNetPrice,
  a.B2CPolicy,
  a.B2CSellPrice,
  a.B2CNetPrice,
  a.Policy,
  a.SellPrice,
  a.NetPrice
into [db-au-stage].dbo.tmp_policy_tias_nz1_main
from
  #policy_tias_nz1_main m
  left join [db-au-stage].dbo.tmp_policy_tias_nz1 a on
    m.CountryKey = a.CountryKey and
    m.AgencySuperGroupname = a.AgencySuperGroupName and
    m.AgencyGroupName = a.AgencyGroupName and
    m.BDM = a.BDM and
    m.CreateDate = a.CreateDate
order by
  m.CountryKey,
  m.AgencySuperGroupName,
  m.AgencyGroupName,
  m.BDM,
  m.CreateDate

--select * from [db-au-stage].dbo.tmp_policy_tias_nz1_main  where AgencyGroupName = 'Harvey World' and CreateDate between '2010-10-01' and '2010-10-31'


/**************************/
-- Get LY Sales

if object_id('[db-au-stage].dbo.tmp_policy_tias_nz2') is not null drop table [db-au-stage].dbo.tmp_policy_tias_nz2
select
    p.CountryKey,
    a.AgencySuperGroupName,
    case when a.AgencyGroupCode = 'FL' then 'Flight Centre'
     when a.AgencyGroupCode in ('AA','TS','TM') then 'Independents'
     when a.AgencyGroupCode in ('HS') then 'Harvey World'
     when a.AgencyGroupCode in ('AT') then 'APX'
     when a.AgencyGroupCode in ('GO') then 'GO Holidays'
     when a.AgencyGroupCode in ('ST') then 'STA'
     else a.AgencyGroupName
    end as AgencyGroupName,
    case when a.BDMName like '%Jason%' then 'Jason'
         when a.BDMName like '%Ross%' then 'Ross'
         when a.BDMName like '%Rochelle%' then 'Rochelle'
         else a.BDMName
    end as BDM,
    p.CreateDate as CreateDate,
    sum(case when right(p.BatchNo,2) = 'BB' then
                case when p.PolicyType in ('N','E') then 1
                     when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
                     else 0
                end
             else 0
    end) as B2BPolicy,
    sum(case when right(p.BatchNo,2) = 'BB' then p.GrossPremiumExGSTBeforeDiscount else 0 end) as B2BSellPrice,
    sum(case when right(p.BatchNo,2) = 'BB' then p.NetPremium else 0 end) as B2BNetPrice,
    sum(case when right(p.BatchNo,2) = 'BC' then
                case when p.PolicyType in ('N','E') then 1
                     when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
                     else 0
                end
             else 0
    end) as B2CPolicy,
    sum(case when right(p.BatchNo,2) = 'BC' then p.GrossPremiumExGSTBeforeDiscount else 0 end) as B2CSellPrice,
    sum(case when right(p.BatchNo,2) = 'BC' then p.NetPremium else 0 end) as B2CNetPrice,
    sum(case when p.PolicyType in ('N','E') then 1
             when p.PolicyType = 'R' and p.OldPolicyType in ('N','E') then -1
             else 0
        end) as Policy,
    sum(p.GrossPremiumExGSTBeforeDiscount) as SellPrice,
    sum(p.GrossPremiumExGSTBeforeDiscount + p.GSTonGrossPremium - p.CommissionAmount - p.GSTOnCommission) as NetPrice
into  [db-au-stage].dbo.tmp_policy_tias_nz2
from
    [db-au-cmdwh].dbo.Policy p
    join [db-au-cmdwh].dbo.Agency a on
        p.CountryKey = a.CountryKey and
        p.AgencyKey = a.AgencyKey and
        a.AgencyStatus = 'Current'
where
    p.CreateDate between dateadd(year,-1,@rptStartDate) and dateadd(year,-1,@rptEnddate) and
    p.CountryKey = 'NZ' and
    a.BDMName <> 'Internal'
group by
    p.CountryKey,
    a.AgencySuperGroupName,
    case when a.AgencyGroupCode = 'FL' then 'Flight Centre'
     when a.AgencyGroupCode in ('AA','TS','TM') then 'Independents'
     when a.AgencyGroupCode in ('HS') then 'Harvey World'
     when a.AgencyGroupCode in ('AT') then 'APX'
     when a.AgencyGroupCode in ('GO') then 'GO Holidays'
     when a.AgencyGroupCode in ('ST') then 'STA'
     else a.AgencyGroupName
    end,
    case when a.BDMName like '%Jason%' then 'Jason'
         when a.BDMName like '%Ross%' then 'Ross'
         when a.BDMName like '%Rochelle%' then 'Rochelle'
         else a.BDMName
    end,
    p.CreateDate
order by
    p.CountryKey,
    a.AgencySuperGroupName,
    case when a.AgencyGroupCode = 'FL' then 'Flight Centre'
     when a.AgencyGroupCode in ('AA','TS','TM') then 'Independents'
     when a.AgencyGroupCode in ('HS') then 'Harvey World'
     when a.AgencyGroupCode in ('AT') then 'APX'
     when a.AgencyGroupCode in ('GO') then 'GO Holidays'
     when a.AgencyGroupCode in ('ST') then 'STA'
     else a.AgencyGroupName
    end,
    case when a.BDMName like '%Jason%' then 'Jason'
         when a.BDMName like '%Ross%' then 'Ross'
         when a.BDMName like '%Rochelle%' then 'Rochelle'
         else a.BDMName
    end,
    p.CreateDate


if object_id('tempdb..#policy_tias_nz2_main') is not null drop table #policy_tias_nz2_main
select
  a.CountryKey,
  a.AgencySuperGroupName,
  a.AgencyGroupName,
  a.BDM,
  d.CreateDate
into #policy_tias_nz2_main
from
  [db-au-stage].dbo.tmp_policy_tias_nz2 a
  cross join #policy_tias_nz_dates2 d

if object_id('[db-au-stage].dbo.tmp_policy_tias_nz2_main') is not null drop table [db-au-stage].dbo.tmp_policy_tias_nz2_main
select distinct
  m.CountryKey,
  m.AgencySuperGroupName,
  m.AgencyGroupName,
  m.BDM,
  m.CreateDate,
  a.B2BPolicy,
  a.B2BSellPrice,
  a.B2BNetPrice,
  a.B2CPolicy,
  a.B2CSellPrice,
  a.B2CNetPrice,
  a.Policy,
  a.SellPrice,
  a.NetPrice
into [db-au-stage].dbo.tmp_policy_tias_nz2_main
from
  #policy_tias_nz2_main m
  left join [db-au-stage].dbo.tmp_policy_tias_nz2 a on
    m.CountryKey = a.CountryKey and
    m.AgencySuperGroupname = a.AgencySuperGroupName and
    m.AgencyGroupName = a.AgencyGroupName and
    m.BDM = a.BDM and
    m.CreateDate = a.CreateDate
order by
  m.CountryKey,
  m.AgencySuperGroupName,
  m.AgencyGroupName,
  m.BDM,
  m.CreateDate

--select * from [db-au-stage].dbo.tmp_policy_tias_nz2_main  where AgencyGroupName = 'Harvey World' and CreateDate between '2009-10-01' and '2009-10-31'


if object_id('[db-au-stage].dbo.tmp_policy_tias_nz3') is not null drop table [db-au-stage].dbo.tmp_policy_tias_nz3
select
  a.CountryKey,
  a.AgencySuperGroupName,
  a.AgencyGroupName,
  a.BDM,
  d.CreateDate,
  a.B2BPolicy,
  a.B2BSellPrice,
  a.B2BNetPrice,
  a.B2CPolicy,
  a.B2CSellPrice,
  a.B2CNetPrice,
  a.Policy,
  a.SellPrice,
  a.NetPrice,
  b.Policy as LYPolicy,
  b.SellPrice as LYSellPrice,
  b.NetPrice as LYNetPrice,
  (select sum(b.BudgetValueSAF) from [db-au-cmdwh].dbo.TIAS_Budget_NZ b where b.BudgetGroup = a.AgencyGroupName and b.BudgetSubGroup = a.BDM and b.BudgetDate = a.CreateDate) as BudgetValue
into  [db-au-stage].dbo.tmp_policy_tias_nz3
from
  #policy_tias_nz_dates1 d
  full join [db-au-stage].dbo.tmp_policy_tias_nz1 a on
    d.CreateDate = a.CreateDate
  full join [db-au-stage].dbo.tmp_policy_tias_nz2 b on
    a.CountryKey = b.CountryKey and
    a.AgencySuperGroupName = b.AgencySuperGroupName and
    a.AgencyGroupName = b.AgencyGroupName and
    a.BDM = b.BDM and
    dateadd(year,-1,a.CreateDate) = b.CreateDate
order by
    a.CountryKey,
    a.AgencySuperGroupName,
    a.AgencyGroupName,
    a.BDM,
    d.CreateDate


if object_id('tempdb..#policy_tias_nz_main') is not null drop table #policy_tias_nz_main
select
  a.CountryKey,
  a.AgencySuperGroupName,
  a.AgencyGroupName,
  a.BDM,
  d.CreateDate
into #policy_tias_nz_main
from
  [db-au-stage].dbo.tmp_policy_tias_nz3 a
  cross join #policy_tias_nz_dates1 d

insert into [db-au-cmdwh].dbo.Policy_TIAS_NZ
select distinct
  m.CountryKey,
  m.AgencySuperGroupName,
  m.AgencyGroupName,
  m.BDM,
  m.CreateDate,
  a.B2BPolicy,
  a.B2BSellPrice,
  a.B2BNetPrice,
  a.B2CPolicy,
  a.B2CSellPrice,
  a.B2CNetPrice,
  a.Policy,
  a.SellPrice,
  a.NetPrice,
  a.LYPolicy,
  a.LYSellPrice,
  a.LYNetPrice,
  a.BudgetValue
from
  #policy_tias_nz_main m
  left join [db-au-stage].dbo.tmp_policy_tias_nz3 a on
    m.CountryKey = a.CountryKey and
    m.AgencySuperGroupname = a.AgencySuperGroupName and
    m.AgencyGroupName = a.AgencyGroupName and
    m.BDM = a.BDM and
    m.CreateDate = a.CreateDate
order by
  m.CountryKey,
  m.AgencySuperGroupName,
  m.AgencyGroupName,
  m.BDM,
  m.CreateDate



drop table #policy_tias_nz_dates1
drop table #policy_tias_nz_dates2
drop table #policy_tias_nz1_main
drop table #policy_tias_nz2_main
drop table #policy_tias_nz_main

GO
