USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0728a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt0728a]    @DateRange varchar(30),
                                    @StartDate varchar(10),
                                    @EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0728a
--  Author:         Linus Tor
--  Date Created:   20151214
--  Description:    This stored procedure outputs policy and quote transaction file for IAL.
--                    The stored proc will be called from Crystal Reports (RPT0728a) and output the following files
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
select @DateRange = '_User Defined', @StartDate = '2016-02-19', @EndDate = '2016-02-21'
*/

declare @dataStartDate date
declare @dataEndDate date
declare @DateExtension varchar(10)
declare @Filename varchar(50)
declare @OutputPath varchar(200)


--build filename
select @DateExtension = convert(varchar(10),dateadd(day,-1,getdate()),112)
select @FileName = 'IAL_Transaction.' + @DateExtension
select @OutputPath = '\\ulwibs01.aust.dmz.local\sftpshares\IA\'

/* initialise dates */
if @DateRange = '_User Defined'
    select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
    select @dataStartDate = StartDate, @dataEndDate = EndDate
    from [db-au-cmdwh].dbo.vDateRange
    where DateRange = @DateRange


if object_id('[db-au-cmdwh].dbo.usrRPT0728a') is null
begin
    create table [db-au-cmdwh].dbo.usrRPT0728a
    (
        [BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
        [xOutputFileNamex] [varchar](64) NULL,
        [xDataIDx] [varchar](41) NULL,                --use to store PolicyTransactionKey or QuoteKey
        [xDataValuex] [money] NOT NULL,                --use to store GrossPremium or QuotedPrice
        [Data] [nvarchar](max) NULL,
        [xFailx] [bit] NOT NULL,
        [DataTimeStamp] [datetime] NOT NULL
    )
    create clustered index idx_usrRPT0728a_BIRowID on [db-au-cmdwh].dbo.usrRPT0728a(BIRowID)
    create index idx_usrRPT0728a_DataTimeStamp on [db-au-cmdwh].dbo.usrRPT0728a(DataTimeStamp)
    create index idx_usrRPT0728a_xDataIDx on [db-au-cmdwh].dbo.usrRPT0728a(xDataIDx)
    create index idx_usrRPT0728a_xOutputFileNamex on [db-au-cmdwh].dbo.usrRPT0728a(xOutputFilenamex)
end
else            ---delete today's logged data if any
    delete [db-au-cmdwh].dbo.usrRPT0728a
    where
        DataTimeStamp >= convert(datetime,convert(varchar(10),getdate(),120)) and
        DataTimeStamp < convert(datetime,convert(varchar(10),dateadd(day,1,getdate()),120))


/* get all transaction policykeys from dataStartDate to dataEndDate            */
if object_id('[db-au-workspace].dbo.RPT0728a_PolicyTransaction') is not null drop table [db-au-workspace].dbo.RPT0728a_PolicyTransaction
select
    pts.PolicyKey,
    pts.PolicyTransactionKey
into [db-au-workspace].dbo.RPT0728a_PolicyTransaction
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
                       from [db-au-cmdwh].dbo.usrRPT0728a
                       where
                            xDataIDx = pts.PolicyTransactionKey and
                            xFailx = 0 and
                            Data like '_Policy%'
                       )
        )
    )
group by
    pts.PolicyKey,
    pts.PolicyTransactionKey
order by 1,2


