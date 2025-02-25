USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0385a_takaful_resend]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0385a_takaful_resend]    
    @DateRange varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null

as
begin

                             
/****************************************************************************************************/
--  Name:          rptsp_rpt0385a_takaful_resend - MY Takaful Policy Extract
--  Author:        Surya Bathula
--  Date Created:  202401011
--  Description:   This stored procedure extract malaysia takaful policy data for given parameters
--  Parameters:    @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20180201 - LT - Created. INC0054893 - Takaful policies.
--                  20180930 - LT - INC0127929 - Updated product mapping
--                  20190920 - LL - REQ-2285 - update product mapping, incorrect mapping translation on INC0127929
--                                  moved product mapping to usrMYMAProductMapping populated through etlsp_ETL095_MalaysiaAirlinesMapping
--                                    
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select @DateRange = '_User Defined',@StartDate = '2018-01-01', @EndDate = '2018-01-31'
*/

    set nocount on

    declare 
        @dataStartDate date,
        @dataEndDate date,
        @LastFolderName nvarchar(100),
        @constTitle varchar(8) = 'SIR/MDM '

    --declare variables for outputting text file
    declare 
        @SQL varchar(8000),
        @OutputPath varchar(200),
        @FileName varchar(13),
        @ProfileName varchar(50),
        @Recipients varchar(1000),
        @CC varchar(200),
        @Subject varchar(200),
        @FileAttachments varchar(200),
        @Body varchar(1000)

    /* initialise dates and file output details */
    if @DateRange = '_User Defined'
        select 
            @dataStartDate = @StartDate, 
            @dataEndDate = @EndDate

    else
        select 
            @dataStartDate = StartDate, 
            @dataEndDate = EndDate
        from 
            [db-au-cmdwh].dbo.vDateRange
        where 
            DateRange = @DateRange
    
    /* set output path and filename */                                                
    set @OutputPath = 'E:\ETL\Surya\MAST\'
    set @FileName = 'MAST' + convert(varchar(8),getdate(),12)


    /* 1. get all new policykeys from dataStartDate to dataEndDate            */
    if object_id('[db-au-workspace].dbo.tmp_rpt0385a_TravellersCount') is not null 
        drop table [db-au-workspace].dbo.tmp_rpt0385a_TravellersCount

    select
        pts.PolicyKey,
        pts.PolicyNoKey,  
        pts.IssueDate,  
        pts.PostingDate,
        sum(pts.TravellersCount) as TravellersCount
    into [db-au-workspace].dbo.tmp_rpt0385a_TravellersCount    
    from
        penPolicyTransSummary pts
        join penOutlet o on pts.OutletSKey = o.OutletSKey
    where
        pts.CountryKey = 'MY' and
        o.GroupCode = 'MA' and
        o.AlphaCode in ('MAJ0010','MAJ0011','MAJ0012','MAJ0013','MAJ0009','MAK0003','MAK0004')    and            --takaful outlets
        (    
            pts.PostingDate between @dataStartDate and @dataEndDate 
            OR
            (
                pts.PostingDate >= '2018-09-01' and            ---start of takaful sftp policy extract
                pts.PostingDate < @dataStartDate and
                not exists
                (
                    select null
                    from 
                        [dbo].[usrRPT0385a]
                    where 
                        xDataIDx = pts.PolicyTransactionKey and 
                        xFailx = 0
                )
            ) 
        )
		and  
  pts.PolicyNumber in (
'923100032741',
'923100033093',
'923100033643',
'923100033418',
'923100034577',
'923100035076',
'922100083426',
'923100035180',
'923100036265',
'923100036520',
'923100036520',
'923100037671',
'923100037753',
'923100037671',
'923100037753',
'923100038009',
'923100040124',
'923100040978',
'923100042158',
'923100042575',
'923100044329',
'923100045095',
'923100044837',
'923100045130',
'923100045225',
'923100027268',
'923100027979',
'923100025592',
'923100025178',
'923100029221',
'923100031397',
'923100027268',
'923100027979',
'923100025592',
'923100025178',
'923100029221',
'923100031397'
)
    group by
        pts.PolicyKey,
        pts.PolicyNoKey,
        pts.IssueDate,
        pts.PostingDate



    /* 2. select and build the policy extraction data and file */
    --get travellers
    if object_id('[db-au-workspace].dbo.tmp_rpt0385a_pivot') is not null 
        drop table [db-au-workspace].dbo.tmp_rpt0385a_pivot

    select
        row_number() over(partition by a.PolicyKey order by a.isPrimary desc) as Row,
        a.*
    into [db-au-workspace].dbo.tmp_rpt0385a_pivot    
    from
    (    
        select distinct
            ptr.PolicyKey,
            p.IssueDate, 
            ptr.isPrimary, 
            ptr.EmailAddress, 
            ptr.AddressLine1, 
            ptr.AddressLine2, 
            ptr.Suburb, 
            ptr.PostCode, 
            ptr.[State], 
            ptr.[Country], 
            ptr.HomePhone, 
            ptr.WorkPhone, 
            ptr.MobilePhone, 
            ptr.Title, 
            ptr.FirstName,
            ptr.LastName, 
            ptr.DOB
        from
            penPolicy p
            inner join penPolicyTraveller ptr on p.PolicyKey = ptr.PolicyKey        
        where
            ptr.PolicyKey in (select PolicyKey from [db-au-workspace].dbo.tmp_rpt0385a_TravellersCount)
    ) a

    --transpose travellers to columns
    if object_id('[db-au-workspace].dbo.tmp_rpt0385a_travellers') is not null 
        drop table [db-au-workspace].dbo.tmp_rpt0385a_travellers

    select 
        PolicyKey,
        max(case when [Row] = 1 then convert(char(8),@constTitle) else space(8) end) as Title01,
        max(case when [Row] = 1 then convert(char(30),FirstName) else space(30) end) as FirstName01,
        max(case when [Row] = 1 then convert(char(20),LastName) else space(20) end) as LastName01,
        max(case when [Row] = 1 then 
                    convert(char(10),case when DOB is null then 
                                                convert(datetime,'1900-01-01')
                                          when datediff(year,DOB,IssueDate) < 1 then 
                                                convert(datetime,'1900-01-01') 
                                          else    DOB
                                     end,103) 
                 else space(10) 
        end) as DOB01,
        convert(char(20),space(20)) as SecondName01,
        max(case when [Row] = 1 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID01,
        max(case when [Row] = 1 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID01,
        convert(char(15),space(15)) as LocalName01,
        max(case when [Row] = 2 then convert(char(8),@constTitle) else space(8) end) as Title02,
        max(case when [Row] = 2 then convert(char(30),FirstName) else space(30) end) as FirstName02,
        max(case when [Row] = 2 then convert(char(20),LastName) else space(20) end) as LastName02,
        max(case when [Row] = 2 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB02,
        convert(char(20),space(20)) as SecondName02,
        max(case when [Row] = 2 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID02,
        max(case when [Row] = 2 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID02,
        convert(char(15),space(15)) as LocalName02,
        max(case when [Row] = 3 then convert(char(8),@constTitle) else space(8) end) as Title03,
        max(case when [Row] = 3 then convert(char(30),FirstName) else space(30) end) as FirstName03,
        max(case when [Row] = 3 then convert(char(20),LastName) else space(20) end) as LastName03,
        max(case when [Row] = 3 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB03,
        convert(char(20),space(20)) as SecondName03,
        max(case when [Row] = 3 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID03,
        max(case when [Row] = 3 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID03,
        convert(char(15),space(15)) as LocalName03,
        max(case when [Row] = 4 then convert(char(8),@constTitle) else space(8) end) as Title04,
        max(case when [Row] = 4 then convert(char(30),FirstName) else space(30) end) as FirstName04,
        max(case when [Row] = 4 then convert(char(20),LastName) else space(20) end) as LastName04,
        max(case when [Row] = 4 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB04,
        convert(char(20),space(20)) as SecondName04,
        max(case when [Row] = 4 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID04,
        max(case when [Row] = 4 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID04,
        convert(char(15),space(15)) as LocalName04,
        max(case when [Row] = 5 then convert(char(8),@constTitle) else space(8) end) as Title05,
        max(case when [Row] = 5 then convert(char(30),FirstName) else space(30) end) as FirstName05,
        max(case when [Row] = 5 then convert(char(20),LastName) else space(20) end) as LastName05,
        max(case when [Row] = 5 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB05,
        convert(char(20),space(20)) as SecondName05,
        max(case when [Row] = 5 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID05,
        max(case when [Row] = 5 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID05,
        convert(char(15),space(15)) as LocalName05,
        max(case when [Row] = 6 then convert(char(8),@constTitle) else space(8) end) as Title06,
        max(case when [Row] = 6 then convert(char(30),FirstName) else space(30) end) as FirstName06,
        max(case when [Row] = 6 then convert(char(20),LastName) else space(20) end) as LastName06,
        max(case when [Row] = 6 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB06,
        convert(char(20),space(20)) as SecondName06,
        max(case when [Row] = 6 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID06,
        max(case when [Row] = 6 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID06,
        convert(char(15),space(15)) as LocalName06,
        max(case when [Row] = 7 then convert(char(8),@constTitle) else space(8) end) as Title07,
        max(case when [Row] = 7 then convert(char(30),FirstName) else space(30) end) as FirstName07,
        max(case when [Row] = 7 then convert(char(20),LastName) else space(20) end) as LastName07,
        max(case when [Row] = 7 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB07,
        convert(char(20),space(20)) as SecondName07,
        max(case when [Row] = 7 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID07,
        max(case when [Row] = 7 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID07,
        convert(char(15),space(15)) as LocalName07,
        max(case when [Row] = 8 then convert(char(8),@constTitle) else space(8) end) as Title08,
        max(case when [Row] = 8 then convert(char(30),FirstName) else space(30) end) as FirstName08,
        max(case when [Row] = 8 then convert(char(20),LastName) else space(20) end) as LastName08,
        max(case when [Row] = 8 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB08,
        convert(char(20),space(20)) as SecondName08,
        max(case when [Row] = 8 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID08,
        max(case when [Row] = 8 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID08,
        convert(char(15),space(15)) as LocalName08,
        max(case when [Row] = 9 then convert(char(8),@constTitle) else space(8) end) as Title09,
        max(case when [Row] = 9 then convert(char(30),FirstName) else space(30) end) as FirstName09,
        max(case when [Row] = 9 then convert(char(20),LastName) else space(20) end) as LastName09,
        max(case when [Row] = 9 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB09,
        convert(char(20),space(20)) as SecondName09,
        max(case when [Row] = 9 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID09,
        max(case when [Row] = 9 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID09,
        convert(char(15),space(15)) as LocalName09,
        max(case when [Row] = 10 then convert(char(8),@constTitle) else space(8) end) as Title10,
        max(case when [Row] = 10 then convert(char(30),FirstName) else space(30) end) as FirstName10,
        max(case when [Row] = 10 then convert(char(20),LastName) else space(20) end) as LastName10,
        max(case when [Row] = 10 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB10,
        convert(char(20),space(20)) as SecondName10,
        max(case when [Row] = 10 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID10,
        max(case when [Row] = 10 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID10,
        convert(char(15),space(15)) as LocalName10,
        max(case when [Row] = 11 then convert(char(8),@constTitle) else space(8) end) as Title11,
        max(case when [Row] = 11 then convert(char(30),FirstName) else space(30) end) as FirstName11,
        max(case when [Row] = 11 then convert(char(20),LastName) else space(20) end) as LastName11,
        max(case when [Row] = 11 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB11,
        convert(char(20),space(20)) as SecondName11,
        max(case when [Row] = 11 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID11,
        max(case when [Row] = 11 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID11,
        convert(char(15),space(15)) as LocalName11,
        max(case when [Row] = 12 then convert(char(8),@constTitle) else space(8) end) as Title12,
        max(case when [Row] = 12 then convert(char(30),FirstName) else space(30) end) as FirstName12,
        max(case when [Row] = 12 then convert(char(20),LastName) else space(20) end) as LastName12,
        max(case when [Row] = 12 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB12,
        convert(char(20),space(20)) as SecondName12,
        max(case when [Row] = 12 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID12,
        max(case when [Row] = 12 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID12,
        convert(char(15),space(15)) as LocalName12,
        max(case when [Row] = 13 then convert(char(8),@constTitle) else space(8) end) as Title13,
        max(case when [Row] = 13 then convert(char(30),FirstName) else space(30) end) as FirstName13,
        max(case when [Row] = 13 then convert(char(20),LastName) else space(20) end) as LastName13,
        max(case when [Row] = 13 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB13,
        convert(char(20),space(20)) as SecondName13,
        max(case when [Row] = 13 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID13,
        max(case when [Row] = 13 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID13,
        convert(char(15),space(15)) as LocalName13,
        max(case when [Row] = 14 then convert(char(8),@constTitle) else space(8) end) as Title14,
        max(case when [Row] = 14 then convert(char(30),FirstName) else space(30) end) as FirstName14,
        max(case when [Row] = 14 then convert(char(20),LastName) else space(20) end) as LastName14,
        max(case when [Row] = 14 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB14,
        convert(char(20),space(20)) as SecondName14,
        max(case when [Row] = 14 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID14,
        max(case when [Row] = 14 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID14,
        convert(char(15),space(15)) as LocalName14,
        max(case when [Row] = 15 then convert(char(8),@constTitle) else space(8) end) as Title15,
        max(case when [Row] = 15 then convert(char(30),FirstName) else space(30) end) as FirstName15,
        max(case when [Row] = 15 then convert(char(20),LastName) else space(20) end) as LastName15,
        max(case when [Row] = 15 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB15,
        convert(char(20),space(20)) as SecondName15,
        max(case when [Row] = 15 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID15,
        max(case when [Row] = 15 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID15,
        convert(char(15),space(15)) as LocalName15,
        max(case when [Row] = 16 then convert(char(8),@constTitle) else space(8) end) as Title16,
        max(case when [Row] = 16 then convert(char(30),FirstName) else space(30) end) as FirstName16,
        max(case when [Row] = 16 then convert(char(20),LastName) else space(20) end) as LastName16,
        max(case when [Row] = 16 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB16,
        convert(char(20),space(20)) as SecondName16,
        max(case when [Row] = 16 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID16,
        max(case when [Row] = 16 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID16,
        convert(char(15),space(15)) as LocalName16,
        max(case when [Row] = 17 then convert(char(8),@constTitle) else space(8) end) as Title17,
        max(case when [Row] = 17 then convert(char(30),FirstName) else space(30) end) as FirstName17,
        max(case when [Row] = 17 then convert(char(20),LastName) else space(20) end) as LastName17,
        max(case when [Row] = 17 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB17,
        convert(char(20),space(20)) as SecondName17,
        max(case when [Row] = 17 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID17,
        max(case when [Row] = 17 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID17,
        convert(char(15),space(15)) as LocalName17,
        max(case when [Row] = 18 then convert(char(8),@constTitle) else space(8) end) as Title18,
        max(case when [Row] = 18 then convert(char(30),FirstName) else space(30) end) as FirstName18,
        max(case when [Row] = 18 then convert(char(20),LastName) else space(20) end) as LastName18,
        max(case when [Row] = 18 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB18,
        convert(char(20),space(20)) as SecondName18,
        max(case when [Row] = 18 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID18,
        max(case when [Row] = 18 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID18,
        convert(char(15),space(15)) as LocalName18,
        max(case when [Row] = 19 then convert(char(8),@constTitle) else space(8) end) as Title19,
        max(case when [Row] = 19 then convert(char(30),FirstName) else space(30) end) as FirstName19,
        max(case when [Row] = 19 then convert(char(20),LastName) else space(20) end) as LastName19,
        max(case when [Row] = 19 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB19,
        convert(char(20),space(20)) as SecondName19,
        max(case when [Row] = 19 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID19,
        max(case when [Row] = 19 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID19,
        convert(char(15),space(15)) as LocalName19,
        max(case when [Row] = 20 then convert(char(8),@constTitle) else space(8) end) as Title20,
        max(case when [Row] = 20 then convert(char(30),FirstName) else space(30) end) as FirstName20,
        max(case when [Row] = 20 then convert(char(20),LastName) else space(20) end) as LastName20,
        max(case when [Row] = 20 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB20,
        convert(char(20),space(20)) as SecondName20,
        max(case when [Row] = 20 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID20,
        max(case when [Row] = 20 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID20,
        convert(char(15),space(15)) as LocalName20,
        max(case when [Row] = 21 then convert(char(8),@constTitle) else space(8) end) as Title21,
        max(case when [Row] = 21 then convert(char(30),FirstName) else space(30) end) as FirstName21,
        max(case when [Row] = 21 then convert(char(20),LastName) else space(20) end) as LastName21,
        max(case when [Row] = 21 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB21,
        convert(char(20),space(20)) as SecondName21,
        max(case when [Row] = 21 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID21,
        max(case when [Row] = 21 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID21,
        convert(char(15),space(15)) as LocalName21,
        max(case when [Row] = 22 then convert(char(8),@constTitle) else space(8) end) as Title22,
        max(case when [Row] = 22 then convert(char(30),FirstName) else space(30) end) as FirstName22,
        max(case when [Row] = 22 then convert(char(20),LastName) else space(20) end) as LastName22,
        max(case when [Row] = 22 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB22,
        convert(char(20),space(20)) as SecondName22,
        max(case when [Row] = 22 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID22,
        max(case when [Row] = 22 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID22,
        convert(char(15),space(15)) as LocalName22,
        max(case when [Row] = 23 then convert(char(8),@constTitle) else space(8) end) as Title23,
        max(case when [Row] = 23 then convert(char(30),FirstName) else space(30) end) as FirstName23,
        max(case when [Row] = 23 then convert(char(20),LastName) else space(20) end) as LastName23,
        max(case when [Row] = 23 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB23,
        convert(char(20),space(20)) as SecondName23,
        max(case when [Row] = 23 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID23,
        max(case when [Row] = 23 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID23,
        convert(char(15),space(15)) as LocalName23,
        max(case when [Row] = 24 then convert(char(8),@constTitle) else space(8) end) as Title24,
        max(case when [Row] = 24 then convert(char(30),FirstName) else space(30) end) as FirstName24,
        max(case when [Row] = 24 then convert(char(20),LastName) else space(20) end) as LastName24,
        max(case when [Row] = 24 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB24,
        convert(char(20),space(20)) as SecondName24,
        max(case when [Row] = 24 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID24,
        max(case when [Row] = 24 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID24,
        convert(char(15),space(15)) as LocalName24,                                                                                                
        max(case when [Row] = 25 then convert(char(8),@constTitle) else space(8) end) as Title25,
        max(case when [Row] = 25 then convert(char(30),FirstName) else space(30) end) as FirstName25,
        max(case when [Row] = 25 then convert(char(20),LastName) else space(20) end) as LastName25,
        max(case when [Row] = 25 then convert(char(10),isnull(DOB,convert(datetime,'1900-01-01')),103) else space(10) end) as DOB25,
        convert(char(20),space(20)) as SecondName25,
        max(case when [Row] = 25 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as CardID25,
        max(case when [Row] = 25 then convert(char(15),convert(varchar(8),isnull(DOB,convert(datetime,'1900-01-01')),112)+'-'+left(replace(FirstName,'.',''),6)) else space(15) end) as SocialID25,
        convert(char(15),space(15)) as LocalName25    
    into [db-au-workspace].dbo.tmp_rpt0385a_travellers    
    from [db-au-workspace].dbo.tmp_rpt0385a_pivot
    group by
        PolicyKey
    order by PolicyKey    




    --main data extract
    if object_id('[db-au-workspace].dbo.tmp_rpt0385a_main') is not null 
        drop table [db-au-workspace].dbo.tmp_rpt0385a_main

    select
        pts.PolicyTransactionKey,
        @Filename as DATA_FILENAME,
        convert(varchar(10),getdate(),120) as DATA_DATE,
        pts.PostingDate as POSTING_DATE,
        @dataEndDate as DATA_ENDDATE,
        convert(char(2),case when pts.TransactionType = 'Base' and pts.TransactionStatus = 'Active' then 'NB'
                             when pts.TransactionType <> 'Base' and pts.TransactionStatus = 'Active' then 'AM'
                             when pts.TransactionStatus like 'Cancelled%' then 'CX'
                             else space(2)
        end) as TRANSACTION_TYPE,                                                                            --seq001
        convert(char(10),pts.PostingDate,111) as IS_FN2_LOADED_DATE,                                        --seq002
        convert(char(10),pts.IssueDate,111) as TRANSACTION_DATE,                                            --seq003
        str(convert(char(5),abs(isnull(pts.TaxAmountSD,0.00))),5,2) as STAMP,                                --seq004
        str(convert(char(11),abs(isnull(pts.GrossPremium,0) - isnull(pts.TaxAmountSD,0))),11,2) as GWP,        --seq005
        convert(char(3),'MAS') as [PARTNER],                                                        --seq006
        convert(char(20),isnull(ltrim(rtrim(isnull(u.FirstName,''))) + ' ' + ltrim(rtrim(isnull(u.LastName,''))),space(20))) as SALES_PERSON,        --seq007
        convert(char(2),pts.CountryKey) as BU_CODE,                                                    --seq008
        convert(char(2),case when isnull(o.SalesSegment,'') = 'White Label' then 'WL'                    
                             when isnull(o.SalesSegment,'') = 'Integrated' then 'IN'
                             when isnull(o.SalesSegment,'') = 'Call Centre' then 'CC'
                             else 'OT'
        end) as SALES_TYPE_ORIGIN,                                                                        --seq009
        convert
        (
            char(25),
            case 
                when p.CountryKey = 'MY' and p.AreaType = 'International' and p.TripType = 'Annual Multi Trip' and p.TripCost = '$Unlimited' then 'MHMYW07'
                else
                    isnull
                    (
                        (
                            select top 1 
                                m.ProductCode
                            from
                                dbo.usrMYMAProductMapping m
                            where
                                m.Domain = p.CountryKey and
                                m.AreaType = p.AreaType and
                                m.TripType = p.TripType and
                                m.PlanName = p.PlanName
                            order by
                                m.BIRowID desc
                        ),
                        ''
                    )
            end + 
            case 
                when pts.CountryKey = 'MY' and pts.TransactionType = 'Base' then '0' + convert(varchar,isnull(pts.PolicyNumber,0))
                else convert(varchar,isnull(pts.PolicyNumber,0))
            end
        ) as CUSTOMER_CONTRACT_NUMBER,
        convert(char(10),pts.IssueTime,103) as POLICY_ISSUE_DATE,                                    --seq011
        convert
        (
            char(10),
            case 
                when p.CountryKey = 'MY' and p.AreaType = 'International' and p.TripType = 'Annual Multi Trip' and p.TripCost = '$Unlimited' then 'MHMYW07'
                else
                    isnull
                    (
                        (
                            select top 1 
                                m.ProductCode
                            from
                                dbo.usrMYMAProductMapping m
                            where
                                m.Domain = p.CountryKey and
                                m.AreaType = p.AreaType and
                                m.TripType = p.TripType and
                                m.PlanName = p.PlanName
                            order by
                                m.BIRowID desc
                        ),
                        ''
                    )
            end
        ) as PRODUCT_ID,
        str(convert(char(11),abs(isnull(pts.GrossPremium,0.00))),11,2) as BASE_PREMIUM,                                --seq013
        convert(char(3),isnull(pts.CurrencyCode,space(3))) as CURRENCY_CODE,                                --seq014
        convert(char(10),p.TripStart,103) as TRAVEL_START_DATE,                                        --seq015
        convert(char(10),p.TripEnd,103) as TRAVEL_END_DATE,                                            --seq016
        convert(char(2),pts.CountryKey) as TRAVEL_ORIGIN_COUNTRY,                                    --seq017    
        convert(char(2),space(2)) as TRAVEL_ORIGIN_COUNTY,                                                --seq018
        convert(char(2),space(2)) as TRAVEL_ORIGIN_AIRPORT,                                                --seq019
        (select top 1 c.ISO2CODE from dbo.penCountry c where c.CountryName = p.PrimaryCountry) as TRAVEL_DESTINATION_COUNTRY,            --seq020
        convert(char(2),space(2)) as TRAVEL_DESTINATION_COUNTY,                                            --seq021
        convert(char(2),space(2)) as TRAVEL_DESTINATION_AIRPORT,                                        --seq022
        str(convert(char(11),case when isnumeric(p.TripCost)=1 then p.TripCost else 0.00 end),11,2) as TOTAL_TRAVEL_PRICE,                                            --seq023
        convert(char(10),p.PolicyStart,103) as POLICY_START_COVER,                                    --seq024
        convert(char(10),p.PolicyEnd,103) as POLICY_END_COVER,                                        --seq025
        convert(char(50),isnull(pt.EmailAddress,space(50))) as HOLDER_EMAIL,
        convert(char(90),case when (pt.AddressLine1 is null or pt.AddressLine1 = null or pt.AddressLine1 = '') then 'NA                            NA                                                          '
                              when len(pt.AddressLine1 + ' ' + pt.AddressLine2) > 90 then left(pt.AddressLine1 + ' ' + pt.AddressLine2,90)
                              else pt.AddressLine1 + ' ' + pt.AddressLine2
        end) as HOLDER_ADD_LINE1,
        convert(char(30),case when (pt.AddressLine2 is null or pt.AddressLine2 = null or pt.AddressLine2 = '') then 'NA                            '
                              when len(pt.AddressLine1 + ' ' + pt.AddressLine2) > 90 then substring(pt.AddressLine1 + ' ' + pt.AddressLine2,91,29)    
                              else 'NA                            '
        end) as HOLDER_ADD_LINE2,
        convert(char(30),case when len(pt.AddressLine1 + ' ' + pt.AddressLine2) > 120 then substring(pt.AddressLine1 + ' ' + pt.AddressLine2,121,150)
                              else 'NA                            '
        end) as HOLDER_ADD_LINE3,
        convert(char(10),isnull(pt.PostCode,'99999')) as HOLDER_ZIP,
        convert(char(30),isnull(pt.Suburb,'NA')) as HOLDER_TOWN,
        convert(char(15),isnull(pt.[State],'NA')) as HOLDER_STATE,
        convert(char(15),isnull(pt.Country,'NA')) as HOLDER_COUNTRY,
        convert(char(16),isnull(pt.HomePhone,space(16))) as HOLDER_HOME_PHONE,
        convert(char(16),isnull(pt.WorkPhone,space(16))) as HOLDER_OFFICE_PHONE,
        convert(char(16),isnull(pt.MobilePhone,space(16))) as HOLDER_MOBILE_PHONE,
        convert(char(10),space(10)) as Filler01,
        convert(char(10),space(10)) as Filler02,
        convert(char(10),space(10)) as Filler03,
        convert(char(10),space(10)) as Filler04,
        convert(char(10),space(10)) as Filler05,
        convert(char(10),space(10)) as Filler06,
        convert(char(10),space(10)) as Filler07,
        convert(char(10),space(10)) as Filler08,
        convert(char(10),space(10)) as Filler09,
        convert(char(10),space(10)) as Filler10,
        convert(char(10),space(10)) as Filler11,
        convert(char(10),space(10)) as Filler12,
        convert(char(10),space(10)) as Filler13,
        str(convert(char(10),isnull(pts.PolicyTransactionID,0)),10,0) as TRANSACTION_ID,
        convert(char(11),case when len(convert(varchar,pts.PolicyNumber)) in (12,13) then    
                case when left(convert(varchar,pts.PolicyNumber),1) = '9' then substring(convert(varchar,pts.PolicyNumber),2,len(convert(varchar,pts.PolicyNumber))-1)
                     when left(convert(varchar,pts.PolicyNumber),1) = '1' then substring(convert(varchar,pts.PolicyNumber),3,len(convert(varchar,pts.PolicyNumber))-2)
                    else convert(varchar,isnull(pts.PolicyNumber,0))
                end
            else convert(varchar,isnull(pts.PolicyNumber,0))
        end) as POLICY_PARTNER_REFERENCE,
        str(convert(char(4),abs(isnull(tc.TravellersCount,0))),4,0) as NUMBER_TRAVELLER,    
        t.Title01 as X1_PAX_TITLE,
        t.FirstName01 as X1_PAX_FIRSTNAME,
        t.LastName01 as X1_PAX_LASTNAME,
        t.DOB01 as X1_PAX_DOB,
        t.SecondName01 as X1_PAX_SECONDNAME,
        t.CardID01 as X1_PAX_CARDID,
        t.SocialID01 as X1_PAX_SOCIALID, 
        t.LocalName01 as X1_PAX_LOCALNAME,
        t.Title02 as X2_PAX_TITLE,
        t.FirstName02 as X2_PAX_FIRSTNAME,
        t.LastName02 as X2_PAX_LASTNAME,
        t.DOB02 as X2_PAX_DOB,
        t.SecondName02 as X2_PAX_SECONDNAME,
        t.CardID02 as X2_PAX_CARDID,
        t.SocialID02 as X2_PAX_SOCIALID, 
        t.LocalName02 as X2_PAX_LOCALNAME,
        t.Title03 as X3_PAX_TITLE,
        t.FirstName03 as X3_PAX_FIRSTNAME,
        t.LastName03 as X3_PAX_LASTNAME,
        t.DOB03 as X3_PAX_DOB,
        t.SecondName03 as X3_PAX_SECONDNAME,
        t.CardID03 as X3_PAX_CARDID,
        t.SocialID03 as X3_PAX_SOCIALID, 
        t.LocalName03 as X3_PAX_LOCALNAME,
        t.Title04 as X4_PAX_TITLE,
        t.FirstName04 as X4_PAX_FIRSTNAME,
        t.LastName04 as X4_PAX_LASTNAME,
        t.DOB04 as X4_PAX_DOB,
        t.SecondName04 as X4_PAX_SECONDNAME,
        t.CardID04 as X4_PAX_CARDID,
        t.SocialID04 as X4_PAX_SOCIALID, 
        t.LocalName04 as X4_PAX_LOCALNAME,
        t.Title05 as X5_PAX_TITLE,
        t.FirstName05 as X5_PAX_FIRSTNAME,
        t.LastName05 as X5_PAX_LASTNAME,
        t.DOB05 as X5_PAX_DOB,
        t.SecondName05 as X5_PAX_SECONDNAME,
        t.CardID05 as X5_PAX_CARDID,
        t.SocialID05 as X5_PAX_SOCIALID, 
        t.LocalName05 as X5_PAX_LOCALNAME,
        t.Title06 as X6_PAX_TITLE,
        t.FirstName06 as X6_PAX_FIRSTNAME,
        t.LastName06 as X6_PAX_LASTNAME,
        t.DOB06 as X6_PAX_DOB,
        t.SecondName06 as X6_PAX_SECONDNAME,
        t.CardID06 as X6_PAX_CARDID,
        t.SocialID06 as X6_PAX_SOCIALID, 
        t.LocalName06 as X6_PAX_LOCALNAME,
        t.Title07 as X7_PAX_TITLE,
        t.FirstName07 as X7_PAX_FIRSTNAME,
        t.LastName07 as X7_PAX_LASTNAME,
        t.DOB07 as X7_PAX_DOB,
        t.SecondName07 as X7_PAX_SECONDNAME,
        t.CardID07 as X7_PAX_CARDID,
        t.SocialID07 as X7_PAX_SOCIALID, 
        t.LocalName07 as X7_PAX_LOCALNAME,
        t.Title08 as X8_PAX_TITLE,
        t.FirstName08 as X8_PAX_FIRSTNAME,
        t.LastName08 as X8_PAX_LASTNAME,
        t.DOB08 as X8_PAX_DOB,
        t.SecondName08 as X8_PAX_SECONDNAME,
        t.CardID08 as X8_PAX_CARDID,
        t.SocialID08 as X8_PAX_SOCIALID, 
        t.LocalName08 as X8_PAX_LOCALNAME,
        t.Title09 as X9_PAX_TITLE,
        t.FirstName09 as X9_PAX_FIRSTNAME,
        t.LastName09 as X9_PAX_LASTNAME,
        t.DOB09 as X9_PAX_DOB,
        t.SecondName09 as X9_PAX_SECONDNAME,
        t.CardID09 as X9_PAX_CARDID,
        t.SocialID09 as X9_PAX_SOCIALID, 
        t.LocalName09 as X9_PAX_LOCALNAME,
        t.Title10 as X10_PAX_TITLE,
        t.FirstName10 as X10_PAX_FIRSTNAME,
        t.LastName10 as X10_PAX_LASTNAME,
        t.DOB10 as X10_PAX_DOB,
        t.SecondName10 as X10_PAX_SECONDNAME,
        t.CardID10 as X10_PAX_CARDID,
        t.SocialID10 as X10_PAX_SOCIALID, 
        t.LocalName10 as X10_PAX_LOCALNAME,
        t.Title11 as X11_PAX_TITLE,
        t.FirstName11 as X11_PAX_FIRSTNAME,
        t.LastName11 as X11_PAX_LASTNAME,
        t.DOB11 as X11_PAX_DOB,
        t.SecondName11 as X11_PAX_SECONDNAME,
        t.CardID11 as X11_PAX_CARDID,
        t.SocialID11 as X11_PAX_SOCIALID, 
        t.LocalName11 as X11_PAX_LOCALNAME,
        t.Title12 as X12_PAX_TITLE,
        t.FirstName12 as X12_PAX_FIRSTNAME,
        t.LastName12 as X12_PAX_LASTNAME,
        t.DOB12 as X12_PAX_DOB,
        t.SecondName12 as X12_PAX_SECONDNAME,
        t.CardID12 as X12_PAX_CARDID,
        t.SocialID12 as X12_PAX_SOCIALID, 
        t.LocalName12 as X12_PAX_LOCALNAME,
        t.Title13 as X13_PAX_TITLE,
        t.FirstName13 as X13_PAX_FIRSTNAME,
        t.LastName13 as X13_PAX_LASTNAME,
        t.DOB13 as X13_PAX_DOB,
        t.SecondName13 as X13_PAX_SECONDNAME,
        t.CardID13 as X13_PAX_CARDID,
        t.SocialID13 as X13_PAX_SOCIALID, 
        t.LocalName13 as X13_PAX_LOCALNAME,
        t.Title14 as X14_PAX_TITLE,
        t.FirstName14 as X14_PAX_FIRSTNAME,
        t.LastName14 as X14_PAX_LASTNAME,
        t.DOB14 as X14_PAX_DOB,
        t.SecondName14 as X14_PAX_SECONDNAME,
        t.CardID14 as X14_PAX_CARDID,
        t.SocialID14 as X14_PAX_SOCIALID, 
        t.LocalName14 as X14_PAX_LOCALNAME,
        t.Title15 as X15_PAX_TITLE,
        t.FirstName15 as X15_PAX_FIRSTNAME,
        t.LastName15 as X15_PAX_LASTNAME,
        t.DOB15 as X15_PAX_DOB,
        t.SecondName15 as X15_PAX_SECONDNAME,
        t.CardID15 as X15_PAX_CARDID,
        t.SocialID15 as X15_PAX_SOCIALID, 
        t.LocalName15 as X15_PAX_LOCALNAME,    
        t.Title16 as X16_PAX_TITLE,
        t.FirstName16 as X16_PAX_FIRSTNAME,
        t.LastName16 as X16_PAX_LASTNAME,
        t.DOB16 as X16_PAX_DOB,
        t.SecondName16 as X16_PAX_SECONDNAME,
        t.CardID16 as X16_PAX_CARDID,
        t.SocialID16 as X16_PAX_SOCIALID, 
        t.LocalName16 as X16_PAX_LOCALNAME,
        t.Title17 as X17_PAX_TITLE,
        t.FirstName17 as X17_PAX_FIRSTNAME,
        t.LastName17 as X17_PAX_LASTNAME,
        t.DOB17 as X17_PAX_DOB,
        t.SecondName17 as X17_PAX_SECONDNAME,
        t.CardID17 as X17_PAX_CARDID,
        t.SocialID17 as X17_PAX_SOCIALID, 
        t.LocalName17 as X17_PAX_LOCALNAME,
        t.Title18 as X18_PAX_TITLE,
        t.FirstName18 as X18_PAX_FIRSTNAME,
        t.LastName18 as X18_PAX_LASTNAME,
        t.DOB18 as X18_PAX_DOB,
        t.SecondName18 as X18_PAX_SECONDNAME,
        t.CardID18 as X18_PAX_CARDID,
        t.SocialID18 as X18_PAX_SOCIALID, 
        t.LocalName18 as X18_PAX_LOCALNAME,
        t.Title19 as X19_PAX_TITLE,
        t.FirstName19 as X19_PAX_FIRSTNAME,
        t.LastName19 as X19_PAX_LASTNAME,
        t.DOB19 as X19_PAX_DOB,
        t.SecondName19 as X19_PAX_SECONDNAME,
        t.CardID19 as X19_PAX_CARDID,
        t.SocialID19 as X19_PAX_SOCIALID, 
        t.LocalName19 as X19_PAX_LOCALNAME,
        t.Title20 as X20_PAX_TITLE,
        t.FirstName20 as X20_PAX_FIRSTNAME,
        t.LastName20 as X20_PAX_LASTNAME,
        t.DOB20 as X20_PAX_DOB,
        t.SecondName20 as X20_PAX_SECONDNAME,
        t.CardID20 as X20_PAX_CARDID,
        t.SocialID20 as X20_PAX_SOCIALID, 
        t.LocalName20 as X20_PAX_LOCALNAME,
        t.Title21 as X21_PAX_TITLE,
        t.FirstName21 as X21_PAX_FIRSTNAME,
        t.LastName21 as X21_PAX_LASTNAME,
        t.DOB21 as X21_PAX_DOB,
        t.SecondName21 as X21_PAX_SECONDNAME,
        t.CardID21 as X21_PAX_CARDID,
        t.SocialID21 as X21_PAX_SOCIALID, 
        t.LocalName21 as X21_PAX_LOCALNAME,
        t.Title22 as X22_PAX_TITLE,
        t.FirstName22 as X22_PAX_FIRSTNAME,
        t.LastName22 as X22_PAX_LASTNAME,
        t.DOB22 as X22_PAX_DOB,
        t.SecondName22 as X22_PAX_SECONDNAME,
        t.CardID22 as X22_PAX_CARDID,
        t.SocialID22 as X22_PAX_SOCIALID, 
        t.LocalName22 as X22_PAX_LOCALNAME,
        t.Title23 as X23_PAX_TITLE,
        t.FirstName23 as X23_PAX_FIRSTNAME,
        t.LastName23 as X23_PAX_LASTNAME,
        t.DOB23 as X23_PAX_DOB,
        t.SecondName23 as X23_PAX_SECONDNAME,
        t.CardID23 as X23_PAX_CARDID,
        t.SocialID23 as X23_PAX_SOCIALID, 
        t.LocalName23 as X23_PAX_LOCALNAME,
        t.Title24 as X24_PAX_TITLE,
        t.FirstName24 as X24_PAX_FIRSTNAME,
        t.LastName24 as X24_PAX_LASTNAME,
        t.DOB24 as X24_PAX_DOB,
        t.SecondName24 as X24_PAX_SECONDNAME,
        t.CardID24 as X24_PAX_CARDID,
        t.SocialID24 as X24_PAX_SOCIALID, 
        t.LocalName24 as X24_PAX_LOCALNAME,
        t.Title25 as X25_PAX_TITLE,
        t.FirstName25 as X25_PAX_FIRSTNAME,
        t.LastName25 as X25_PAX_LASTNAME,
        t.DOB25 as X25_PAX_DOB,
        t.SecondName25 as X25_PAX_SECONDNAME,
        t.CardID25 as X25_PAX_CARDID,
        t.SocialID25 as X25_PAX_SOCIALID, 
        t.LocalName25 as X25_PAX_LOCALNAME,
        convert(char(20),isnull(p.TaxInvoiceNumber,space(20))) as TAXINVNO,    
        str(convert(char(11),abs(isnull(pts.TaxAmountGST,0.00))),11,2) TAXAMOUNT
    into [db-au-workspace].dbo.tmp_rpt0385a_main
    from
        dbo.penPolicyTransSummary pts
        left join dbo.penUser u on pts.UserSKey = u.UserSKey
        join dbo.penOutlet o on    pts.OutletSKey = o.OutletSKey
        join dbo.penPolicy p on pts.PolicyKey = p.PolicyKey
        join dbo.penPolicyTraveller pt on pts.PolicyKey = pt.PolicyKey and pt.isPrimary = 1
        join [db-au-workspace].dbo.tmp_rpt0385a_travellers t on pts.PolicyKey = t.PolicyKey
        join [db-au-workspace].dbo.tmp_rpt0385a_TravellersCount tc on pts.PolicyNoKey = tc.PolicyNoKey
    where
        pts.PolicyKey in (select PolicyKey from [db-au-workspace].dbo.tmp_rpt0385a_TravellersCount)
    order by
        BU_CODE,    
        POLICY_ISSUE_DATE,
        TRANSACTION_ID,
        CUSTOMER_CONTRACT_NUMBER


    --build data output
    if object_id('[db-au-workspace].dbo.tmp_rpt0385a') is not null drop table [db-au-workspace].dbo.tmp_rpt0385a
    select
        TRANSACTION_TYPE +
        IS_FN2_LOADED_DATE +
        TRANSACTION_DATE +
        STAMP +
        GWP +
        [PARTNER] +
        SALES_PERSON +
        BU_CODE +
        SALES_TYPE_ORIGIN +
        CUSTOMER_CONTRACT_NUMBER +
        POLICY_ISSUE_DATE +
        PRODUCT_ID +
        BASE_PREMIUM +
        CURRENCY_CODE +
        TRAVEL_START_DATE +
        TRAVEL_END_DATE +
        TRAVEL_ORIGIN_COUNTRY +
        TRAVEL_ORIGIN_COUNTY +
        TRAVEL_ORIGIN_AIRPORT +
        convert(char(2),isnull(TRAVEL_DESTINATION_COUNTRY,space(2))) +
        TRAVEL_DESTINATION_COUNTY +
        TRAVEL_DESTINATION_AIRPORT +
        TOTAL_TRAVEL_PRICE +
        POLICY_START_COVER +
        POLICY_END_COVER +
        HOLDER_EMAIL +
        HOLDER_ADD_LINE1 +
        HOLDER_ADD_LINE2 +
        HOLDER_ADD_LINE3 +
        HOLDER_ZIP +
        HOLDER_TOWN +
        HOLDER_STATE +
        HOLDER_COUNTRY +
        HOLDER_HOME_PHONE +
        HOLDER_OFFICE_PHONE +
        HOLDER_MOBILE_PHONE +
        Filler01 +
        Filler02 +
        Filler03 +
        Filler04 +
        Filler05 +
        Filler06 +
        Filler07 +
        Filler08 +
        Filler09 +
        Filler10 +
        Filler11 +
        Filler12 +
        Filler13 +
        TRANSACTION_ID +
        POLICY_PARTNER_REFERENCE +
        NUMBER_TRAVELLER +
        X1_PAX_TITLE +
        X1_PAX_FIRSTNAME +
        X1_PAX_LASTNAME +
        X1_PAX_DOB +
        X1_PAX_SECONDNAME +
        X1_PAX_CARDID +
        X1_PAX_SOCIALID + 
        X1_PAX_LOCALNAME +
        X2_PAX_TITLE +
        X2_PAX_FIRSTNAME +
        X2_PAX_LASTNAME +
        X2_PAX_DOB +
        X2_PAX_SECONDNAME +
        X2_PAX_CARDID +
        X2_PAX_SOCIALID + 
        X2_PAX_LOCALNAME +
        X3_PAX_TITLE +
        X3_PAX_FIRSTNAME +
        X3_PAX_LASTNAME +
        X3_PAX_DOB +
        X3_PAX_SECONDNAME +
        X3_PAX_CARDID +
        X3_PAX_SOCIALID + 
        X3_PAX_LOCALNAME +
        X4_PAX_TITLE +
        X4_PAX_FIRSTNAME +
        X4_PAX_LASTNAME +
        X4_PAX_DOB +
        X4_PAX_SECONDNAME +
        X4_PAX_CARDID +
        X4_PAX_SOCIALID + 
        X4_PAX_LOCALNAME +
        X5_PAX_TITLE +
        X5_PAX_FIRSTNAME +
        X5_PAX_LASTNAME +
        X5_PAX_DOB +
        X5_PAX_SECONDNAME +
        X5_PAX_CARDID +
        X5_PAX_SOCIALID + 
        X5_PAX_LOCALNAME +
        X6_PAX_TITLE +
        X6_PAX_FIRSTNAME +
        X6_PAX_LASTNAME +
        X6_PAX_DOB +
        X6_PAX_SECONDNAME +
        X6_PAX_CARDID +
        X6_PAX_SOCIALID + 
        X6_PAX_LOCALNAME +
        X7_PAX_TITLE +
        X7_PAX_FIRSTNAME +
        X7_PAX_LASTNAME +
        X7_PAX_DOB +
        X7_PAX_SECONDNAME +
        X7_PAX_CARDID +
        X7_PAX_SOCIALID + 
        X7_PAX_LOCALNAME +
        X8_PAX_TITLE +
        X8_PAX_FIRSTNAME +
        X8_PAX_LASTNAME +
        X8_PAX_DOB +
        X8_PAX_SECONDNAME +
        X8_PAX_CARDID +
        X8_PAX_SOCIALID + 
        X8_PAX_LOCALNAME +
        X9_PAX_TITLE +
        X9_PAX_FIRSTNAME +
        X9_PAX_LASTNAME +
        X9_PAX_DOB +
        X9_PAX_SECONDNAME +
        X9_PAX_CARDID +
        X9_PAX_SOCIALID + 
        X9_PAX_LOCALNAME +
        X10_PAX_TITLE +
        X10_PAX_FIRSTNAME +
        X10_PAX_LASTNAME +
        X10_PAX_DOB +
        X10_PAX_SECONDNAME +
        X10_PAX_CARDID +
        X10_PAX_SOCIALID + 
        X10_PAX_LOCALNAME +
        X11_PAX_TITLE +
        X11_PAX_FIRSTNAME +
        X11_PAX_LASTNAME +
        X11_PAX_DOB +
        X11_PAX_SECONDNAME +
        X11_PAX_CARDID +
        X11_PAX_SOCIALID + 
        X11_PAX_LOCALNAME +
        X12_PAX_TITLE +
        X12_PAX_FIRSTNAME +
        X12_PAX_LASTNAME +
        X12_PAX_DOB +
        X12_PAX_SECONDNAME +
        X12_PAX_CARDID +
        X12_PAX_SOCIALID + 
        X12_PAX_LOCALNAME +
        X13_PAX_TITLE +
        X13_PAX_FIRSTNAME +
        X13_PAX_LASTNAME +
        X13_PAX_DOB +
        X13_PAX_SECONDNAME +
        X13_PAX_CARDID +
        X13_PAX_SOCIALID + 
        X13_PAX_LOCALNAME +
        X14_PAX_TITLE +
        X14_PAX_FIRSTNAME +
        X14_PAX_LASTNAME +
        X14_PAX_DOB +
        X14_PAX_SECONDNAME +
        X14_PAX_CARDID +
        X14_PAX_SOCIALID + 
        X14_PAX_LOCALNAME +
        X15_PAX_TITLE +
        X15_PAX_FIRSTNAME +
        X15_PAX_LASTNAME +
        X15_PAX_DOB +
        X15_PAX_SECONDNAME +
        X15_PAX_CARDID +
        X15_PAX_SOCIALID + 
        X15_PAX_LOCALNAME +    
        X16_PAX_TITLE +
        X16_PAX_FIRSTNAME +
        X16_PAX_LASTNAME +
        X16_PAX_DOB +
        X16_PAX_SECONDNAME +
        X16_PAX_CARDID +
        X16_PAX_SOCIALID + 
        X16_PAX_LOCALNAME +
        X17_PAX_TITLE +
        X17_PAX_FIRSTNAME +
        X17_PAX_LASTNAME +
        X17_PAX_DOB +
        X17_PAX_SECONDNAME +
        X17_PAX_CARDID +
        X17_PAX_SOCIALID + 
        X17_PAX_LOCALNAME +
        X18_PAX_TITLE +
        X18_PAX_FIRSTNAME +
        X18_PAX_LASTNAME +
        X18_PAX_DOB +
        X18_PAX_SECONDNAME +
        X18_PAX_CARDID +
        X18_PAX_SOCIALID + 
        X18_PAX_LOCALNAME +
        X19_PAX_TITLE +
        X19_PAX_FIRSTNAME +
        X19_PAX_LASTNAME +
        X19_PAX_DOB +
        X19_PAX_SECONDNAME +
        X19_PAX_CARDID +
        X19_PAX_SOCIALID + 
        X19_PAX_LOCALNAME +
        X20_PAX_TITLE +
        X20_PAX_FIRSTNAME +
        X20_PAX_LASTNAME +
        X20_PAX_DOB +
        X20_PAX_SECONDNAME +
        X20_PAX_CARDID +
        X20_PAX_SOCIALID + 
        X20_PAX_LOCALNAME +
        X21_PAX_TITLE +
        X21_PAX_FIRSTNAME +
        X21_PAX_LASTNAME +
        X21_PAX_DOB +
        X21_PAX_SECONDNAME +
        X21_PAX_CARDID +
        X21_PAX_SOCIALID + 
        X21_PAX_LOCALNAME +
        X22_PAX_TITLE +
        X22_PAX_FIRSTNAME +
        X22_PAX_LASTNAME +
        X22_PAX_DOB +
        X22_PAX_SECONDNAME +
        X22_PAX_CARDID +
        X22_PAX_SOCIALID + 
        X22_PAX_LOCALNAME +
        X23_PAX_TITLE +
        X23_PAX_FIRSTNAME +
        X23_PAX_LASTNAME +
        X23_PAX_DOB +
        X23_PAX_SECONDNAME +
        X23_PAX_CARDID +
        X23_PAX_SOCIALID + 
        X23_PAX_LOCALNAME +
        X24_PAX_TITLE +
        X24_PAX_FIRSTNAME +
        X24_PAX_LASTNAME +
        X24_PAX_DOB +
        X24_PAX_SECONDNAME +
        X24_PAX_CARDID +
        X24_PAX_SOCIALID + 
        X24_PAX_LOCALNAME +
        X25_PAX_TITLE +
        X25_PAX_FIRSTNAME +
        X25_PAX_LASTNAME +
        X25_PAX_DOB +
        X25_PAX_SECONDNAME +
        X25_PAX_CARDID +
        X25_PAX_SOCIALID + 
        X25_PAX_LOCALNAME +
        TAXINVNO +
        TAXAMOUNT as Data,
        PolicyTransactionKey,
        GWP
    into [db-au-workspace].dbo.tmp_rpt0385a        
    from [db-au-workspace].dbo.tmp_rpt0385a_main  
	
	--export data to files
	declare @SQL1 varchar(8000)

	--output control file
	select @SQL1 = 'bcp "select Data from [db-au-workspace].dbo.tmp_RPT0385a" queryout "'+ @OutputPath + @FileName + '" -c -t -T -S ULDWH02'
	execute master.dbo.xp_cmdshell @SQL1

    --return output
    select 
        Data,
        @filename xOutputFileNamex,
        PolicyTransactionKey xDataIDx,
        GWP xDataValuex
    from
        [db-au-workspace].dbo.tmp_rpt0385a
    


    --truncate tables because this stored proc is called via OpenRowSet
    --if these tables are dropped, OpenRowSet will complain
    truncate table [db-au-workspace].dbo.tmp_rpt0385a_TravellersCount
    truncate table [db-au-workspace].dbo.tmp_rpt0385a_pivot
    truncate table [db-au-workspace].dbo.tmp_rpt0385a_travellers
    truncate table [db-au-workspace].dbo.tmp_rpt0385a_main
    truncate table [db-au-workspace].dbo.tmp_rpt0385a

end

GO
