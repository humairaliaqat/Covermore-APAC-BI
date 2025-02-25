USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tds_claim_incurred]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[tds_claim_incurred]
as
begin

--CBA TDS, logic: All claim incurred movements on day - 1
--20180727, LL, create

    declare 
        @batchid int,
        @start date,
        @end date

    --debug
    declare
        @domain varchar(5) = 'AU',
        @group varchar(5) = 'MB'

    --todo: get active batch


    --dev
    select
        @batchid = -1,
        @start = '2018-06-01',
        @end = '2018-06-30'

    if object_id('[db-au-cba].[dbo].[cbaClaimIncurred]') is null
    begin

        create table [db-au-cba].[dbo].[cbaClaimIncurred]
        (
            BIRowID bigint not null identity(1,1),
            BatchID int,
            claim_number int,
            incident_number int,
            incurred_date date,
            claim_benefit varchar(50),
            outstanding_movement decimal(20,6),
            payment_movement decimal(20,6),
            incurred_movement decimal(20,6),
            outstanding_eod decimal(20,6),
            payment_eod decimal(20,6),
            incurred_eod decimal(20,6)
        )

        create unique clustered index ucidx_cbaClaimIncurred on [db-au-cba].[dbo].[cbaClaimIncurred](BIRowID)
        create nonclustered index idx_cbaClaimIncurred_BatchID on [db-au-cba].[dbo].[cbaClaimIncurred](BatchID)

    end
    
    begin transaction 

    begin try

        --delete existing data from current batch (just in case)
        delete
        from
            [db-au-cba].[dbo].[cbaClaimIncurred]
        where
            BatchID = @batchid

        insert into [db-au-cba].[dbo].[cbaClaimIncurred]
        (
            BatchID,
            [claim_number],
            [incident_number],
            [incurred_date],
            [claim_benefit],
            [outstanding_movement],
            [payment_movement],
            [incurred_movement],
            [outstanding_eod],
            [payment_eod],
            [incurred_eod]
        )
        select --top 100 
            @batchid,
            cl.ClaimNo [claim_number],
            cs.EventID [incident_number],
            csi.IncurredDate [incurred_date],
            cs.SectionDescription [claim_benefit],
            csi.EstimateDelta [outstanding_movement],
            csi.PaymentDelta [payment_movement],
            csi.IncurredDelta [incurred_movement],
            csi.Estimate [outstanding_eod],
            csi.Paid [payment_eod],
            csi.IncurredValue [incurred_eod]
        from
            [ULDWH02].[db-au-cmdwh].[dbo].[clmClaim] cl
            inner join [ULDWH02].[db-au-cmdwh].[dbo].[penOutlet] o on
                o.OutletKey = cl.OutletKey and
                o.OutletStatus = 'Current'
            inner join [ULDWH02].[db-au-cmdwh].[dbo].[clmSection] cs on
                cs.ClaimKey = cl.ClaimKey
            inner join [ULDWH02].[db-au-cmdwh].[dbo].[vclmClaimSectionIncurred] csi on
                csi.SectionKey = cs.SectionKey
        where
            o.CountryKey = @domain and
            o.GroupCode = @group and
            csi.IncurredDate >= @start and
            csi.IncurredDate <  dateadd(day, 1, @end)            

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbAddress

        --exec syssp_genericerrorhandler 'cbaClaimIncurred data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction 



end
GO