if object_id('[db-au-workspace].dbo.RPT0728a_Transaction') is null
begin
    create table [db-au-workspace].dbo.RPT0728a_Transaction
    (
        RowType varchar(20) not null,
        GroupName varchar(100) null,
        SubGroupName varchar(100) null,
        AlphaCode varchar(20) null,
        OutletName varchar(100) null,
        OutletType varchar(50) null,
        Branch varchar(60) null,
        [State] varchar(50) null,
        QuoteID varchar(50) null,
        SessionID varchar(255) null,
        PolicyID varchar(50) null,
        PolicyNumber varchar(50) null,
        IssueDate varchar(30) null,
        QuoteDate varchar(30) null,
        QuoteTime varchar(30) null,
        isSelected varchar(10) null,
        isSaved varchar(10) null,
        QuoteSaveDate varchar(30) null,
        PolicyStatus varchar(50) null,
        CancelledDate varchar(30) null,
        ProductCode varchar(50) null,
        ProductDisplayName varchar(50) null,
        PlanName varchar(50) null,
        AreaType varchar(25) null,
        Area varchar(100) null,
        Destination varchar(max) null,
        TripStart varchar(30) null,
        TripEnd varchar(30) null,
        Excess varchar(30) null,
        DaysCovered varchar(10) null,
        TripType varchar(50) null,
        EmailConsent varchar(10) null,
        PolicyTransactionID varchar(30) null,
        TransactionNumber varchar(50) null,
        TransactionDate varchar(30) null,
        TransactionType varchar(50) null,
        TransactionStatus varchar(50) null,
        Username varchar(100) null,
        ConsultantName varchar(100) null,
        CoverMoreCSR varchar(100) null,
        TaxAmountSD varchar(30) null,
        TaxOnAgentCommissionSD varchar(30) null,
        TaxAmountGST varchar(30) null,
        TaxOnAgentCommissionGST varchar(30) null,
        QuotePrice varchar(30) null,
        SellPrice varchar(30) null,
        AgencyCommission varchar(30) null,
        NetPrice varchar(30) null,
        BasePolicyCount varchar(10) null,
        QuoteCount varchar(10) null,
        AddonPolicyCount varchar(10) null,
        ExtensionPolicyCount varchar(10) null,
        TravellerCount varchar(10) null,
        AdultCount varchar(10) null,
        ChildCount varchar(10) null,
        ChargedAdultCount varchar(10) null,
        LuggageCount varchar(10) null,
        MedicalCount varchar(10) null,
        MotorcycleCount varchar(10) null,
        RentalCarCount varchar(10) null,
        WintersportCount varchar(10) null,
        EMCCount varchar(10) null,
        PromoCode varchar(10) null,
        PromoName varchar(250) null,
        PromoType varchar(50) null,
        PromoDiscount varchar(10) null,
        GoBelowNet varchar(10) null,
        IDKey varchar(50) null
    )
end
else truncate table [db-au-workspace].dbo.RPT0728a_Transaction


