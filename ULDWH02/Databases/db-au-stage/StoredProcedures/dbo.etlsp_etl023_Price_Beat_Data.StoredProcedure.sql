USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl023_Price_Beat_Data]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_etl023_Price_Beat_Data]
as

if object_id('[db-au-cmdwh].dbo.usrPriceBeat') is null
begin
    create table [db-au-cmdwh].[dbo].usrPriceBeat
    (
        CountryKey varchar(2) NOT NULL,
        CompanyKey varchar(5) NOT NULL,
        PriceBeatKey varchar(41) NULL,
        PolicyKey varchar(41) NULL,
        PolicyNoKey varchar(41) NULL,
        AgencyKey varchar(10) NULL,
        PriceBeatID int NOT NULL,
        ReceivedDate datetime NULL,
        AlphaCode varchar(10) NULL,
        AgencyName varchar(255) NULL,
        Consultant varchar(255) NULL,
        Client varchar(255) NULL,
        CompName varchar(100) NULL,
        CompPlan varchar(15) NULL,
        Adults tinyint NULL,
        CompPrice money NULL,
        Area varchar(1) NULL,
        Destination varchar(25) NULL,
        Duration varchar(3) NULL,
        DurLen varchar(6) NULL,
        Age varchar(5) NULL,
        TripCost money NULL,
        BasePrice money NULL,
        CMTAdd money NULL,
        TotalPrice money NULL,
        DefaultNet money NULL,
        PBResult varchar(50) NULL,
        Approved bit NOT NULL,
        PBPrice money NULL,
        AvgCommRate real NULL,
        PolicyType varchar(10) NULL,
        PolicyNo varchar(8) NULL,
        IssueDate datetime NULL,
        Initials varchar(15) NULL,
        AmountInSystem money NULL,
        AmountToBePaidFC money NULL,
        NetAdjust money NULL,
        Gross money NULL,
        Comm money NULL,
        Net money NULL,
        BrocPrice money NULL,
        Gross1 money NULL,
        Comm1 money NULL,
        Net1 money NULL,
        CommAdjustToBePaidFC money NULL,
        NetAdjustToBePaidFC money NULL,
        Percentage real NULL,
        Username varchar(25) NULL,
        LastAction datetime NULL,
        VoucherID varchar(10) NULL
    )
    if exists(select name from sys.indexes where name = 'idx_usrPriceBeat_CountryKey')
        drop index idx_usrPriceBeat_CountryKey on usrPriceBeat.CountryKey

    if exists(select name from sys.indexes where name = 'idx_usrPriceBeat_PriceBeatKey')
        drop index idx_usrPriceBeat_PriceBeatKey on usrPriceBeat.PriceBeatKey

    if exists(select name from sys.indexes where name = 'idx_usrPriceBeat_PolicyKey')
        drop index idx_usrPriceBeat_PolicyKey on usrPriceBeat.PolicyKey

    if exists(select name from sys.indexes where name = 'idx_usrPriceBeat_PolicyNoKey')
        drop index idx_usrPriceBeat_PolicyNoKey on usrPriceBeat.PolicyNoKey

    if exists(select name from sys.indexes where name = 'idx_usrPriceBeat_AgencyKey')
        drop index idx_usrPriceBeat_AgencyKey on usrPriceBeat.AgencyKey

    if exists(select name from sys.indexes where name = 'idx_usrPriceBeat_PriceBeatID')
        drop index idx_usrPriceBeat_PriceBeatID on usrPriceBeat.PriceBeatID

    if exists(select name from sys.indexes where name = 'idx_usrPriceBeat_PolicyNo')
        drop index idx_usrPriceBeat_PolicyNo on usrPriceBeat.PolicyNo

    create index idx_usrPriceBeat_CountryKey on [db-au-cmdwh].dbo.usrPriceBeat(CountryKey)
    create index idx_usrPriceBeat_PriceBeatKey on [db-au-cmdwh].dbo.usrPriceBeat(PriceBeatKey)
    create index idx_usrPriceBeat_PolicyKey on [db-au-cmdwh].dbo.usrPriceBeat(PolicyKey)
    create index idx_usrPriceBeat_PolicyNoKey on [db-au-cmdwh].dbo.usrPriceBeat(PolicyNoKey)
    create index idx_usrPriceBeat_AgencyKey on [db-au-cmdwh].dbo.usrPriceBeat(AgencyKey)
    create index idx_usrPriceBeat_PriceBeatID on [db-au-cmdwh].dbo.usrPriceBeat(PriceBeatID)
    create index idx_usrPriceBeat_PolicyNo on [db-au-cmdwh].dbo.usrPriceBeat(PolicyNo)
end
else
    truncate table [db-au-cmdwh].dbo.usrPriceBeat



insert into [db-au-cmdwh].dbo.usrPriceBeat with(tablockx)
(
    CountryKey,
    CompanyKey,
    PriceBeatKey,
    PolicyKey,
    PolicyNoKey,
    AgencyKey,
    PriceBeatID,
    ReceivedDate,
    AlphaCode,
    AgencyName,
    Consultant,
    Client,
    CompName,
    CompPlan,
    Adults,
    CompPrice,
    Area,
    Destination,
    Duration,
    DurLen,
    Age,
    TripCost,
    BasePrice,
    CMTAdd,
    TotalPrice,
    DefaultNet,
    PBResult,
    Approved,
    PBPrice,
    AvgCommRate,
    PolicyType,
    PolicyNo,
    IssueDate,
    Initials,
    AmountInSystem,
    AmountToBePaidFC,
    NetAdjust,
    Gross,
    Comm,
    Net,
    BrocPrice,
    Gross1,
    Comm1,
    Net1,
    CommAdjustToBePaidFC,
    NetAdjustToBePaidFC,
    Percentage,
    Username,
    LastAction,
    VoucherID
)
select
    'AU' as CountryKey,
    'CM' as CompanyKey,
    convert(varchar(41),left('AU-CM-' + cast(PBID as varchar),35)) as PriceBeatKey,
    left('AU-' + ltrim(rtrim(left(Alpha,7))) + '-' + convert(varchar,PolicyNo),41) as PolicyKey,
    convert(varchar(41),left('AU-' + cast(PolicyNo as varchar),38)) as PolicyNoKey,
    'AU-' + ltrim(rtrim(left(Alpha,7))) as AgencyKey,
    PBID as PriceBeatID,
    Received as ReceivedDate,
    Alpha as AlphaCode,
    Agency as AgencyName,
    Consultant,
    Client,
    CompName,
    CompPlan,
    Adults,
    CompPrice,
    Area,
    Destination,
    Duration,
    DurLen,
    Age,
    TripCost,
    BasePrice,
    CMTAdd,
    TotalPrice,
    DefaultNet,
    PBResult,
    Approved,
    PBPrice,
    AvgCommRate,
    Policy as PolicyType,
    PolicyNo,
    Issue,
    Initials,
    AmountInSystem,
    AmountToBePaidFC,
    NetAdjust,
    Gross,
    Comm,
    Net,
    BrocPrice,
    Gross1,
    Comm1,
    Net1,
    CommAdjustToBePaidFC,
    NetAdjustToBePaidFC,
    Percentage,
    Username,
    LastAction,
    VoucherID
from
    [db-au-stage].dbo.etl_pricebeat




GO
