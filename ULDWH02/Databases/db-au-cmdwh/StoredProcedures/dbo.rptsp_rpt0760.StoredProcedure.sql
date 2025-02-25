USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0760]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rptsp_rpt0760]
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0760
--  Author:         Linus Tor
--  Date Created:   20160407
--  Description:    This stored procedure outputs traveller data files for Experian POC project.
--                    The stored proc will be called from Crystal Reports (RPT0760) and output the following files
--
--                    1. tbl_People_Address_YYYYMMDDHHMMSS
--                    2. tbl_Transaction_Attributes_YYYYMMDDHHMMSS
--
--                    The files will then be compressed in zip format
--
--  Parameters:        @DateRange:        Required. Standard date range or _User Defined
--                    @StartDate:        Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--                    @EndDate:        Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--
--  Change History: 20160407 - LT - Created
--                    20160602 - LT - Changed selection criteria to: all policy transactions issued from 01/07/2015 and Departure date is after Current Date
--                                    Added Planning Period calculation:
--                                        Issue Date and Departure Date in:
--                                            < 1 week (0 to 6 days from Issue Date)
--                                            1 - 2 weeks (7 to 13 days from Issue Date)
--                                            2 -  3  weeks (14 to 20 days from Issue Date)
--                                            3 -  4  weeks (21 to 27 days from Issue Date)
--                                            4 -  8 weeks (28 to 55 days from Issue Date)
--                                            8 - 12  weeks (56 to 83 days from Issue Date)
--                                            > 12 weeks (84 days + from Issue Date)
--
/****************************************************************************************************/


declare @CurrentDate varchar(10)
declare @Filename varchar(200)
declare @OutputPath varchar(200)
declare @FormatDate varchar(8)
declare @FormatTime varchar(6)
declare @SFTPFolderLocation varchar(255)

select @CurrentDate = convert(varchar(10),getdate(),120)

--build filename format
select @FormatDate = convert(varchar(20),getdate(),112)
select @FormatTime = replace(convert(varchar(8),getdate(),108),':','')
select @Filename = 'tbl_traveller_data_' + @FormatDate + @FormatTime
select @OutputPath = 'e:\temp\'
select @SFTPFolderLocation = '\\ulwibs01.aust.dmz.local\SFTPShares\Experian\Process\'

if object_id('[db-au-workspace].dbo.rpt0760_traveller') is not null drop table [db-au-workspace].dbo.rpt0760_traveller
select
    o.SuperGroupName as SuperGroup,
    convert(varchar(10),p.IssueDate,103) as IssueDate,
    p.PolicyNumber,
    p.PrimaryCountry as PrimaryDestination,
    convert(varchar(10),p.TripStart,120) as DepartureDate,
    convert(varchar(10),p.TripEnd,120) as ReturnDate,
    convert(varchar,pt.isPrimary) as isPrimary,
    pt.Title,
    pt.FirstName,
    pt.LastName,
    convert(varchar(10),pt.DOB,103) as DOB,
    pt.AddressLine1,
    pt.AddressLine2,
    pt.Postcode,
    pt.Suburb,
    pt.[State],
    pt.Country,
    pt.WorkPhone,
    pt.MobilePhone,
    pt.EmailAddress,
    prod.PlanType,
    prod.ProductClassification,
    convert(varchar,case when pt.isPrimary = 1 then 1 else 0 end) as PrimaryTravellerCount,
    convert(varchar,case when pt.isPrimary = 0 then 1 else 0 end) as NonPrimaryTravellerCount,
    case when py.CardType = '' or py.CardType = ' ' or py.CardType is null then 'Account' else py.CardType end PaymentType,
    case when datediff(day,p.IssueDate,p.TripStart) between 0 and 6 then '< week'
         when datediff(day,p.IssueDate,p.TripStart) between 7 and 13 then '1-2 weeks'
         when datediff(day,p.IssueDate,p.TripStart) between 14 and 20 then '2-3 weeks'
         when datediff(day,p.IssueDate,p.TripStart) between 21 and 27 then '3-4 weeks'
         when datediff(day,p.IssueDate,p.TripStart) between 28 and 55 then '4-8 weeks'
         when datediff(day,p.IssueDate,p.TripStart) between 56 and 83 then '8-12 weeks'
         when datediff(day,p.IssueDate,p.TripStart) >= 84 then '> 12 weeks +'
         else ''
    end as PlanningPeriod