insert [db-au-workspace].dbo.RPT0728a_Transaction
(
    RowType,
    GroupName,
    SubGroupName,
    AlphaCode,
    OutletName,
    OutletType,
    Branch,
    [State],
    QuoteID,
    SessionID,
    PolicyID,
    PolicyNumber,
    IssueDate,
    QuoteDate,
    QuoteTime,
    isSelected,
    isSaved,
    QuoteSaveDate,
    PolicyStatus,
    CancelledDate,
    ProductCode,
    ProductDisplayName,
    PlanName,
    AreaType,
    Area,
    Destination,
    TripStart,
    TripEnd,
    Excess,
    DaysCovered,
    TripType,
    EmailConsent,
    PolicyTransactionID,
    TransactionNumber,
    TransactionDate,
    TransactionType,
    TransactionStatus,
    Username,
    ConsultantName,
    CoverMoreCSR,
    TaxAmountSD,
    TaxOnAgentCommissionSD,
    TaxAmountGST,
    TaxOnAgentCommissionGST,
    QuotePrice,
    SellPrice,
    AgencyCommission,
    NetPrice,
    BasePolicyCount,
    QuoteCount,
    AddonPolicyCount,
    ExtensionPolicyCount,
    TravellerCount,
    AdultCount,
    ChildCount,
    ChargedAdultCount,
    LuggageCount,
    MedicalCount,
    MotorcycleCount,
    RentalCarCount,
    WintersportCount,
    EMCCount,
    PromoCode,
    PromoName,
    PromoType,
    PromoDiscount,
    GoBelowNet,
    IDKey
)
select
    'Policy' as RowType,
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.OutletType,
    o.Branch,
    o.StateSalesArea,
    convert(varchar(50),'NULL') as QuoteID,
    convert(varchar(50),'NULL') as SessionID,
    convert(varchar(30),p.PolicyID) as PolicyID,
    convert(varchar(50),p.PolicyNumber) as PolicyNumber,
    convert(varchar(30),p.IssueDate,120) as IssueDate,
    convert(varchar(30),'NULL') as QuoteDate,
    convert(varchar(30),'NULL') as QuoteTime,
    convert(varchar(10),'NULL') as isSelected,
    convert(varchar(10),'NULL') as isSaved,
    convert(varchar(30),'NULL') as QuoteSaveDate,
    p.StatusDescription as PolicyStatus,
    convert(varchar(30),p.CancelledDate,120) as CancelledDate,
    p.ProductCode,
    p.ProductDisplayName,
    p.PlanName,
    p.AreaType,
    p.Area,
    p.PrimaryCountry as Destination,
    convert(varchar(30),p.TripStart,120) as TripStart,
    convert(varchar(30),p.TripEnd,120) as TripEnd,
    convert(varchar(30),p.Excess) as Excess,
    convert(varchar(10),p.DaysCovered) as DaysCovered,
    p.TripType,
    convert(varchar(10),p.EmailConsent) as EmailConsent,
    convert(varchar(30),pts.PolicyTransactionID) as PolicyTransactionID,
    convert(varchar(50),pts.PolicyNumber) as TransactionNumber,
    convert(varchar(30),pts.IssueDate,120) as TransactionDate,
    pts.TransactionType,
    pts.TransactionStatus,
    ltrim(rtrim(u.Username)) as UserName,
    ltrim(rtrim(u.ConsultantName)) as ConsultantName,
    ltrim(rtrim(pts.CRMUserName)) as CoverMoreCSR,
    convert(varchar(30),pts.TaxAmountSD) as TaxAmountSD,
    convert(varchar(30),pts.TaxOnAgentCommissionSD) as TaxOnAgentCommissionSD,
    convert(varchar(30),pts.TaxAmountGST) as TaxAmountGST,
    convert(varchar(30),pts.TaxOnAgentCommissionGST) as TaxOnAgentCommissionGST,
    convert(varchar(30),'null') as QuotePrice,
    convert(varchar(30),pts.GrossPremium) as SellPrice,
    convert(varchar(30),pts.Commission + pts.GrossAdminFee) as AgencyCommission,
    convert(varchar(30),pts.AdjustedNet) as NetPrice,
    convert(varchar(10),pts.BasePolicyCount) as BasePolicyCount,
    convert(varchar(10),'null') as QuoteCount,
    convert(varchar(10),pts.AddonPolicyCount) as AddonPolicyCount,
    convert(varchar(10),pts.ExtensionPolicyCount) as ExtensionPolicyCount,
    convert(varchar(10),pts.TravellersCount) as TravellerCount,
    convert(varchar(10),pts.AdultsCount) as AdultCount,
    convert(varchar(10),pts.ChildrenCount) as ChildCount,
    convert(varchar(10),pts.ChargedAdultsCount) as ChargedAdultCount,
    convert(varchar(10),pts.LuggageCount) as LuggageCount,
    convert(varchar(10),pts.MedicalCount) as MedicalCount,
    convert(varchar(10),pts.MotorcycleCount) as MotorcycleCount,
    convert(varchar(10),pts.RentalCarCount) as RentalCarCount,
    convert(varchar(10),pts.WintersportCount) as WintersportCount,
    convert(varchar(10),pts.EMCCount) as EMCCount,
    promo.PromoCode,
    promo.PromoName,
    promo.PromoType,
    convert(varchar(30),promo.PromoDiscount) as PromoDiscount,
    convert(varchar(10),promo.GoBelowNet) as GoBelowNet,
    pts.PolicyTransactionKey as IDKey
from
    penPolicy p
    join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
    join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
    outer apply
    (
        select top 1
            [Login] as UserName,
            FirstName + ' ' + LastName as ConsultantName
        from
            penUser
        where
            UserKey = pts.UserKey
    ) u
    outer apply
    (
        select top 1
            PromoCode,
            PromoName,
            PromoType,
            Discount as PromoDiscount,
            GoBelowNet
        from
            penPolicyTransactionPromo
        where
            PolicyTransactionKey = pts.PolicyTransactionKey and
            IsApplied = 1
    ) promo
