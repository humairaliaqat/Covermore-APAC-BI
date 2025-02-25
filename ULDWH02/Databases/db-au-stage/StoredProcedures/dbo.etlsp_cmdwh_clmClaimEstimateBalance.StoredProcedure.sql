USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmClaimEstimateBalance]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_clmClaimEstimateBalance]
    @MonthStart date

as
begin

--20150722, LS, release to prod
--20160901, LL, drop UTC

    if object_id('[db-au-cmdwh].dbo.clmClaimEstimateBalance') is null
    begin

        create table [db-au-cmdwh].dbo.clmClaimEstimateBalance
        (

            [BIRowID] int not null identity(1,1),
	        [CountryKey] [varchar](2) not null,
	        [Date] [date] not null,
	        [BenefitCategory] [varchar](35) not null,
	        [SectionCode] [varchar](25) null,
            [EstimateBalance] [money] null,
            [RecoveryEstimateBalance] [money] null
        )

        create clustered index idx_clmClaimEstimateBalance_BIRowID on [db-au-cmdwh].dbo.clmClaimEstimateBalance(BIRowID)
        create nonclustered index idx_clmClaimEstimateBalance_Date on [db-au-cmdwh].dbo.clmClaimEstimateBalance(Date,CountryKey) include(BenefitCategory,SectionCode,EstimateBalance,RecoveryEstimateBalance)

    end

    --if object_id('[db-au-cmdwh].dbo.clmClaimEstimateBalanceUTC') is null
    --begin

    --    create table [db-au-cmdwh].dbo.clmClaimEstimateBalanceUTC
    --    (

    --        [BIRowID] int not null identity(1,1),
	   --     [CountryKey] [varchar](2) not null,
	   --     [Date] [date] not null,
	   --     [BenefitCategory] [varchar](35) not null,
	   --     [SectionCode] [varchar](25) null,
    --        [EstimateBalance] [money] null,
    --        [RecoveryEstimateBalance] [money] null
    --    )

    --    create clustered index idx_clmClaimEstimateBalanceUTC_BIRowID on [db-au-cmdwh].dbo.clmClaimEstimateBalanceUTC(BIRowID)
    --    create nonclustered index idx_clmClaimEstimateBalanceUTC_Date on [db-au-cmdwh].dbo.clmClaimEstimateBalanceUTC(Date,CountryKey) include(BenefitCategory,SectionCode,EstimateBalance,RecoveryEstimateBalance)

    --end

    begin transaction

    begin try
    
        delete 
        from 
            [db-au-cmdwh]..clmClaimEstimateBalance
        where
            [Date] = @MonthStart

        insert into [db-au-cmdwh].dbo.clmClaimEstimateBalance with(tablock)
        (
	        CountryKey,
	        Date,
	        BenefitCategory,
	        SectionCode,
            EstimateBalance,
            RecoveryEstimateBalance
        )
        select 
            left(ClaimKey, 2) CountryKey,
            @MonthStart,
            BenefitCategory,
            SectionCode,
            sum(EstimateMovement) Estimate,
            sum(RecoveryEstimateMovement) RecoveryEstimate
        from
            [db-au-cmdwh]..clmClaimEstimateMovement
        where
            EstimateDate < @MonthStart
        group by
            left(ClaimKey, 2),
            BenefitCategory,
            SectionCode


        --delete 
        --from 
        --    [db-au-cmdwh]..clmClaimEstimateBalanceUTC
        --where
        --    [Date] = @MonthStart

        --insert into [db-au-cmdwh].dbo.clmClaimEstimateBalanceUTC with(tablock)
        --(
	       -- CountryKey,
	       -- Date,
	       -- BenefitCategory,
	       -- SectionCode,
        --    EstimateBalance,
        --    RecoveryEstimateBalance
        --)
        --select 
        --    left(ClaimKey, 2) CountryKey,
        --    @MonthStart,
        --    BenefitCategory,
        --    SectionCode,
        --    sum(EstimateMovement) Estimate,
        --    sum(RecoveryEstimateMovement) RecoveryEstimate
        --from
        --    [db-au-cmdwh]..clmClaimEstimateMovement
        --where
        --    EstimateDateUTC < @MonthStart
        --group by
        --    left(ClaimKey, 2),
        --    BenefitCategory,
        --    SectionCode
            
    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'clmClaimEstimateBalance data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = -1,
            @PackageID = 'clmClaimEstimateBalance'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
