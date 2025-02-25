USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entBlackList]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_entBlackList]
as
begin

    if object_id('[db-au-cmdwh]..entBlacklist') is null
    begin

        create table [db-au-cmdwh]..[entBlacklist]
        (
            [BIRowID] bigint not null identity(1,1),
            [CustomerID] bigint null,
            [PolicyKey] varchar(50) null,
            [SURNAME] varchar(50) null,
            [GIVEN] varchar(50) null,
            [DOB] date null,
            [ADDRESS] varchar(250) null,
            [EMAIL] varchar(250) null,
            [CLAIM] varchar(50) null,
            [POLICY] varchar(50) null,
            [FRAUD] varchar(50) null,
            [REASON] nvarchar(max) null
        )

        create unique clustered index cidx on [db-au-cmdwh]..[entBlacklist](BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..[entBlacklist] (CustomerID) include (REASON)

    end


    if object_id('tempdb..#blacklist') is not null
        drop table #blacklist

    select 
        *
    into #blacklist
    from 
        openrowset
        (
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;HDR=YES;IMEX=1;Database=E:\ETL\Data\ROFI list.xlsx',
            '
            select 
                *
            from 
                [Sheet1$]
            '
        )

    --select *
    --from
    --    #blacklist

    if object_id('tempdb..#blacklist_trav') is not null
        drop table #blacklist_trav

    select 
        0 CustomerID,
        ptv.PolicyKey,
        ptv.PolicyTravellerKey,
        cn.ClaimKey,
        cn.NameKey,
        SURNAME,
        GIVEN,
        DOB,
        [ADDRESS],
        [E-MAIL] EMAIL,
        CLAIM,
        convert(varchar(max), convert(decimal(38,0), t.POLICY)) POLICY,
        FRAUD,
        REASON
    into #blacklist_trav
    from
        #blacklist t
        outer apply
        (
            select top 1
                p.PolicyKey,
                ptv.PolicyTravellerKey
            from
                [db-au-cmdwh]..penPolicy p with(nolock)
                inner join [db-au-cmdwh]..penPolicyTraveller ptv with(nolock) on
                    ptv.PolicyKey = p.PolicyKey
            where
                p.CountryKey = 'AU' and
                p.PolicyNumber = convert(varchar(max), convert(decimal(38,0), t.POLICY))
            order by
                case
                    when ptv.FirstName = t.Given and ptv.LastName = t.SURNAME then 1
                    when ptv.FirstName = t.Given then 2
                    when soundex(ptv.FirstName) = soundex(t.Given) then 3
                    else 4
                end
        ) ptv
        outer apply
        (
            select top 1 
                cn.ClaimKey,
                cn.NameKey
            from
                [db-au-cmdwh]..clmName cn with(nolock)
            where
                cn.CountryKey = 'AU' and
                cn.ClaimNo = t.CLAIM
            order by
                case
                    when cn.FirstName = t.Given and cn.Surname = t.SURNAME then 1
                    when cn.FirstName = t.Given then 2
                    when soundex(cn.FirstName) = soundex(t.Given) then 3
                    else 4
                end
        ) cn

    truncate table [db-au-cmdwh]..entBlacklist

    insert into [db-au-cmdwh]..entBlacklist
    (
        CustomerID,
        PolicyKey,
        SURNAME,
        GIVEN,
        DOB,
        [ADDRESS],
        EMAIL,
        CLAIM,
        POLICY,
        FRAUD,
        REASON
    )
    select 
        isnull(p.CustomerID, c.CustomerID) CustomerID,
        PolicyKey,
        SURNAME,
        GIVEN,
        DOB,
        [ADDRESS],
        EMAIL,
        CLAIM,
        POLICY,
        FRAUD,
        REASON
    from
        #blacklist_trav t
        outer apply
        (
            select top 1
                CustomerID
            from
                [db-au-cmdwh]..entPolicy ep with(nolock)
            where
                ep.PolicyKey = t.PolicyKey and
                ep.Reference = t.PolicyTravellerKey
        ) p
        outer apply
        (
            select top 1
                CustomerID
            from
                [db-au-cmdwh]..entPolicy ep with(nolock)
            where
                ep.ClaimKey = t.ClaimKey and
                ep.Reference = t.NameKey
        ) c

end
GO