where
    p.CountryKey = 'AU' and
    o.SuperGroupName = 'IAL' and
    pts.PolicyTransactionKey in (select PolicyTransactionKey from [db-au-workspace].dbo.RPT0728a_PolicyTransaction)



/* get all transaction QuoteKeys from dataStartDate to dataEndDate            */
if object_id('[db-au-workspace].dbo.RPT0728a_QuoteTransaction') is not null drop table [db-au-workspace].dbo.RPT0728a_QuoteTransaction
select
    q.QuoteKey
into [db-au-workspace].dbo.RPT0728a_QuoteTransaction
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
                       from [db-au-cmdwh].dbo.usrRPT0728a
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


insert [db-au-workspace].dbo.RPT0728a_Transaction
(
    RowType,
    GroupName,
    SubGroupName,
    AlphaCode,
    OutletName,
    OutletType,
    QuoteID,
    SessionID,
    PolicyID,
    PolicyNumber,
    IssueDate,
    QuoteDate,
    QuoteTime,
    isSelected,
    isSaved,
    QuoteSaveDate,
    PolicyStatus,
    CancelledDate,
    ProductCode,
    ProductDisplayName,
    PlanName,
    AreaType,
    Area,
    Destination,
    TripStart,
    TripEnd,
    Excess,
    DaysCovered,
    TripType,
    EmailConsent,
    PolicyTransactionID,
    TransactionNumber,
    TransactionDate,
    TransactionType,
    TransactionStatus,
    Username ,
    ConsultantName,
    CoverMoreCSR,
    TaxAmountSD,
    TaxOnAgentCommissionSD,
    TaxAmountGST,
    TaxOnAgentCommissionGST,
    QuotePrice,
    SellPrice,
    AgencyCommission,
    NetPrice,
    BasePolicyCount,
    QuoteCount,
    AddonPolicyCount,
    ExtensionPolicyCount,
    TravellerCount,
    AdultCount,
    ChildCount,
    ChargedAdultCount,
    LuggageCount,
    MedicalCount,
    MotorcycleCount,
    RentalCarCount,
    WintersportCount,
    EMCCount,
    PromoCode,
    PromoName,
    PromoType,
    PromoDiscount,
    GoBelowNet,
    IDKey
)
select
    'Quote' as RowType,
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.OutletType,
    q.QuoteID,
    q.SessionID,
    p.PolicyID,
    p.PolicyNumber,
    convert(varchar(30),p.IssueDate,120) as IssueDate,
    convert(varchar(30),q.CreateDate,120) as QuoteDate,
    convert(varchar(30),q.CreateTime,120) as QuoteTime,
    q.IsSelected,
    q.IsSaved,
    convert(varchar(30),q.QuoteSaveDate,120) as QuoteSaveDate,
    'NULL' as PolicyStatus,
    'NULL' as CancelledDate,
    q.ProductCode,
    q.ProductDisplayName,
    q.PlanName,
    'NULL' as AreaType,
    q.Area,
    q.Destination,
    convert(varchar(30),q.DepartureDate,120) as TripStart,
    convert(varchar(30),q.ReturnDate,120) as TripEnd,
    q.Excess,
    q.DaysCovered,
    q.PlanType as TripType,
    'NULL' as EmailConsent,
    'NULL' as PolicyTransactionID,
    'NULL' as TransactionNumber,
    'NULL' as TransactionDate,
    'NULL' as TransactionType,
    'NULL' as TransactionStatus,
    q.Username,
    q.ConsultantName,
    'NULL' as CoverMoreCSR,
    'NULL' as TaxAmountSD,
    'NULL' as TaxOnAgentCommissionSD,
    'NULL' as TaxAmountGST,
    'NULL' as TaxOnAgentCommissionGST,
    q.QuotedPrice as QuotePrice,
    'NULL' as SellPrice,
    'NULL' as AgencyCommission,
    'NULL' as NetPrice,
    'NULL' as BasePolicyCount,
    1 as QuoteCount,
    'NULL' as AddonPolicyCount,
    'NULL' as ExtensionPolicyCount,
    q.NumberOfPersons as TravellerCount,
    q.NumberofAdults as AdultCount,
    q.NumberOfChildren as ChildCount,
    'NULL' as ChargedAdultCount,
    'NULL' as LuggageCount,
    'NULL' as MedicalCount,
    'NULL' as MotorcycleCount,
    'NULL' as RentalCarCount,
    'NULL' as WintersportCount,
    'NULL' as EMCCount,
    promo.PromoCode,
    promo.PromoName,
    promo.PromoType,
    promo.PromoDiscount,
    promo.GoBelowNet,
    q.QuoteKey
