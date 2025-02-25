USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL091_Penelope_Exception_Summary]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL091_Penelope_Exception_Summary]
as
begin

    if object_id('[db-au-dtc]..ectnExceptionSummary') is null
    begin

        create table [db-au-dtc]..ectnExceptionSummary
        (
            [BIRowID] bigint not null identity(1,1),
            [ExceptionDate] date,
            [State] nvarchar(20),
            [Manager] nvarchar(250),
            [Clinician] nvarchar(250),
            [Exception] varchar(50),
            [ResourceType] nvarchar(250),
            [Funder] nvarchar(250),
            [ServiceName] nvarchar(250),
            [SectionCode] nvarchar(50),
            [ExceptionCount] int,
            [ApprovedExceptionCount] int,
            [Team] nvarchar(250),
            UserID varchar(50)
        )

        create clustered index cidx on [db-au-dtc]..ectnExceptionSummary([BIRowID])
        create nonclustered index ncidx_date on [db-au-dtc]..ectnExceptionSummary([ExceptionDate],[Exception])

    end

    delete 
    from
        [db-au-dtc]..ectnExceptionSummary
    where
        ExceptionDate = convert(date, getdate())


    insert into [db-au-dtc]..ectnExceptionSummary
    (
        ExceptionDate,
        [State],
        Manager,
        UserID,
        Clinician, 
        Team,
        Exception, 
        ResourceType, 
        Funder,
        ServiceName,
        SectionCode,
        ExceptionCount,
        ApprovedExceptionCount
    )
    select 
        convert(date, getdate()) ExceptionDate,
        [State],
        Manager,
        UserID,
        Clinician,
        Team,
        Exception, 
        [Resource Type], 
        Funder,
        ServiceName,
        SectionCode,
        sum(1) ExceptionCount,
        sum
        (
            case
                when Comment like 'approve%' then 1
                --Included below 'No Action Required' into ApprovedExceptionCOunt, as request by Elena in JIRA REQ-977
                when Comment = 'No Action Required' then 1
                --20190529, LL, REQ-1320
                when Comment = '2018 no remediation' then 1
                else 0
            end
        ) ApprovedExceptionCount
    from
        [db-au-dtc]..vExceptionDetails with(nolock)
    where
        Exception in
        (
            'No Funder On Individual',
            'No Policy On Service File',
            'No Cart Item On Event',
            'Duplicate Cart Item On Event',
            'Event Time Not Equal To Cart Item Total',
            'Booked Event In The Past',
            'Cart Item Hours More Than 10',
            'Cart items over service standard',
            'Service Events Not Covered',
            'No Presenting Issue',
            'CSO Document Not Completed',
            'No First Session Document',
            'No Agreement Document On First EA Event',
            'No Employee Assist Associate Data Form',
            'No Presenting Issue - managerAssist',
            'Travel Clinician without Travel Customer'
        )
    group by
        [State],
        Manager,
        UserID,
        Clinician,
        Team,
        Exception, 
        [Resource Type], 
        Funder,
        ServiceName,
        SectionCode

    update x
    set
        x.UserID = u.UserID
    from
        [db-au-dtc]..ectnExceptionSummary x
        cross apply
        (
            select top 1
                u.UserID
            from
                [db-au-dtc]..pnpUser u
            where
                rtrim(u.FirstName) <> '' and
                (
                    x.Clinician like (u.FirstName + '%' + u.LastName + '%' + u.ResourceType + '%') or
                    (u.FirstName + ' ' + u.LastName) = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(x.Clinician, 'psy_c ', ''), ' psy c ', ' '), 'sw_c ', ''), 'psy_s ', ''), 'sw_s ', ''), ' psy s ', ' '), 'PsyDO NOT USE ', ''), 'DONT USE ', ''), 'DO NOT USE', ''), 'Diet_C ', ''), '  ', ' ')
                ) and
                u.UserID not like 'CLI%'
        ) u
    where
        x.UserID is null

end
GO