into [db-au-workspace].dbo.rpt0760_traveller
from
    [db-au-cmdwh].dbo.penPolicy p
    join [db-au-star].dbo.dimOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.isLatest = 'Y'
    join [db-au-cmdwh].dbo.penPolicyTraveller pt on p.PolicyKey = pt.PolicyKey
    outer apply
    (
        select top 1 pr.PlanType, pr.ProductClassification
        from
            [db-au-star].dbo.factPolicyTransaction fpt
            inner join [db-au-star].dbo.dimPolicy pol on fpt.PolicySK = pol.PolicySK
            inner join [db-au-star].dbo.dimProduct pr on fpt.ProductSK = pr.ProductSK
        where
            pol.PolicyKey = p.PolicyKey
    ) prod
    outer apply
    (
        select top 1
            case when pay.MerchantID = 'Paypal' then 'Paypal'
                 else pay.CardType
            end as CardType
        from
            penPolicyTransSummary pts
            left join penPayment pay on pts.PolicyTransactionKey = pay.PolicyTransactionKey
        where
            pts.PolicyKey = p.PolicyKey
    ) py
where
    o.Country = 'AU' and
    o.SuperGroupName in ('Cover-More Phonesales','Cover-More Websales') and
    o.isLatest = 'Y' and
    p.PolicyKey in (select distinct pts.PolicyKey
                    from
                        penPolicyTransSummary pts
                        inner join [db-au-star].dbo.dimOutlet o on pts.OutletAlphaKey = o.OutletAlphaKey and o.isLatest = 'Y'
                    where
                        pts.CountryKey = 'AU' and
                        o.SuperGroupName in ('Cover-More Phonesales','Cover-More Websales') and
                        pts.TransactionType = 'Base' and
                        pts.TransactionStatus = 'Active' and
                        pts.PostingDate >= '2015-07-01' and
                        pts.PostingDate <= @CurrentDate
                   ) and
    p.TripStart >= @CurrentDate



--build data output
if object_id('[db-au-workspace].dbo.RPT0760_Output') is null
begin
    create table [db-au-workspace].dbo.RPT0760_Output
    (
        data varchar(8000) null
    )
end
else
    truncate table [db-au-workspace].dbo.RPT0760_Output



--insert header label
insert [db-au-workspace].dbo.RPT0760_Output
(
    data
)
select
    'SuperGroup|IssueDate|PolicyNumber|PrimaryDestination|DepartureDate|ReturnDate|isPrimary|Title|FirstName|LastName|DOB|AddressLine1|AddressLine2|Postcode|Suburb|State|Country|WorkPhone|MobilePhone|EmailAddress|PlanType|ProductClassification|PrimaryTravellerCount|NonPrimaryTravellerCount|PaymentType|PlanningPeriod'

--insert data
insert [db-au-workspace].dbo.RPT0760_Output
(
    data
)
select
    isnull([SuperGroup],'') + '|' +
    isnull([IssueDate],'') + '|' +
    isnull([PolicyNumber],'') + '|' +
    isnull([PrimaryDestination],'') + '|' +
    isnull([DepartureDate],'') + '|' +
    isnull([ReturnDate],'') + '|' +
    isnull([isPrimary],'') + '|' +
    isnull([Title],'') + '|' +
    isnull([FirstName],'') + '|' +
    isnull([LastName],'') + '|' +
    isnull([DOB],'') + '|' +
    isnull([AddressLine1],'') + '|' +
    isnull([AddressLine2],'') + '|' +
    isnull([Postcode],'') + '|' +
    isnull([Suburb],'') + '|' +
    isnull([State],'') + '|' +
    isnull([Country],'') + '|' +
    isnull([WorkPhone],'') + '|' +
    isnull([MobilePhone],'') + '|' +
    isnull([EmailAddress],'') + '|' +
    isnull([PlanType],'') + '|' +
    isnull([ProductClassification],'') + '|' +
    isnull([PrimaryTravellerCount],'') + '|' +
    isnull([NonPrimaryTravellerCount],'') + '|' +
    isnull([PaymentType],'') + '|' +
    isnull([PlanningPeriod],'')
from
    [db-au-workspace].dbo.rpt0760_traveller


--export to data to file
declare @sql varchar(8000)

select @sql = 'bcp "select * from [db-au-workspace].dbo.RPT0760_Output" queryout ' + @OutputPath + @Filename + ' -c -T -S ULDWH02'
exec master..xp_cmdshell @sql

--compress data file
select @sql = '7z a ' + @OutputPath + @Filename + '.zip' + ' ' + @OutputPath + @Filename
exec master..xp_cmdshell @sql

--move file to SFTP folder location
select @sql = 'move ' + @OutputPath + @Filename + '.zip' + ' ' + @SFTPFolderLocation + @FileName + '.zip'
exec master..xp_cmdshell @sql

--delete temp file on e:\temp
select @sql = 'del ' + @OutputPath + @Filename
exec master..xp_cmdshell @sql

select 'hello world' as Data
GO