from
    penQuote q
    join penOutlet o on
        q.OutletAlphaKey = o.OutletAlphaKey and
        o.OutletStatus = 'Current'
    outer apply
    (
        select top 1
            PromoCode,
            PromoName,
            PromoType,
            Discount as PromoDiscount,
            GoBelowNet
        from
            penQuotePromo
        where
            isApplied = 1 and
            QuoteCountryKey = q.QuoteCountryKey
    ) promo
    outer apply
    (
        select top 1
            PolicyID,
            PolicyNumber,
            IssueDate
        from
            [db-au-cmdwh].dbo.penPolicy
        where
            CountryKey = q.CountryKey and
            CompanyKey = q.CompanyKey and
            PolicyNumber = q.PolicyNo
    ) p
where
    q.CountryKey = 'AU' and
    o.SuperGroupName = 'IAL' and
    q.QuoteKey in (select QuoteKey from [db-au-workspace].dbo.RPT0728a_QuoteTransaction)


--build data output
if object_id('[db-au-workspace].dbo.RPT0728a_Output') is null
begin
    create table [db-au-workspace].dbo.RPT0728a_Output
    (
        ID int identity(1,1) not null,
        data varchar(max) null,
        xDataIDx varchar(41) null,
        PolicyPremiumGWP money null
    )
end
else
    truncate table [db-au-workspace].dbo.RPT0728a_Output


--insert transaction column name record
insert [db-au-workspace].dbo.RPT0728a_Output
(
    data,
    xDataIDx,
    PolicyPremiumGWP
)
select
    '"RowType"|"GroupName"|"SubGroupName"|"AlphaCode"|"OutletName"|"OutletType"|"Branch"|"State"|"QuoteID"|"SessionID"|"PolicyID"|"PolicyNumber"|"IssueDate"|"QuoteDate"|"QuoteTime"|"isSelected"|"isSaved"|"QuoteSaveDate"|"PolicyStatus"|"CancelledDate"|"ProductCode"|"ProductDisplayName"|"PlanName"|"AreaType"|"Area"|"Destination"|"TripStart"|"TripEnd"|"Excess"|"DaysCovered"|"TripType"|"EmailConsent"|"PolicyTransactionID"|"TransactionNumber"|"TransactionDate"|"TransactionType"|"TransactionStatus"|"UserName"|"ConsultantName"|"CoverMoreCSR"|"TaxAmountSD"|"TaxOnAgentCommissionSD"|"TaxAmountGST"|"TaxOnAgentCommissionGST"|"QuotePrice"|"SellPrice"|"AgencyCommission"|"NetPrice"|"BasePolicyCount"|"QuoteCount"|"AddonPolicyCount"|"ExtensionPolicyCount"|"TravellerCount"|"AdultCount"|"ChildCount"|"ChargedAdultCount"|"LuggageCount"|"MedicalCount"|"MotorcycleCount"|"RentalCarCount"|"WintersportCount"|"EMCCount"|"PromoCode"|"PromoName"|"PromoType"|"PromoDiscount"|"GoBelowNet"' as Data,
    'ColumnName' as xDataIDx,
    0 as PolicyPremiumGWP

