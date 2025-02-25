USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0253]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0253]    
    @Country varchar(100),
    @EmailStatus varchar(20),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
    
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0253
--  Author:         Linus Tor
--  Date Created:   20111122
--  Description:    This stored procedure retrieves penguin failed emails list from ulsql03 penguin
--                  server/database.
--  Parameters:     @Country: 1 or more values of AU, NZ, MY, SG or UK. Separated by comma. No Spaces
--                  @EmailStatus: Failed, Success, All
--                  @ReportingPeriod: standard date range or _User Defined
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--                  
--  Change History: 
--                  20111122 - LT - Created
--                  20140922 - LS - critical bug fix, include failed email with COI *and* PDS generated
--                  20140923 - LS - exclude policies with successful (on all 3 conditions) email
--                  20141008 - LS - refactoring
--					20150828 - LT - T18917 - bug fix, changes were made to tblEmailAudit XML column where
--									sequencing of XML Elements were not identical to the regular penguin mailer.
--                  20170609 - LL - INC0032121, exclude policy (base) issued prior to 01/06/2017
--																		
/****************************************************************************************************/

--uncomment to debug
/*
declare 
    @Country varchar(100),
    @EmailStatus varchar(20),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
select    
    @Country = 'AU,NZ,SG,MY,CN,ID', 
    @EmailStatus = 'All', 
    @ReportingPeriod = 'Yesterday', 
    @StartDate = null, 
    @EndDate = null
*/

    set nocount on

    declare 
        @rptStartDate smalldatetime,
        @rptEndDate smalldatetime,
        @WhereEmailStatus varchar(100),
        @SQL varchar(8000)

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = convert(smalldatetime,@StartDate), 
            @rptEndDate = convert(smalldatetime,@EndDate)
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    if object_id('tempdb..#Country') is not null 
        drop table #Country
        
    create table #Country (Country varchar(10) null)

    if @Country = 'All' or @Country = '' or @Country is null
    begin
    
        insert #Country
        select distinct 
            CountryKey
        from 
            penDomain
        
    end
    else
    begin
    
        insert #Country
        select 
            Item
        from 
            dbo.fn_DelimitedSplit8K(replace(@Country,' ',''), ',')
        
    end

    if object_id('tempdb..#EmailStatus') is not null 
        drop table #EmailStatus
        
    create table #EmailStatus (Status bit null)

    if @EmailStatus = 'All' or @EmailStatus = '' or @EmailStatus is null
    begin
    
        insert #EmailStatus values(1)
        insert #EmailStatus values(0)
        
    end    
    else if @EmailStatus = 'Failed'
        insert #EmailStatus values(0)    
        
    else if @EmailStatus = 'Success'
        insert #EmailStatus values(1)
                                        
    if object_id('tempdb..#rpt0253') is not null 
        drop table #rpt0253

    select
		tp.CountryKey as Country, 
		tp.CompanyKey as Company, 
		o.AlphaCode as AlphaCode,
		tp.PolicyNumber,
		convert(varchar(250),tea.Recipients) as Recipients,
		tea.SentDate,
		case 
			when tea.Status = 0 then 'Failed'
			when tea.Status = 1 then 'Success'
		end as Status,
		case when tea.ExtraData.value('(/Hashtable//Item/Key//text())[1]', 'VARCHAR(500)') = 'COI Attached' then tea.ExtraData.value('(/Hashtable//Item/Value//text())[1]', 'VARCHAR(500)') 
			when tea.ExtraData.value('(/Hashtable//Item/Key//text())[2]', 'VARCHAR(500)') = 'COI Attached' then tea.ExtraData.value('(/Hashtable//Item/Value//text())[2]', 'VARCHAR(500)')
			when tea.ExtraData.value('(/Hashtable//Item/Key//text())[3]', 'VARCHAR(500)') = 'COI Attached' then tea.ExtraData.value('(/Hashtable//Item/Value//text())[3]', 'VARCHAR(500)')
			else 'Unknown'
		end as isCOIAttached,
		case when tea.ExtraData.value('(/Hashtable//Item/Key//text())[1]', 'VARCHAR(500)') = 'PDS Attached' then tea.ExtraData.value('(/Hashtable//Item/Value//text())[1]', 'VARCHAR(500)') 
			when tea.ExtraData.value('(/Hashtable//Item/Key//text())[2]', 'VARCHAR(500)') = 'PDS Attached' then tea.ExtraData.value('(/Hashtable//Item/Value//text())[2]', 'VARCHAR(500)')
			when tea.ExtraData.value('(/Hashtable//Item/Key//text())[3]', 'VARCHAR(500)') = 'PDS Attached' then tea.ExtraData.value('(/Hashtable//Item/Value//text())[3]', 'VARCHAR(500)')
			else 'Unknown'
		end as isPDSAttached,
        tp.IssueDate
    into #rpt0253    
    from 
        penEmailAudit tea 
        inner join penPolicy tp on 
            tea.CountryKey = tp.CountryKey and 
            tea.CompanyKey = tp.CompanyKey and
            tea.AuditReference=tp.PolicyNumber
        inner join penOutlet o on
            tp.OutletAlphaKey = o.OutletAlphaKey and
            o.OutletStatus = 'Current'
    where
        tea.CountryKey in (select Country from #Country) and
        tea.Status in (select Status from #EmailStatus) and
        convert(varchar(10),tea.SentDate,120) between convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120) 
    order by
        tea.SentDate


    if (select count(*) from #rpt0253 where isCOIAttached = 'No' or isPDSAttached = 'No') = 0
        select 
            convert(varchar(2),null) as Country,
            convert(varchar(5),null) as Company,
            convert(varchar(20),null) as AlphaCode,
            convert(bigint,null) as PolicyNumber, 
            convert(varchar(200),null) as Recipients, 
            convert(datetime,null) as SentDate, 
            convert(varchar(10),null) as Status, 
            convert(varchar(10),null) as isCOIAttached,
            convert(varchar(10),null) as isPDSAttached,
            @rptStartDate as rptStartDate, 
            @rptEndDate as rptEndDate
            
    else        
        select
            a.*,
            @rptStartDate as rptStartDate,
            @rptEndDate as rptEndDate
        from
            #rpt0253 a    
        where
            (
                a.isCOIAttached = 'No' or
                (
                    a.IssueDate >= '2017-06-01' and
                    a.isPDSAttached = 'No' 
                ) or
                a.[Status] = 'Failed'
            ) and
            not exists
            (
                select null
                from
                    #rpt0253 b
                where
                    b.PolicyNumber = a.PolicyNumber and
                    b.[Status] = 'Success' and
                    b.isCOIAttached = 'Yes' and
                    b.isPDSAttached = 'Yes' and
                    convert(date, a.SentDate) = convert(date, b.SentDate)
            )


    drop table #rpt0253
    drop table #EmailStatus
    drop table #Country

end
GO
