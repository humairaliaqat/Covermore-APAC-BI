USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_EnterpriseAssociationGraph]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_EnterpriseAssociationGraph] 
    @CustomerID bigint

as
begin

--declare @CustomerID bigint = 8231562

    declare @rowcount int

    if object_id ('tempdb..#out') is not null
        drop table #out

    create table #out
    (
        ParentID bigint,
        CustomerID bigint,
        CustomerName nvarchar(255),
        Relation varchar(100),
        Level2ID bigint,
        Level2Name nvarchar(255),
        Level2Relation varchar(100),
        Level3ID bigint,
        Level3Name nvarchar(255),
        Level3Relation varchar(100),
        Level4ID bigint,
        Level4Name nvarchar(255),
        Level4Relation varchar(100),
        Level5ID bigint,
        Level5Name nvarchar(255),
        Level5Relation varchar(100)
    )

    if isnull(@CustomerID, 0) <> 0
    begin

        insert into #out
        select
            t.ParentID,
            t.CustomerID,
            t.CustomerName,
            t.Relation,
            null Level2ID,
            null Level2Name,
            null Level2Relation,
            null Level3ID,
            null Level3Name,
            null Level3Relation,
            null Level4ID,
            null Level4Name,
            null Level4Relation,
            null Level5ID,
            null Level5Name,
            null Level5Relation
        from
            dbo.fn_EnterpriseRelation(@CustomerID, null) t

        select 
            @rowcount = count(*) 
        from 
            #out

        insert into #out
        select 
            t.ParentID,
            t.CustomerID,
            t.CustomerName,
            t.Relation,
            r.CustomerID Level2ID,
            r.CustomerName Level2Name,
            r.Relation Level2Relation,
            null Level3ID,
            null Level3Name,
            null Level3Relation,
            null Level4ID,
            null Level4Name,
            null Level4Relation,
            null Level5ID,
            null Level5Name,
            null Level5Relation
        from
            #out t
            cross apply dbo.fn_EnterpriseRelation(t.CustomerID, t.ParentID) r
        where
            t.CustomerID is not null and
            r.CustomerID not in
            (
                select 
                    CustomerID
                from
                    #out
            )

        select 
            @rowcount = count(*) 
        from 
            #out

        insert into #out
        select --top 10
            t.ParentID,
            t.CustomerID,
            t.CustomerName,
            t.Relation,
            t.Level2ID,
            t.Level2Name,
            t.Level2Relation,
            r.CustomerID Level3ID,
            r.CustomerName Level3Name,
            r.Relation Level3Relation,
            null Level4ID,
            null Level4Name,
            null Level4Relation,
            null Level5ID,
            null Level5Name,
            null Level5Relation
        from
            #out t
            cross apply dbo.fn_EnterpriseRelation(t.Level2ID, t.CustomerID) r
        where
            @rowcount < 30 and
            t.Level2ID is not null and
            r.CustomerID not in
            (
                select 
                    CustomerID
                from
                    #out
            ) 
            --and
            --r.CustomerID not in
            --(
            --    select 
            --        Level2ID
            --    from
            --        #out
            --)

        if object_id ('tempdb..#clean') is not null
            drop table #clean

        ;with 
        cte_asssociation as
        (
            select 
                *,
                max(Level2ID) over (partition by CustomerID) MaxLevel2ID,
                max(Level3ID) over (partition by Level2ID) MaxLevel3ID
            from
                #out
        ),
        cte_clean as
        (
            select 
                t.*,
                ec.CUstomerName ParentName
            from
                cte_asssociation t
                inner join entCustomer ec on
                    ec.CustomerID = t.ParentID
            where
                (
                    Level2ID is not null or
                    MaxLevel2ID is null
                ) and
                (
                    Level3ID is not null or
                    MaxLevel3ID is null
                )
        )
        select *
        into #clean
        from
            cte_clean

        if object_id ('tempdb..#nodes') is not null
            drop table #nodes

        select top 180
            CustomerID,
            min(IndexNum) IndexNum
        into #nodes
        from
            (
                select distinct
                    ParentID CustomerID,
                    0 IndexNum
                from
                    #clean

                union

                select distinct
                    CustomerID,
                    1 IndexNum
                from
                    #clean
                where
                    CustomerName is not null

                union

                select distinct
                    Level2ID,
                    2 IndexNum
                from
                    #clean
                where
                    Level2Name is not null

                union

                select distinct
                    Level3ID,
                    3 IndexNum
                from
                    #clean
                where
                    Level3Name is not null
            ) t
        group by
            CustomerID

        if object_id ('tempdb..#coord') is not null
            drop table #coord

        select 
            CustomerID,
            --2 * pi() * row_number() over (order by IndexNum) / count(CustomerID) over () + 2 * pi() Spread,
            cos(2 * pi() * row_number() over (order by IndexNum) / count(CustomerID) over () + pi() / 2) X_Coord,
            sin(2 * pi() * row_number() over (order by IndexNum) / count(CustomerID) over () + pi() / 2) Y_Coord
        into #coord
        from
            #nodes n

        select 
            t.*,
            0 hasClaim,
            (
                select 
                    case
                        when isnull(BlockScore, 0) > 0 then 'Blocked'
                        when p.ClaimScore >= 3000 then 'Very high risk'
                        when p.ClaimScore >= 500 then 'High risk'
                        when p.ClaimScore >= 10 then 'Medium risk'

                        when p.PrimaryScore >= 5000 then 'Very high risk'
                        when p.SecondaryScore >= 6000 then 'Very high risk by association'
                        when p.PrimaryScore >= 3000 then 'High risk'
                        when p.SecondaryScore >= 4000 then 'High risk by association'
                        when p.PrimaryScore > 1500 then 'Medium risk'
                        when p.SecondaryScore > 2000 then 'Medium risk by association'
                        else 'Low Risk'
                    end 
                    

                    --case
                    --    when isnull(bl.BlockScore, 0) > 0 then 'BLOCKED! '
                    --    else ''
                    --end +
                    --case
                    --    when p.PrimaryScore - isnull(bl.BlockScore, 0) >= 5000 then 'Very high risk. ' + char(10)
                    --    when p.SecondaryScore >= 5000 then 'Very high risk by association. ' + char(10)
                    --    when p.PrimaryScore - isnull(bl.BlockScore, 0) >= 2000 then 'High risk. ' + char(10)
                    --    when p.SecondaryScore >= 2000 then 'High risk by association. ' + char(10)
                    --    when p.PrimaryScore - isnull(bl.BlockScore, 0) > 750 then 'Medium risk. ' + char(10)
                    --    when p.SecondaryScore > 750 then 'Medium risk by association. ' + char(10)
                    --    else 'Low Risk'
                    --end 
                from
                    entCustomer p
                    outer apply
                    (
                        select top 1 
                            9001 BlockScore
                        from
                            entBlacklist bl
                        where
                            bl.CustomerID = p.CustomerID
                    ) bl
                where
                    p.CustomerID = t.CustomerID
            ) isFlagged
        from
            (
                select 
                    t.*,
                    c.X_Coord,
                    c.Y_Coord
                from
                    (
                        select distinct
                            ParentID CustomerID,
                            'Node' [Type],
                            ParentName [Node],
                            'Node' [Node and Flow Type],
                            ParentName [Node and Flow Name]
                        from
                            #clean

                        union

                        select distinct
                            CustomerID,
                            'Node' [Type],
                            CustomerName [Node],
                            'Node' [Node and Flow Type],
                            CustomerName [Node and Flow Name]
                        from
                            #clean
                        where
                            CustomerName is not null

                        union

                        select distinct
                            Level2ID,
                            'Node' [Type],
                            Level2Name [Node],
                            'Node' [Node and Flow Type],
                            Level2Name [Node and Flow Name]
                        from
                            #clean
                        where
                            Level2Name is not null

                        union

                        select distinct
                            Level3ID,
                            'Node' [Type],
                            Level3Name [Node],
                            'Node' [Node and Flow Type],
                            Level3Name [Node and Flow Name]
                        from
                            #clean
                        where
                            Level3Name is not null

                        union

                        select distinct
                            ParentID,
                            'Flow Form' [Type],
                            ParentName [Node],
                            Relation [Node and Flow Type],
                            ParentName + ' - ' + CustomerName [Node and Flow Name]
                        from
                            #clean
                        where
                            CustomerName is not null

                        union

                        select distinct
                            CustomerID,
                            'Flow To' [Type],
                            CustomerName [Node],
                            Relation [Node and Flow Type],
                            ParentName + ' - ' + CustomerName [Node and Flow Name]
                        from
                            #clean
                        where
                            CustomerName is not null

                        union

                        select distinct
                            CustomerID,
                            'Flow Form' [Type],
                            CustomerName [Node],
                            Level2Relation [Node and Flow Type],
                            CustomerName + ' - ' + Level2Name [Node and Flow Name]
                        from
                            #clean
                        where
                            Level2Name is not null

                        union

                        select distinct
                            Level2ID,
                            'Flow To' [Type],
                            Level2Name [Node],
                            Level2Relation [Node and Flow Type],
                            CustomerName + ' - ' + Level2Name [Node and Flow Name]
                        from
                            #clean
                        where
                            Level2Name is not null

                        union

                        select distinct
                            Level2ID,
                            'Flow Form' [Type],
                            Level2Name [Node],
                            Level3Relation [Node and Flow Type],
                            Level2Name + ' - ' + Level3Name [Node and Flow Name]
                        from
                            #clean
                        where
                            Level3Name is not null

                        union

                        select distinct
                            Level3ID,
                            'Flow To' [Type],
                            Level3Name [Node],
                            Level3Relation [Node and Flow Type],
                            Level2Name + ' - ' + Level3Name [Node and Flow Name]
                        from
                            #clean
                        where
                            Level3Name is not null
                    ) t
                    inner join #coord c on
                        c.CustomerID = t.CustomerID
            ) t


    end

    else
        select
            cast(null as bigint) CustomerID,
            cast(null as varchar(max)) Type,
            cast(null as varchar(max)) Node,
            cast(null as varchar(max)) [Node and Flow Type],
            cast(null as varchar(max)) [Node and Flow Name],
            0 [X_Coord],
            0 [Y_Coord],
            0 [hasClaim],
            cast(null as varchar(max)) [isFlagged]


end



GO