--insert policy transaction record
insert [db-au-workspace].dbo.RPT0728a_Output
(
    data,
    xDataIDx,
    PolicyPremiumGWP
)
select
    '"' +
    ltrim(rtrim(isnull([RowType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([GroupName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([SubGroupName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AlphaCode],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([OutletName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([OutletType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Branch],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([State],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([SessionID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyNumber],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([IssueDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteTime],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([isSelected],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([isSaved],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteSaveDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyStatus],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([CancelledDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ProductCode],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ProductDisplayName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PlanName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AreaType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Area],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Destination],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TripStart],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TripEnd],'NULL'))) + '"|"' +
    replace(ltrim(rtrim(isnull([Excess],'NULL'))),',','') + '"|"' +
    ltrim(rtrim(isnull([DaysCovered],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TripType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([EmailConsent],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyTransactionID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionNumber],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionStatus],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Username],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ConsultantName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([CoverMoreCSR],'NULL'))) + '"|"' +
    replace(ltrim(rtrim(isnull([TaxAmountSD],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([TaxOnAgentCommissionSD],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([TaxAmountGST],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([TaxOnAgentCommissionGST],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([QuotePrice],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([SellPrice],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([AgencyCommission],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([NetPrice],'NULL'))),',','') + '"|"' +
    ltrim(rtrim(isnull([BasePolicyCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AddonPolicyCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ExtensionPolicyCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TravellerCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AdultCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ChildCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ChargedAdultCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([LuggageCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([MedicalCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([MotorcycleCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([RentalCarCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([WintersportCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([EMCCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoCode],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoDiscount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([GoBelowNet],'NULL'))) + '"' as Data,
    IDKey as xDataIDx,
    convert(money,isnull(SellPrice,'0')) as PolicyPremiumGWP
from
    [db-au-workspace].dbo.RPT0728a_Transaction
where
    RowType = 'Policy'


--insert quote transaction record
insert [db-au-workspace].dbo.RPT0728a_Output
(
    data,
    xDataIDx,
    PolicyPremiumGWP
)
select
    '"' +
    ltrim(rtrim(isnull([RowType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([GroupName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([SubGroupName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AlphaCode],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([OutletName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([OutletType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Branch],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([State],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([SessionID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyNumber],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([IssueDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteTime],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([isSelected],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([isSaved],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteSaveDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyStatus],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([CancelledDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ProductCode],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ProductDisplayName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PlanName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AreaType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Area],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Destination],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TripStart],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TripEnd],'NULL'))) + '"|"' +
    replace(ltrim(rtrim(isnull([Excess],'NULL'))),',','') + '"|"' +
    ltrim(rtrim(isnull([DaysCovered],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TripType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([EmailConsent],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PolicyTransactionID],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionNumber],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionDate],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TransactionStatus],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([Username],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ConsultantName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([CoverMoreCSR],'NULL'))) + '"|"' +
    replace(ltrim(rtrim(isnull([TaxAmountSD],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([TaxOnAgentCommissionSD],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([TaxAmountGST],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([TaxOnAgentCommissionGST],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([QuotePrice],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([SellPrice],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([AgencyCommission],'NULL'))),',','') + '"|"' +
    replace(ltrim(rtrim(isnull([NetPrice],'NULL'))),',','') + '"|"' +
    ltrim(rtrim(isnull([BasePolicyCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([QuoteCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AddonPolicyCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ExtensionPolicyCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([TravellerCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([AdultCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ChildCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([ChargedAdultCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([LuggageCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([MedicalCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([MotorcycleCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([RentalCarCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([WintersportCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([EMCCount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoCode],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoName],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoType],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([PromoDiscount],'NULL'))) + '"|"' +
    ltrim(rtrim(isnull([GoBelowNet],'NULL'))) + '"' as Data,
    IDKey as xDataIDx,
    convert(money,isnull(QuotePrice,'0')) as PolicyPremiumGWP
from
    [db-au-workspace].dbo.RPT0728a_Transaction
where
    RowType = 'Quote'

declare @RecordCount int
select @RecordCount = count(*)
from [db-au-workspace].dbo.RPT0728a_Transaction
where RowType in ('Policy','Quote')

--insert eof transaction record
insert [db-au-workspace].dbo.RPT0728a_Output
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
insert [db-au-cmdwh].dbo.usrRPT0728a
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
    [db-au-workspace].dbo.RPT0728a_Output
order by ID


declare @SQL varchar(8000)

--export Transaction as pipe (|) delimited text file
select @sql = 'bcp "select Data from [db-au-workspace].dbo.RPT0728a_Output order by ID" queryout ' + @OutputPath + @FileName + ' -c -T -S ULDWH02'
exec master..xp_cmdshell @sql




GO
