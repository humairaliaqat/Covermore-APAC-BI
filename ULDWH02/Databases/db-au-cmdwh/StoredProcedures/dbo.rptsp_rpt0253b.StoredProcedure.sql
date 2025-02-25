USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0253b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0253b]
    @ReportingPeriod varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)

as
begin
/****************************************************************************************************/
--    Name:            dbo.rptsp_rpt0253b
--    Author:            Linus Tor
--    Date Created:    20111122
--    Description:    This stored procedure retrieves DocGen failed COI/PDS generation and failed sent emails
--                    server/database.
--    Parameters:        @Country: 1 or more values of AU, NZ, MY, SG or UK. Separated by comma. No Spaces
--                    @EmailStatus: Failed, Success, All
--                    @ReportingPeriod: standard date range or _User Defined
--                    @StartDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--                    @EndDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--
--    Change History:    20111122 - LT - Created
--                  20140922 - LS - change deliverystatus check (when COI & PDS failed this status will be null)
--                                  add additional condition, check log comment for blank attachment list
--                                  add COIAttached field
--                  20140923 - LS - move date conversion to BI side (access issue)
--                  20140924 - LS - docgen's time is local (IKR), remove date conversion
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select
    @ReportingPeriod = 'Month-To-Date',
    @StartDate = null,
    @EndDate = null
*/

    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime
    declare @SQL nvarchar(max)
    declare @docgen table
    (
        ID int,
        PolicyNumber nvarchar(50),
        AlphaCode nvarchar(30),
        DocumentType nvarchar(100),
        CreateDateTime datetime,
        [Status] varchar(15),
        DeliveryStatus varchar(50),
        COIAttached varchar(15),
        Recipient nvarchar(max)
    )

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


    set @SQL =
        '
        select *
        from
            openquery(
                [db-au-penguinsharp.aust.covermore.com.au],
                ''
                select
                    d.ID,
                    p.PolicyNumber,
                    p.AlphaCode,
                    dt.[Name] as DocumentType,
                    d.CreateDateTime,
                    d.[Status],
                    l.DeliveryStatus,
                    case
                        when l.Comment like ''''%<AttachmentList>%COI%</AttachmentList>%'''' then ''''Yes''''
                        else ''''No''''
                    end COIAttached,
                    replace(Xcomment.value(''''(/EmailAudit/To)[1]'''',''''nvarchar(255)''''), '''' ;'''', '''''''') Recipient
                from
                    [au_docgen].dbo.Document d
                    join [au_docgen].dbo.DocumentType dt on
                        d.DocumentTypeID = dt.ID
                    join [AU_TIP_PenguinSharp_Active].dbo.[tblPolicy] p on
                        d.ObjectID = p.PolicyID
                    left join [au_docgen].dbo.[Log] l on
                        d.ID = l.ObjectID
                    outer apply
                    (
                        select
                            cast(l.Comment as xml) XComment
                    ) lx
                where
                    (
                        d.[Status] = ''''Error'''' OR
                        isnull(l.DeliveryStatus, '''''''') <> ''''EMAILSENT'''' OR
                        l.Comment not like ''''%<AttachmentList>%COI%</AttachmentList>%''''
                    ) and
                    dt.ID in (123,124,125) and
                    d.CreateDateTime >= ''''' + convert(varchar(10),@rptStartDate,120) + ''''' and
                    d.CreateDateTime <  dateadd(day, 1, ''''' + convert(varchar(10),@rptEndDate,120) + ''''')
                ''
            ) a
        '

    insert into @docgen
    exec(@SQL)

    /*
    if object_id('tempdb..##docgenUK') is not null drop table ##docgenUK

    select @SQL = 'select * into ##docgenUK from openquery(AZEUSQL01, ''
    select    d.ID, p.PolicyNumber, p.AlphaCode, dt.[Name] as DocumentType, d.CreateDateTime,
    d.[Status],    l.DeliveryStatus
    from [UK_docgen].dbo.Document d
    join [UK_docgen].dbo.DocumentType dt on d.DocumentTypeID = dt.ID
    left join [UK_docgen].dbo.[Log] l on d.ID = l.ObjectID
    join [UK_PenguinSharp_Active].dbo.[tblPolicy] p on d.ObjectID = p.PolicyID
    where (d.[Status] = ''''Error'''' OR l.DeliveryStatus = ''''EMAILFAILEDSENT'''') and
    dt.ID in (123,124,125) and
    convert(varchar(10),d.CreateDateTime,120) between ''''' + convert(varchar(10),dateadd(d,-2,@rptStartDate),120) + ''''' and ''''' + convert(varchar(10),@rptEndDate,120) + '''''
    '') a'

    exec(@SQL)
    */

    select
        'AU/NZ/MY/SG' as Country,
        a.ID,
        a.PolicyNumber,
        a.AlphaCode,
        a.DocumentType,
        a.CreateDateTime,
        a.[Status],
        isnull(a.DeliveryStatus, 'EMAILFAILEDSENT') DeliveryStatus,
        a.COIAttached,
        a.Recipient
    from
        @docgen a

    /*
    union all

    select
    'UK' as Country,
    a.ID,
    a.PolicyNumber,
    a.AlphaCode,
    a.DocumentType,
    a.CreateDateTime,
    a.[Status],
    a.DeliveryStatus
    from ##docgenUK a
    */

end
GO
