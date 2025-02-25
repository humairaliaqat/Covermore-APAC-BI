USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_customer_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_customer_rollup]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:
Prerequisite:
Description:
Change History:
                20130129 - LS - case 18180, NZ: use the same TRIPS schema as AU
                20130405 - LS - case 18433, MY & SG uses the wrong staging table

*************************************************************************************************************************************/

    set nocount on


    --get the max address record for each policy
    --this step is required because there may be more than 1 address record for each policy.
    if object_id('[db-au-stage].dbo.etl_address') is not null drop table [db-au-stage].dbo.etl_address

    ;WITH CTE_Address
    as
    (
        select
            'AU' as Country,
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP],
            max(PPADDR_ID) as PPADDR_ID
        from [db-au-stage].dbo.trips_ppaddr_au a
        group by
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP]

        union all

        select
            'NZ' as Country,
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP],
            max(PPADDR_ID) as PPADDR_ID
        from [db-au-stage].dbo.trips_ppaddr_nz a
        group by
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP]

        union all

        select
            'UK' as Country,
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP],
            max(PPADDR_ID) as PPADDR_ID
        from [db-au-stage].dbo.trips_ppaddr_uk a
        group by
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP]

        union all

        select
            'MY' as Country,
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP],
            max(PPADDR_ID) as PPADDR_ID
        from [db-au-stage].dbo.trips_ppaddr_my a
        group by
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP]

        union all

        select
            'SG' as Country,
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP],
            max(PPADDR_ID) as PPADDR_ID
        from [db-au-stage].dbo.trips_ppaddr_sg a
        group by
            a.[PPALPHA],
            a.[PPPOLYN],
            a.[PPPOLTP]
    )
    select
        'AU' as Country,
        a.[PPADDR_ID],
        a.[PPALPHA],
        a.[PPPOLYN],
        a.[PPPOLTP],
        a.[PPSTREET],
        a.[PPSUBURB],
        a.[PPSTATE],
        a.[PPPOST],
        a.[PPPHONE],
        a.[PPWPHONE],
        a.[PPEMAIL],
        a.[PPCOUNTRY]
    into [db-au-stage].dbo.etl_address
    from
        [db-au-stage].dbo.trips_ppaddr_au a
        join CTE_Address ad on
            a.[PPALPHA] = ad.[PPALPHA] and
            a.[PPPOLYN] = ad.[PPPOLYN] and
            a.[PPPOLTP] = ad.[PPPOLTP] and
            a.[PPADDR_ID] = ad.[PPADDR_ID] and
            ad.[Country] = 'AU'

    union all

    select
        'NZ' as Country,
        a.[PPADDR_ID],
        a.[PPALPHA],
        a.[PPPOLYN],
        a.[PPPOLTP],
        a.[PPSTREET],
        a.[PPSUBURB],
        a.[PPSTATE],
        a.[PPPOST],
        a.[PPPHONE],
        a.[PPWPHONE],
        a.[PPEMAIL],
        a.[PPCOUNTRY]
    from
        [db-au-stage].dbo.trips_ppaddr_nz a
        join CTE_Address ad on
            a.[PPALPHA] = ad.[PPALPHA] and
            a.[PPPOLYN] = ad.[PPPOLYN] and
            a.[PPPOLTP] = ad.[PPPOLTP] and
            a.[PPADDR_ID] = ad.[PPADDR_ID] and
            ad.[Country] = 'NZ'

    union all

    select
        'UK' as Country,
        a.[PPADDR_ID],
        a.[PPALPHA],
        a.[PPPOLYN],
        a.[PPPOLTP],
        a.[PPSTREET],
        a.[PPSUBURB],
        a.[PPSTATE],
        a.[PPPOST],
        a.[PPPHONE],
        a.[PPWPHONE],
        a.[PPEMAIL],
        a.[PPCOUNTRY]
    from
        [db-au-stage].dbo.trips_ppaddr_uk a
        join CTE_Address ad on
            a.[PPALPHA] = ad.[PPALPHA] and
            a.[PPPOLYN] = ad.[PPPOLYN] and
            a.[PPPOLTP] = ad.[PPPOLTP] and
            a.[PPADDR_ID] = ad.[PPADDR_ID] and
            ad.[Country] = 'UK'

    union all

    select
        'MY' as Country,
        a.[PPADDR_ID],
        a.[PPALPHA],
        a.[PPPOLYN],
        a.[PPPOLTP],
        a.[PPSTREET],
        a.[PPSUBURB],
        a.[PPSTATE],
        a.[PPPOST],
        a.[PPPHONE],
        a.[PPWPHONE],
        a.[PPEMAIL],
        a.[PPCOUNTRY]
    from
        [db-au-stage].dbo.trips_ppaddr_my a
        join CTE_Address ad on
            a.[PPALPHA] = ad.[PPALPHA] and
            a.[PPPOLYN] = ad.[PPPOLYN] and
            a.[PPPOLTP] = ad.[PPPOLTP] and
            a.[PPADDR_ID] = ad.[PPADDR_ID] and
            ad.[Country] = 'MY'

    union all

    select
        'SG' as Country,
        a.[PPADDR_ID],
        a.[PPALPHA],
        a.[PPPOLYN],
        a.[PPPOLTP],
        a.[PPSTREET],
        a.[PPSUBURB],
        a.[PPSTATE],
        a.[PPPOST],
        a.[PPPHONE],
        a.[PPWPHONE],
        a.[PPEMAIL],
        a.[PPCOUNTRY]
    from
        [db-au-stage].dbo.trips_ppaddr_sg a
        join CTE_Address ad on
            a.[PPALPHA] = ad.[PPALPHA] and
            a.[PPPOLYN] = ad.[PPPOLYN] and
            a.[PPPOLTP] = ad.[PPPOLTP] and
            a.[PPADDR_ID] = ad.[PPADDR_ID] and
            ad.[Country] = 'SG'

    --combine customer and address records
    if object_id('[db-au-stage].dbo.etl_customer') is not null drop table [db-au-stage].dbo.etl_customer

    select
      'AU' as CountryKey,
      left('AU-' + ltrim(rtrim(left(m.PPALPHA,7))) + '-' + convert(varchar,m.PPPOLYN),41) COLLATE Latin1_General_CI_AS as CustomerKey,
      left(m.PPALPHA,7)  COLLATE Latin1_General_CI_AS as AgencyCode,
      m.PPPOLYN as PolicyNo,
      left(m.PPPOLTP,4)COLLATE Latin1_General_CI_AS as ProductCode,
      left(m.PPTITLE,6) COLLATE Latin1_General_CI_AS as Title,
      left(m.PPFIRST,25) COLLATE Latin1_General_CI_AS as FirstName,
      left(m.PPINITS,4) COLLATE Latin1_General_CI_AS as Initial,
      left(m.PPNAME,25) COLLATE Latin1_General_CI_AS as LastName,
      m.PPDOB as DateOfBirth,
      case when isNumeric(m.PPAGE) = 1 then convert(int,m.PPAGE) else null end as AgeAtDateOfIssue,
      m.ISADULT as PersonIsAdult,
      left(a.PPSTREET,60) COLLATE Latin1_General_CI_AS as AddressStreet,
      left(a.PPSUBURB,30) COLLATE Latin1_General_CI_AS as AddressSuburb,
      left(a.PPSTATE,20) COLLATE Latin1_General_CI_AS as AddressState,
      left(a.PPPOST,6) COLLATE Latin1_General_CI_AS  as AddressPostCode,
      left(a.PPCOUNTRY,20) COLLATE Latin1_General_CI_AS as AddressCountry,
      left(a.PPPHONE,30) COLLATE Latin1_General_CI_AS as Phone,
      left(a.PPWPHONE,30) COLLATE Latin1_General_CI_AS as WorkPhone,
      left(a.PPEMAIL,60) COLLATE Latin1_General_CI_AS as Email,
      m.PPMULT_ID as CustomerID,
      a.PPADDR_ID as AddressID,
      null as isPrimary,
      m.MemberNumber
    into [db-au-stage].dbo.etl_customer
    from
      [db-au-stage].dbo.trips_ppmult_au m
      join [db-au-stage].dbo.etl_address a on
        m.PPALPHA = a.PPALPHA and
        m.PPPOLYN = a.PPPOLYN and
        m.PPPOLTP = a.PPPOLTP and
        a.Country = 'AU'

    union all

    select
      'NZ' as CountryKey,
      left('NZ-' + ltrim(rtrim(left(m.PPALPHA,7))) + '-' + convert(varchar,m.PPPOLYN),41) COLLATE Latin1_General_CI_AS as CustomerKey,
      left(m.PPALPHA,7) COLLATE Latin1_General_CI_AS as AgencyCode,
      m.PPPOLYN as PolicyNo,
      left(m.PPPOLTP,4) COLLATE Latin1_General_CI_AS as ProductCode,
      left(m.PPTITLE,6) COLLATE Latin1_General_CI_AS as Title,
      left(m.PPFIRST,25) COLLATE Latin1_General_CI_AS as FirstName,
      left(m.PPINITS,4) COLLATE Latin1_General_CI_AS as Initial,
      left(m.PPNAME,25) COLLATE Latin1_General_CI_AS as LastName,
      m.PPDOB as DateOfBirth,
      case when isNumeric(m.PPAGE) = 1 then convert(int,m.PPAGE) else null end as AgeAtDateOfIssue,
      m.ISADULT as PersonIsAdult,
      left(a.PPSTREET,60) COLLATE Latin1_General_CI_AS as AddressStreet,
      left(a.PPSUBURB,30) COLLATE Latin1_General_CI_AS as AddressSuburb,
      left(a.PPSTATE,20) COLLATE Latin1_General_CI_AS as AddressState,
      left(a.PPPOST,6) COLLATE Latin1_General_CI_AS as AddressPostCode,
      left(a.PPCOUNTRY,20) COLLATE Latin1_General_CI_AS as AddressCountry,
      left(a.PPPHONE,30) COLLATE Latin1_General_CI_AS as Phone,
      left(a.PPWPHONE,30) COLLATE Latin1_General_CI_AS  as WorkPhone,
      left(a.PPEMAIL,60) COLLATE Latin1_General_CI_AS as Email,
      m.PPMULT_ID as CustomerID,
      a.PPADDR_ID as AddressID,
      null as isPrimary,
      m.MemberNumber
    from
      [db-au-stage].dbo.trips_ppmult_nz m
      join [db-au-stage].dbo.etl_address a on
        m.PPALPHA = a.PPALPHA and
        m.PPPOLYN = a.PPPOLYN and
        m.PPPOLTP = a.PPPOLTP and
        a.Country = 'NZ'

    union all

    select
      'UK' as CountryKey,
      left('UK-' + ltrim(rtrim(left(m.PPALPHA,7))) + '-' + convert(varchar,m.PPPOLYN),41) COLLATE Latin1_General_CI_AS as CustomerKey,
      left(m.PPALPHA,7) COLLATE Latin1_General_CI_AS as AgencyCode,
      m.PPPOLYN as PolicyNo,
      left(m.PPPOLTP,4) COLLATE Latin1_General_CI_AS as ProductCode,
      left(m.PPTITLE,6) COLLATE Latin1_General_CI_AS as Title,
      left(m.PPFIRST,25) COLLATE Latin1_General_CI_AS as FirstName,
      left(m.PPINITS,4) COLLATE Latin1_General_CI_AS as Initial,
      left(m.PPNAME,25) COLLATE Latin1_General_CI_AS as LastName,
      m.PPDOB as DateOfBirth,
      case when isNumeric(m.PPAGE) = 1 then convert(int,m.PPAGE) else null end as AgeAtDateOfIssue,
      m.ISADULT as PersonIsAdult,
      left(a.PPSTREET,60) COLLATE Latin1_General_CI_AS as AddressStreet,
      left(a.PPSUBURB,30) COLLATE Latin1_General_CI_AS as AddressSuburb,
      left(a.PPSTATE,20) COLLATE Latin1_General_CI_AS as AddressState,
      left(a.PPPOST,6) COLLATE Latin1_General_CI_AS as AddressPostCode,
      left(a.PPCOUNTRY,20) COLLATE Latin1_General_CI_AS as AddressCountry,
      left(a.PPPHONE,30) COLLATE Latin1_General_CI_AS as Phone,
      left(a.PPWPHONE,30) COLLATE Latin1_General_CI_AS  as WorkPhone,
      left(a.PPEMAIL,60) COLLATE Latin1_General_CI_AS as Email,
      m.PPMULT_ID as CustomerID,
      a.PPADDR_ID as AddressID,
      null as isPrimary,
      null MemberNumber
    from
      [db-au-stage].dbo.trips_ppmult_uk m
      join [db-au-stage].dbo.etl_address a on
        m.PPALPHA = a.PPALPHA and
        m.PPPOLYN = a.PPPOLYN and
        m.PPPOLTP = a.PPPOLTP and
        a.Country = 'UK'

    union all

    select
      'MY' as CountryKey,
      left('MY-' + ltrim(rtrim(left(m.PPALPHA,7))) + '-' + convert(varchar,m.PPPOLYN),41) COLLATE Latin1_General_CI_AS as CustomerKey,
      left(m.PPALPHA,7)  COLLATE Latin1_General_CI_AS as AgencyCode,
      m.PPPOLYN as PolicyNo,
      left(m.PPPOLTP,4)COLLATE Latin1_General_CI_AS as ProductCode,
      left(m.PPTITLE,6) COLLATE Latin1_General_CI_AS as Title,
      left(m.PPFIRST,25) COLLATE Latin1_General_CI_AS as FirstName,
      left(m.PPINITS,4) COLLATE Latin1_General_CI_AS as Initial,
      left(m.PPNAME,25) COLLATE Latin1_General_CI_AS as LastName,
      m.PPDOB as DateOfBirth,
      case when isNumeric(m.PPAGE) = 1 then convert(int,m.PPAGE) else null end as AgeAtDateOfIssue,
      m.ISADULT as PersonIsAdult,
      left(a.PPSTREET,60) COLLATE Latin1_General_CI_AS as AddressStreet,
      left(a.PPSUBURB,30) COLLATE Latin1_General_CI_AS as AddressSuburb,
      left(a.PPSTATE,20) COLLATE Latin1_General_CI_AS as AddressState,
      left(a.PPPOST,6) COLLATE Latin1_General_CI_AS  as AddressPostCode,
      left(a.PPCOUNTRY,20) COLLATE Latin1_General_CI_AS as AddressCountry,
      left(a.PPPHONE,30) COLLATE Latin1_General_CI_AS as Phone,
      left(a.PPWPHONE,30) COLLATE Latin1_General_CI_AS as WorkPhone,
      left(a.PPEMAIL,60) COLLATE Latin1_General_CI_AS as Email,
      m.PPMULT_ID as CustomerID,
      a.PPADDR_ID as AddressID,
      null as isPrimary,
      m.MemberNumber
    from
      [db-au-stage].dbo.trips_ppmult_my m
      join [db-au-stage].dbo.etl_address a on
        m.PPALPHA = a.PPALPHA and
        m.PPPOLYN = a.PPPOLYN and
        m.PPPOLTP = a.PPPOLTP and
        a.Country = 'MY'

    union all

    select
      'SG' as CountryKey,
      left('SG-' + ltrim(rtrim(left(m.PPALPHA,7))) + '-' + convert(varchar,m.PPPOLYN),41) COLLATE Latin1_General_CI_AS as CustomerKey,
      left(m.PPALPHA,7)  COLLATE Latin1_General_CI_AS as AgencyCode,
      m.PPPOLYN as PolicyNo,
      left(m.PPPOLTP,4)COLLATE Latin1_General_CI_AS as ProductCode,
      left(m.PPTITLE,6) COLLATE Latin1_General_CI_AS as Title,
      left(m.PPFIRST,25) COLLATE Latin1_General_CI_AS as FirstName,
      left(m.PPINITS,4) COLLATE Latin1_General_CI_AS as Initial,
      left(m.PPNAME,25) COLLATE Latin1_General_CI_AS as LastName,
      m.PPDOB as DateOfBirth,
      case when isNumeric(m.PPAGE) = 1 then convert(int,m.PPAGE) else null end as AgeAtDateOfIssue,
      m.ISADULT as PersonIsAdult,
      left(a.PPSTREET,60) COLLATE Latin1_General_CI_AS as AddressStreet,
      left(a.PPSUBURB,30) COLLATE Latin1_General_CI_AS as AddressSuburb,
      left(a.PPSTATE,20) COLLATE Latin1_General_CI_AS as AddressState,
      left(a.PPPOST,6) COLLATE Latin1_General_CI_AS  as AddressPostCode,
      left(a.PPCOUNTRY,20) COLLATE Latin1_General_CI_AS as AddressCountry,
      left(a.PPPHONE,30) COLLATE Latin1_General_CI_AS as Phone,
      left(a.PPWPHONE,30) COLLATE Latin1_General_CI_AS as WorkPhone,
      left(a.PPEMAIL,60) COLLATE Latin1_General_CI_AS as Email,
      m.PPMULT_ID as CustomerID,
      a.PPADDR_ID as AddressID,
      null as isPrimary,
      m.MemberNumber
    from
      [db-au-stage].dbo.trips_ppmult_sg m
      join [db-au-stage].dbo.etl_address a on
        m.PPALPHA = a.PPALPHA and
        m.PPPOLYN = a.PPPOLYN and
        m.PPPOLTP = a.PPPOLTP and
        a.Country = 'SG'


    if object_id('[db-au-cmdwh].dbo.Customer') is null
    begin
      create table [db-au-cmdwh].dbo.Customer
      (
        CountryKey varchar(2) not null,
        CustomerKey varchar(41) not null,
        AgencyCode varchar(7) not null,
        PolicyNo int not null,
        ProductCode varchar(4) null,
        Title varchar(6) null,
        FirstName varchar(25) null,
        Initial varchar(4) null,
        LastName varchar(25) null,
        DateOfBirth datetime null,
        AgeAtDateOfIssue int null,
        PersonIsAdult bit null,
        AddressStreet varchar(60) null,
        AddressSuburb varchar(30) null,
        AddressState varchar(20) null,
        AddressPostCode varchar(6) null,
        AddressCountry varchar(20) null,
        Phone varchar(30) null,
        WorkPhone varchar(30) null,
        Email varchar(60) null,
        CustomerID int null,
      MemberNumber varchar(25) null,
        AddressID int null,
        isPrimary bit null
      )
      if exists(select name from sys.indexes where name = 'idx_Customer_CountryKey')
        drop index idx_Customer_CountryKey on Customer.CountryKey

      if exists(select name from sys.indexes where name = 'idx_Customer_CustomerKey')
        drop index idx_Customer_CustomerKey on Customer.CustomerKey

      if exists(select name from sys.indexes where name = 'idx_Customer_AgencyCode')
        drop index idx_Customer_AgencyCode on Customer.AgencyCode

      if exists(select name from sys.indexes where name = 'idx_Customer_PolicyNo')
        drop index idx_Customer_PolicyNo on Customer.PolicyNo

      if exists(select name from sys.indexes where name = 'idx_Customer_CustomerID')
        drop index idx_Customer_CustomerID on Customer.CustomerID

      if exists(select name from sys.indexes where name = 'idx_Customer_AddressID')
        drop index idx_Customer_AddressID on Customer.AddressID

      create index idx_Customer_CountryKey on [db-au-cmdwh].dbo.Customer(CountryKey)
      create index idx_Customer_CustomerKey on [db-au-cmdwh].dbo.Customer(CustomerKey)
      create index idx_Customer_AgencyCode on [db-au-cmdwh].dbo.Customer(AgencyCode)
      create index idx_Customer_PolicyNo on [db-au-cmdwh].dbo.Customer(PolicyNo)
      create index idx_Customer_CustomerID on [db-au-cmdwh].dbo.Customer(CustomerID)
      create index idx_Customer_AddressID on [db-au-cmdwh].dbo.Customer(AddressID)
    end
    else
    begin
        delete [db-au-cmdwh].dbo.Customer
        from [db-au-cmdwh].dbo.Customer a
            join [db-au-stage].dbo.etl_customer b on
                a.CountryKey = b.CountryKey and
                a.CustomerKey = b.CustomerKey
    end



    -- Transfer data from [db-au-stage].dbo.etl_customer to [db-au-cmdwh].dbo.Customer
    insert into [db-au-cmdwh].dbo.Customer with (tablock)
    (
        CountryKey,
        CustomerKey,
        AgencyCode,
        PolicyNo,
        ProductCode,
        Title,
        FirstName,
        Initial,
        LastName,
        DateOfBirth,
        AgeAtDateOfIssue,
        PersonIsAdult,
        AddressStreet,
        AddressSuburb,
        AddressState,
        AddressPostCode,
        AddressCountry,
        Phone,
        WorkPhone,
        Email,
        CustomerID,
        AddressID,
        MemberNumber,
        isPrimary
    )
    select
        c.CountryKey,
        c.CustomerKey,
        c.AgencyCode,
        c.PolicyNo,
        c.ProductCode,
        c.Title,
        c.FirstName,
        c.Initial,
        c.LastName,
        c.DateOfBirth,
        c.AgeAtDateOfIssue,
        c.PersonIsAdult,
        c.AddressStreet,
        c.AddressSuburb,
        c.AddressState,
        c.AddressPostCode,
        c.AddressCountry,
        c.Phone,
        c.WorkPhone,
        c.Email,
        c.CustomerID,
        c.AddressID,
        c.MemberNumber,
        c.isPrimary
    from
        [db-au-stage].dbo.etl_customer c


    --Update Customer table with isPrimary field
    ;WITH Customer_CTE as
    (
        select
            c.CustomerKey,
            min(c.CustomerID) as CustomerID,
            min(c.AddressID) as AddressID
        from
            [db-au-stage].dbo.etl_Customer c
        group by
            c.CustomerKey
    )
    update [db-au-cmdwh].dbo.Customer with (tablockx)
    set isPrimary = 1
    from
    -- LS, 2011-09-06, joining with etl_customer will update ALL Customer record to 1
    --    [db-au-stage].dbo.etl_customer c
        [db-au-cmdwh].dbo.Customer c
        join Customer_CTE t on
            c.CustomerKey = t.CustomerKey and
            c.CustomerID = t.CustomerID and
            c.AddressID = t.AddressID


    drop table [db-au-stage].dbo.etl_address
    drop table [db-au-stage].dbo.etl_customer

end


GO
