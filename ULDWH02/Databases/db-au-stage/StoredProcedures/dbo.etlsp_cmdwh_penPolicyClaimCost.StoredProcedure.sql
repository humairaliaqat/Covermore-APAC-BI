USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyClaimCost]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penPolicyClaimCost]
    @MonthStart date
    
as
begin

--declare 
--    @MonthStart date
--select
--    @MonthStart = '2014-10-01'

    set nocount on

    if object_id('tempdb..#penPolicyClaimCost') is not null
        drop table #penPolicyClaimCost

    select 
        (
            select top 1 
                Date_SK
            from
                [db-au-star]..Dim_Date d
            where
                d.Date = dateadd(day, -1, dateadd(month, 1, @MonthStart))
        ) [Date_SK],
        @MonthStart IncurredDate,
        cl.ClaimKey,
        cl.PolicyTransactionKey,
        cl.ClaimNo,
        cl.PolicyNo,
        case
            when csi.Bucket = 'CAT' then isnull(csi.Incurred, 0)
            else 0
        end [Incurred Cat],
        case
            when csi.Bucket = 'Large' then isnull(csi.Incurred, 0)
            else 0
        end [Incurred Large],
        case
            when csi.Bucket = 'Underlying' then isnull(csi.Incurred, 0)
            else 0
        end [Incurred Underlying]
    into #penPolicyClaimCost
    from
        [db-au-cmdwh]..clmClaim cl
        inner join [db-au-cmdwh]..clmSection cs on
            cs.ClaimKey = cl.ClaimKey
        outer apply
        (
            select 
                csi.Bucket,
                sum(isnull(IncurredDelta, 0)) Incurred
            from
                [db-au-cmdwh]..vclmClaimSectionIncurred csi
            where
                csi.SectionKey = cs.SectionKey and
                csi.IncurredDate >= @MonthStart and
                csi.IncurredDate <  dateadd(month, 1, @MonthStart)
            group by
                csi.Bucket
        ) csi
    where
        cl.CreateDate < dateadd(month, 1, @MonthStart) and
        csi.Incurred <> 0 and
        csi.Incurred is not null
        
    if object_id('[db-au-cmdwh]..penPolicyClaimCost') is null
    begin

        create table [db-au-cmdwh]..[penPolicyClaimCost]
        (
            [BIRowID] bigint not null identity(1,1),
            [Date_SK] int not null,
            [Incurred Date] datetime null,
            [ClaimKey] varchar(41) null,
            [PolicyTransactionKey] varchar(41) null,
            [Claim Number] int null,
            [Policy Number] varchar(50) null,
            [Ultimate Cat] money null,
            [Ultimate Large] money null,
            [Ultimate Underlying] money null,
            [Incurred Cat] money null,
            [Incurred Large] money null,
            [Incurred Underlying] money null,
            [Projected Cat] money null,
            [Projected Large] money null,
            [Projected Underlying] money null
        )
    
        create clustered index idx_penPolicyClaimCost_BIRowID on [db-au-cmdwh]..penPolicyClaimCost(BIRowID)
        create nonclustered index idx_penPolicyClaimCost_PolicyTransactionKey on [db-au-cmdwh]..penPolicyClaimCost(PolicyTransactionKey) 
            include ([Ultimate Cat],[Ultimate Large],[Ultimate Underlying],[Incurred Cat],[Incurred Large],[Incurred Underlying],[Projected Cat],[Projected Large],[Projected Underlying])
        create nonclustered index idx_penPolicyClaimCost_Date_SK on [db-au-cmdwh]..penPolicyClaimCost(Date_SK) 
            include ([Ultimate Cat],[Ultimate Large],[Ultimate Underlying],[Incurred Cat],[Incurred Large],[Incurred Underlying],[Projected Cat],[Projected Large],[Projected Underlying])
        create nonclustered index idx_penPolicyClaimCost_IncurredDate on [db-au-cmdwh]..penPolicyClaimCost([Incurred Date]) 
            include ([Ultimate Cat],[Ultimate Large],[Ultimate Underlying],[Incurred Cat],[Incurred Large],[Incurred Underlying],[Projected Cat],[Projected Large],[Projected Underlying])
        create nonclustered index idx_penPolicyClaimCost_ClaimKey on [db-au-cmdwh]..penPolicyClaimCost(ClaimKey)
        create nonclustered index idx_penPolicyClaimCost_ClaimNo on [db-au-cmdwh]..penPolicyClaimCost([Claim Number])
        
    end


    begin transaction

    begin try

        delete 
        from
            [db-au-cmdwh]..[penPolicyClaimCost]
        where
            [Incurred Date] >= @MonthStart
            
        insert into [db-au-cmdwh]..[penPolicyClaimCost]
        (
            [Date_SK],
            [Incurred Date],
            ClaimKey,
            PolicyTransactionKey,
            [Claim Number],
            [Policy Number],
            [Ultimate Cat],
            [Ultimate Large],
            [Ultimate Underlying],
            [Incurred Cat],
            [Incurred Large],
            [Incurred Underlying],
            [Projected Cat],
            [Projected Large],
            [Projected Underlying]
        )
        select
            [Date_SK],
            IncurredDate,
            ClaimKey,
            PolicyTransactionKey,
            ClaimNo,
            PolicyNo,
            0,
            0,
            0,
            sum(isnull([Incurred Cat], 0)) [Incurred Cat],
            sum(isnull([Incurred Large], 0)) [Incurred Large],
            sum(isnull([Incurred Underlying], 0)) [Incurred Underlying],
            0,
            0,
            0
        from
            #penPolicyClaimCost
        group by
            [Date_SK],
            IncurredDate,
            ClaimKey,
            PolicyTransactionKey,
            ClaimNo,
            PolicyNo
        
    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'penPolicyClaimCost data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = -1,
            @PackageID = 'penPolicyClaimCost'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
