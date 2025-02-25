USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [opsupport].[rptsp_EnterpriseSearch_preparetables]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [opsupport].[rptsp_EnterpriseSearch_preparetables]
as
begin

    if object_id('[db-au-workspace].[opsupport].[ev_customer]') is null
    begin

        create table [db-au-workspace].[opsupport].[ev_customer]
        (
            [BIRowID] bigint not null identity(1,1),
            [CustomerID] bigint not null,
            [MergedTo] bigint null,
            [CreateDate] datetime null,
            [UpdateDate] datetime null,
            [Status] nvarchar(10) null,
            [CustomerName] nvarchar(255) null,
            [CustomerRole] nvarchar(50) null,
            [Title] nvarchar(20) null,
            [FirstName] nvarchar(100) null,
            [MidName] nvarchar(100) null,
            [LastName] nvarchar(100) null,
            [Gender] nvarchar(7) null,
            [MaritalStatus] nvarchar(15) null,
            [DOB] date not null,
            [isDeceased] bit null,
            [CurrentAddress] nvarchar(614) null,
            [CurrentEmail] nvarchar(255) null,
            [CurrentContact] nvarchar(25) null,
            [SortID] int null,
            [PrimaryScore] int null,
            [SecondaryScore] int null,
            [RiskCategory] varchar(29) not null,
            [ForceFlag] int not null,
            [BlockFlag] int not null,
            [Alias] nvarchar(4000) null,
            [Comment] varchar(max),
            [isEmployee] bit default 0 
        )

        create unique clustered index cidx on [db-au-workspace].[opsupport].[ev_customer]([BIRowID])
        create nonclustered index idx on [db-au-workspace].[opsupport].[ev_customer]([CustomerID])
    
    end

    if object_id('[db-au-workspace].[opsupport].[ev_contact]') is null
    begin

        create table [db-au-workspace].[opsupport].[ev_contact]
        (
            [BIRowID] bigint not null identity(1,1),
            [CustomerID] bigint not null,
            [ContactType] varchar(10) not null,
            [ContactValue] nvarchar(614) null,
            [MinDate] date null,
            [MaxDate] date null
        )

        create unique clustered index cidx on [db-au-workspace].[opsupport].[ev_contact]([BIRowID])
        create nonclustered index idx on [db-au-workspace].[opsupport].[ev_contact]([CustomerID],[ContactType]) include ([ContactValue],[MinDate],[MaxDate])

    end

    if object_id('[db-au-workspace].[opsupport].[ev_network]') is null
    begin

        create table [db-au-workspace].[opsupport].[ev_network]
        (
            [BIRowID] bigint not null identity(1,1),
            [CustomerID] bigint not null,
            [JSONNetwork] nvarchar(max) null
        )

        create unique clustered index cidx on [db-au-workspace].[opsupport].[ev_network]([BIRowID])
        create nonclustered index idx on [db-au-workspace].[opsupport].[ev_network]([CustomerID])

    end    

    if object_id('[db-au-workspace].[opsupport].[ev_relation]') is null
    begin

        create table [db-au-workspace].[opsupport].[ev_relation]
        (
            [BIRowID] bigint not null identity(1,1),
            [CustomerID] bigint not null,
            [Relation] varchar(14) not null,
            [DataID] nvarchar(max) null,
            [RelatedCustomerID] bigint not null,
            [CustomerName] nvarchar(255) null,
            [RelatedScore] varchar(14) not null,
            [RelatedSize] int not null
        )

        create unique clustered index cidx on [db-au-workspace].[opsupport].[ev_relation]([BIRowID])
        create nonclustered index idx on [db-au-workspace].[opsupport].[ev_relation]([CustomerID],[RelatedCustomerID],[Relation])

    end

    if object_id('[db-au-workspace].[opsupport].[ev_timeline]') is null
    begin

        create table [db-au-workspace].[opsupport].[ev_timeline]
        (
            [BIRowID] bigint not null identity(1,1),
            [Who] bigint null,
            [When] date null,
            [What] varchar(14) null,
            [Caption] nvarchar(4000) null,
            [Where] nvarchar(max) null,
            [Detail] nvarchar(70) null,
            [Axis] numeric(3,2) null,
            [URL] nvarchar(max) null,
            [Tooltip] nvarchar(max) not null,
            [Value] numeric(20,2) null,
            [ReferenceID] varchar(100) null,
            [Transcript] nvarchar(4000) null
        )
 
        create unique clustered index cidx on [db-au-workspace].[opsupport].[ev_timeline]([BIRowID])
        create nonclustered index idx on [db-au-workspace].[opsupport].[ev_timeline]([Who],[What])

    end

    if object_id('[db-au-workspace].[opsupport].[ev_policy]') is null
    begin

        create table [db-au-workspace].[opsupport].[ev_policy]
        (
            [BIRowID] bigint not null identity(1,1),
            [CustomerID] bigint null,
            [Domain] varchar(5) null,
            [Business] varchar(5) null,
            [GroupName] nvarchar(50) null,
            [PolicyKey] varchar(50) not null,
            [PolicyNumber] varchar(50) null,
            [Status] varchar(50) null,
            [IssueDate] date null,
            [TripStart] date null,
            [TripEnd] date null,
            [TripType] nvarchar(50) null,
            [PrimaryCountry] nvarchar(50) null,
            [TravellerCount] int null,
            [ClaimCount] int null
        )

        create unique clustered index cidx on [db-au-workspace].[opsupport].[ev_policy]([BIRowID])
        create nonclustered index idx on [db-au-workspace].[opsupport].[ev_policy]([CustomerID],[PolicyKey]) include([PolicyNumber])

    end

end
GO
