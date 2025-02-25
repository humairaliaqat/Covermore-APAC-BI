USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0728b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt0728b]    @DateRange varchar(30),
                                    @StartDate varchar(10),
                                    @EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0728b
--  Author:         Linus Tor
--  Date Created:   20151214
--  Description:    This stored procedure outputs policy and quote traveller file for IAL.
--                    The stored proc will be called from Crystal Reports (RPT0728b) and output the following files
--
--                    Transaction.YYYYMMDD
--                    where YYYYMMDD is the date of the transaction (ie if today is 10/12/2015, the date extension is 20151209
--
--  Parameters:        @DateRange:        Required. Standard date range or _User Defined
--                    @StartDate:        Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--                    @EndDate:        Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--
--  Change History: 20151214 - LT - Created
--
/****************************************************************************************************/


--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2016-02-01', @EndDate = '2016-02-18'
*/

declare @dataStartDate date
declare @dataEndDate date
declare @DateExtension varchar(10)
declare @Filename varchar(50)
declare @OutputPath varchar(200)


--build filename
select @DateExtension = convert(varchar(10),dateadd(day,-1,getdate()),112)
select @FileName = 'IAL_Traveller.' + @DateExtension
select @OutputPath = '\\ulwibs01.aust.dmz.local\sftpshares\IA\'

/* initialise dates */
if @DateRange = '_User Defined'
    select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
    select @dataStartDate = StartDate, @dataEndDate = EndDate
    from [db-au-cmdwh].dbo.vDateRange
    where DateRange = @DateRange


if object_id('[db-au-cmdwh].dbo.usrRPT0728b') is null
begin
    create table [db-au-cmdwh].dbo.usrRPT0728b
    (
        [BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
        [xOutputFileNamex] [varchar](64) NULL,
        [xDataIDx] [varchar](41) NULL,                --use to store PolicyTransactionKey or QuoteKey
        [xDataValuex] [money] NOT NULL,                --use to store GrossPremium or QuotedPrice
        [Data] [nvarchar](max) NULL,
        [xFailx] [bit] NOT NULL,
        [DataTimeStamp] [datetime] NOT NULL
    )
    create clustered index idx_usrRPT0728b_BIRowID on [db-au-cmdwh].dbo.usrRPT0728b(BIRowID)
    create index idx_usrRPT0728b_DataTimeStamp on [db-au-cmdwh].dbo.usrRPT0728b(DataTimeStamp)
    create index idx_usrRPT0728b_xDataIDx on [db-au-cmdwh].dbo.usrRPT0728b(xDataIDx)
    create index idx_usrRPT0728b_xOutputFileNamex on [db-au-cmdwh].dbo.usrRPT0728b(xOutputFilenamex)
end
else            ---delete today's logged data if any
    delete [db-au-cmdwh].dbo.usrRPT0728b
    where
        DataTimeStamp >= convert(datetime,convert(varchar(10),getdate(),120)) and
        DataTimeStamp < convert(datetime,convert(varchar(10),dateadd(day,1,getdate()),120))

/* get all policykeys from dataStartDate to dataEndDate            */
if object_id('[db-au-workspace].dbo.RPT0728b_PolicyTraveller') is not null drop table [db-au-workspace].dbo.RPT0728b_PolicyTraveller
select
    pts.PolicyKey
into [db-au-workspace].dbo.RPT0728b_PolicyTraveller
from
    [db-au-cmdwh].dbo.penPolicyTransSummary pts
    inner join [db-au-cmdwh].dbo.penOutlet o on
            pts.OutletAlphaKey = o.OutletAlphaKey and
            o.OutletStatus = 'Current'
where
    pts.CountryKey = 'AU' and
    o.SuperGroupName = 'IAL' and
    (    pts.PostingDate between @dataStartDate and @dataEndDate
        OR
        (
            pts.PostingDate >= '2016-02-18' and                                ---data extract went live on this date
            pts.PostingDate < @dataStartDate and
            not exists(select null
                       from [db-au-cmdwh].dbo.usrRPT0728b
                       where
                            xDataIDx = pts.PolicyKey and
                            xFailx = 0 and
                            Data like '_Policy%'
                       )
        )
    )
group by
    pts.PolicyKey
order by 1

if object_id('[db-au-workspace].dbo.RPT0728b_Traveller') is null
begin
    create table [db-au-workspace].dbo.RPT0728b_Traveller
    (
        RowType varchar(20) not null,
        CustomerID varchar(20) null,
        QuoteID varchar(20) null,
        PolicyTravellerID varchar(20) null,
        PolicyID varchar(20) null,
        Title varchar(100) null,
        FirstName varchar(100) null,
        LastName varchar(100) null,
        DOB varchar(30) null,
        Age varchar(10) null,
        Gender varchar(10) null,
        isAdult varchar(10) null,
        AdultCharge varchar(10) null,
        isPrimary varchar(10) null,
        AddressLine1 varchar(100) null,
        AddressLine2 varchar(100) null,
        Suburb varchar(50) null,
        Postcode varchar(50) null,
        [State] varchar(100) null,
        Country varchar(100) null,
        HomePhone varchar(50) null,
        WorkPhone varchar(50) null,
        MobilePhone varchar(50) null,
        EmailAddress varchar(255) null,
        EMCReference varchar(100) null,
        OptFurtherContact varchar(10) null,
        MarketingConsent varchar(10) null,
        hasEMC varchar(10) null,
        IDKey varchar(50) null
    )
end
else
    truncate table [db-au-workspace].dbo.RPT0728b_Traveller


insert [db-au-workspace].dbo.RPT0728b_Traveller
(
    RowType,
    CustomerID,
    QuoteID,
    PolicyTravellerID,
    PolicyID,
    Title,
    FirstName,
    LastName,
    DOB,
    Age,
    Gender,
    isAdult,
    AdultCharge,
    isPrimary,
    AddressLine1,
    AddressLine2,
    Suburb,
    Postcode,
    [State],
    Country,
    HomePhone,
    WorkPhone,
    MobilePhone,
    EmailAddress,
    EMCReference,
    OptFurtherContact,
    MarketingConsent,
    hasEMC,
    IDKey
)
select
    'Policy' as RowType,
    'NULL' as CustomerID,
    'NULL' as QuoteID,
    convert(varchar(20),pt.PolicyTravellerID) as PolicyTravellerID,
    convert(varchar(20),pt.PolicyID) as PolicyID,
    convert(varchar(100),pt.Title) as Title,
    convert(varchar(100),pt.FirstName) as FirstName,
    convert(varchar(100),pt.LastName) as LastName,
    convert(varchar(30),pt.DOB,120) as DOB,
    convert(varchar(10),pt.Age) as Age,
    convert(varchar(10),pt.Gender) as Gender,
    convert(varchar(10),pt.isAdult) as isAdult,
    convert(varchar(10),pt.AdultCharge) as AdultCharge,
    convert(varchar(10),pt.isPrimary) as isPrimary,
    convert(varchar(100),pt.AddressLine1) as AddressLine1,
    convert(varchar(100),pt.AddressLine2) as AddressLine2,
    convert(varchar(50),pt.Suburb) as Suburb,
    convert(varchar(50),pt.Postcode) as Postcode,
    convert(varchar(100),pt.[State]) as [State],
    convert(varchar(100),pt.Country) as Country,
    convert(varchar(50),pt.HomePhone) as HomePhone,
    convert(varchar(50),pt.WorkPhone) as WorkPhone,
    convert(varchar(50),pt.MobilePhone) as MobilePhone,
    convert(varchar(255),pt.EmailAddress) as EmailAddress,
    convert(varchar(100),pt.EMCRef) as EMCReference,
    convert(varchar(10),pt.OptFurtherContact) as OptFurtherContact,
    convert(varchar(10),pt.MarketingConsent) as MarketingConsent,
    'NULL' as hasEMC,
    pt.PolicyKey
from
    penPolicyTraveller pt
where
    pt.PolicyKey in (select distinct PolicyKey from [db-au-workspace].dbo.RPT0728b_PolicyTraveller)



/* get all transaction Quotekeys from dataStartDate to dataEndDate            */
if object_id('[db-au-workspace].dbo.RPT0728b_QuoteTraveller') is not null drop table [db-au-workspace].dbo.RPT0728b_QuoteTraveller
select distinct
    q.QuoteKey
into [db-au-workspace].dbo.RPT0728b_QuoteTraveller
from
    [db-au-cmdwh].dbo.penQuote q
    inner join [db-au-cmdwh].dbo.penOutlet o on
            q.OutletAlphaKey = o.OutletAlphaKey and
            o.OutletStatus = 'Current'
where
    q.CountryKey = 'AU' and
    o.SuperGroupName = 'IAL' and
    (    q.CreateDate between @dataStartDate and @dataEndDate
        OR
        (
            q.CreateDate >= '2016-02-18' and                                ---data extract went live on this date
            q.CreateDate < @dataStartDate and
            not exists(select null
                       from [db-au-cmdwh].dbo.usrRPT0728b
                       where
                            xDataIDx = q.QuoteKey and
                            xFailx = 0 and
                            Data like '_Quote%'
                       )
        )
    )
group by
    q.QuoteKey
order by 1


insert [db-au-workspace].dbo.RPT0728b_Traveller
(
    RowType,
    CustomerID,
    QuoteID,
    PolicyTravellerID,
    PolicyID,
    Title,
    FirstName,
    LastName,
    DOB,
    Age,
    Gender,
    isAdult,
    AdultCharge,
    isPrimary,
    AddressLine1,
    AddressLine2,
    Suburb,
    Postcode,
    [State],
    Country,
    HomePhone,
    WorkPhone,
    MobilePhone,
    EmailAddress,
    EMCReference,
    OptFurtherContact,
    MarketingConsent,
    hasEMC,
    IDKey
)
select
    'Quote' as RowType,
    convert(varchar(20),cus.CustomerID) as CustomerID,
    convert(varchar(20),q.QuoteID) as QuoteID,
    'NULL' as PolicyTravellerID,
    'NULL' as PolicyID,
    convert(varchar(100),cus.Title) as Title,
    convert(varchar(100),cus.FirstName) as FirstName,
    convert(varchar(100),cus.LastName) as LastName,
    convert(varchar(30),cus.DOB,120) as DOB,
    convert(varchar(10),cus.Age) as Age,
    convert(varchar(10),cus.Gender) as Gender,
    convert(varchar(10),cus.isAdult) as isAdult,
    'NULL' as AdultCharge,
    convert(varchar(10),cus.isPrimary) as isPrimary,
    convert(varchar(100),cus.AddressLine1) as AddressLine1,
    convert(varchar(100),cus.AddressLine2) as AddressLine2,
    convert(varchar(50),cus.Suburb) as Suburb,
    convert(varchar(50),cus.Postcode) as Postcode,
    convert(varchar(100),cus.[State]) as [State],
    convert(varchar(100),cus.Country) as Country,
    convert(varchar(50),cus.HomePhone) as HomePhone,
    convert(varchar(50),cus.WorkPhone) as WorkPhone,
    convert(varchar(50),cus.MobilePhone) as MobilePhone,
    convert(varchar(255),cus.EmailAddress) as EmailAddress,
    'NULL' as EMCReference,
    convert(varchar(10),cus.OptFurtherContact) as OptFurtherContact,
    convert(varchar(10),cus.MarketingConsent) as MarketingConsent,
    convert(varchar(10),cus.HasEMC) as HasEMC,
    q.QuoteKey
from
    penQuote q
    inner join penOutlet o on
        q.OutletAlphaKey = o.OutletAlphaKey and
        o.OutletStatus = 'Current'
    outer apply
    (
        select
            qc.Age,
            qc.PersonIsAdult as isAdult,
            qc.isPrimary,
            qc.HasEMC,
            c.OptFurtherContact,
            c.MarketingConsent,
            c.AddressLine1,
            c.AddressLine2,
            c.Town as Suburb,
            c.Postcode,
            c.[State],
            c.Country,
            c.HomePhone,
            c.WorkPhone,
            c.MobilePhone,
            c.EmailAddress,
            c.CustomerID,
            c.Title,
            c.FirstName,
            c.LastName,
            c.DOB,
            c.Gender
        from
            penQuoteCustomer qc
            left join penCustomer c on qc.CustomerKey = c.CustomerKey
        where
            qc.QuoteCountryKey = q.QuoteCountryKey
    ) cus
where
    q.CountryKey = 'AU' and
    o.SuperGroupName = 'IAL' and
    q.QuoteKey in (select QuoteKey from [db-au-workspace].dbo.RPT0728b_QuoteTraveller)



--build data output
if object_id('[db-au-workspace].dbo.RPT0728b_Output') is null
begin
    create table [db-au-workspace].dbo.RPT0728b_Output
    (
        ID int identity(1,1) not null,
        data varchar(max) null,
        xDataIDx varchar(41) null,
        PolicyPremiumGWP money null
    )
end
else
    truncate table [db-au-workspace].dbo.RPT0728b_Output


--insert transaction column name record
insert [db-au-workspace].dbo.RPT0728b_Output
(
    data,
    xDataIDx,
    PolicyPremiumGWP
)
select
    '"RowType"|"CustomerID"|"QuoteID"|"PolicyTravellerID"|"PolicyID"|"Title"|"FirstName"|"LastName"|"DOB"|"Age"|"Gender"|"isAdult"|"AdultCharge"|"isPrimary"|"AddressLine1"|"AddressLine2"|"Suburb"|"Postcode"|"State"|"Country"|"HomePhone"|"WorkPhone"|"MobilePhone"|"EmailAddress"|"EMCReference"|"OptFurtherContact"|"MarketingConsent"|"hasEMC"' as Data,
    'ColumnName' as xDataIDx,
    0 as PolicyPremiumGWP


--insert transaction data
insert [db-au-workspace].dbo.RPT0728b_Output
(
    data,
    xDataIDx,
    PolicyPremiumGWP
)
select
    '"' +
    'Policy' + '"|"' +
    ltrim(rtrim(isnull(CustomerID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(QuoteID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(PolicyTravellerID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(PolicyID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Title,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(FirstName,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(LastName,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(DOB,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Age,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Gender,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(isAdult,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(AdultCharge,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(isPrimary,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(AddressLine1,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(AddressLine2,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Suburb,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Postcode,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([State],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Country,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(HomePhone,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(WorkPhone,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(MobilePhone,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(EmailAddress,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(EMCReference,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(OptFurtherContact,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(MarketingConsent,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(hasEMC,'NULL'))) + '"' as Data,
    IDKey as xDataIDx,
    0 as PolicyPremiumGWP
from
    [db-au-workspace].dbo.RPT0728b_Traveller
where
    RowType = 'Policy'


insert [db-au-workspace].dbo.RPT0728b_Output
(
    data,
    xDataIDx,
    PolicyPremiumGWP
)
select
    '"' +
    'Quote' + '"|"' +
    ltrim(rtrim(isnull(CustomerID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(QuoteID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(PolicyTravellerID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(PolicyID,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Title,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(FirstName,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(LastName,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(DOB,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Age,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Gender,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(isAdult,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(AdultCharge,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(isPrimary,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(AddressLine1,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(AddressLine2,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Suburb,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Postcode,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([State],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(Country,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(HomePhone,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(WorkPhone,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(MobilePhone,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(EmailAddress,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(EMCReference,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(OptFurtherContact,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(MarketingConsent,'NULL'))) + '"|"' +
    ltrim(rtrim(isnull(hasEMC,'NULL'))) + '"' as Data,
    IDKey as xDataIDx,
    0 as PolicyPremiumGWP
from
    [db-au-workspace].dbo.RPT0728b_Traveller
where
    RowType = 'Quote'


declare @RecordCount int
select @RecordCount = count(*)
from [db-au-workspace].dbo.RPT0728b_Traveller
where RowType in ('Policy','Quote')


--insert eof transaction record
insert [db-au-workspace].dbo.RPT0728b_Output
(
    data,
    xDataIDx,
    PolicyPremiumGWP
)
select
    '"FILE-END"|"' + convert(varchar,isnull(@RecordCount,0)) + '"|"EOF"' as Data,
    'Footer' as xDataIDx,
    '0.00' as PolicyPremiumGWP


--dump output to Logtable
insert [db-au-cmdwh].dbo.usrRPT0728b
(
    [xOutputFileNamex],
    [xDataIDx],
    [xDataValuex],
    [Data],
    [xFailx],
    [DataTimeStamp]
)
select
    @FileName as xOutputFileNamex,
    xDataIDx,
    PolicyPremiumGWP as xDataValuex,
    Data,
    0 as xFailx,
    getdate() as DataTimeStamp
from
    [db-au-workspace].dbo.RPT0728b_Output
order by ID



declare @SQL varchar(8000)

--export Transaction as pipe (|) delimited text file
select @sql = 'bcp "select Data from [db-au-workspace].dbo.RPT0728b_Output order by ID" queryout ' + @OutputPath + @FileName + ' -c -t "|" -T -S ULDWH02'
exec master..xp_cmdshell @sql




GO
