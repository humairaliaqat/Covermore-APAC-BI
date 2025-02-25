USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tds_claim]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[tds_claim]
as
begin

--CBA TDS, logic: All claim details related having claim incurred on day - 1
--20180727, LL, create

    declare 
        @batchid int,
        @start date,
        @end date

    --todo: get active batch

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

    if object_id('[db-au-cba].[dbo].[cbaClaim]') is null
    begin

        create table [db-au-cba].[dbo].[cbaClaim]
        (
            BIRowID bigint not null identity(1,1),
            BatchID int,
            claim_number int,
            policy_number varchar(50),
            customer_id nvarchar(50),
            channel_reference nvarchar(50),
            claim_register_date date,
            claim_receipt_date date,
            claim_status nvarchar(50),
            first_finalised_date date,
            outstanding decimal(20,6),
            payment decimal(20,6),
            incurred decimal(20,6)
        )

        create unique clustered index ucidx_cbaClaim on [db-au-cba].[dbo].[cbaClaim](BIRowID)
        create nonclustered index idx_cbaClaim_BatchID on [db-au-cba].[dbo].[cbaClaim](BatchID)

    end

    if object_id('[db-au-cba].[dbo].[cbaClaimClaimant]') is null
    begin

        create table [db-au-cba].[dbo].[cbaClaimClaimant]
        (
            BIRowID bigint not null identity(1,1),
            BatchID int,
            customer_id nvarchar(50),
            title nvarchar(50),
            first_name nvarchar(100),
            last_name nvarchar(100),
            dob date,
            address_line_1 nvarchar(100),
            address_line_2 nvarchar(100),
            post_code nvarchar(50),
            suburb nvarchar(50),
            [state] nvarchar(100),
            country nvarchar(100),
            home_phone nvarchar(50),
            work_phone nvarchar(50),
            mobile_phone nvarchar(50),
            email_address nvarchar(255),
            opt_in_contract nvarchar(5),
            company_name nvarchar(100)
        )

        create unique clustered index ucidx_cbaClaimClaimant on [db-au-cba].[dbo].[cbaClaimClaimant](BIRowID)
        create nonclustered index idx_cbaClaimCLaimant_BatchID on [db-au-cba].[dbo].[cbaClaimClaimant](BatchID)

    end

    begin transaction 

    begin try

        if object_id('tempdb..#claim') is not null
            drop table #claim

        select --top 100 
            @batchid BatchID,
            cl.ClaimNo [claim_number],
            cl.PolicyNo [policy_number],
            case
                when rtrim(isnull(c.CustomerID, '')) <> '' then c.CustomerID
                else isnull(cn.customer_id, '') 
            end [customer_id],
            cl.AgencyCode [channel_reference],
            cl.CreateDate [claim_register_date],
            cl.ReceivedDate [claim_receipt_date],
            cl.StatusDesc [claim_status],
            cl.FirstNilDate [first_finalised_date],
            ci.Estimate [outstanding],
            ci.Paid [payment],
            ci.Incurred [incurred]
        into #claim
        from
            [ULDWH02].[db-au-cmdwh].[dbo].[clmClaim] cl
            inner join [ULDWH02].[db-au-cmdwh].[dbo].[penOutlet] o on
                o.OutletKey = cl.OutletKey and
                o.OutletStatus = 'Current'
            cross apply
            (
                select
                    sum(ci.EstimateDelta) Estimate,
                    sum(ci.PaymentDelta) Paid,
                    sum(ci.IncurredDelta) Incurred
                from
                    [ULDWH02].[db-au-cmdwh].[dbo].[vclmClaimIncurred] ci
                where
                    ci.ClaimKey = cl.ClaimKey
            ) ci
            outer apply
            (
                select top 1 
                    ptv.MemberNumber CustomerID
                from
                    [ULDWH02].[db-au-cmdwh].[dbo].[penPolicyTransSummary] pt
                    inner join [ULDWH02].[db-au-cmdwh].[dbo].[penPolicyTraveller] ptv on
                        ptv.PolicyKey = pt.PolicyKey
                where
                    pt.PolicyTransactionKey = cl.PolicyTransactionKey and
                    ptv.isPrimary = 1
            ) c
            outer apply
            (
                select top 1
                    'CMCN_' + convert(nvarchar, cn.NameID) [customer_id]
                from
                    [ULDWH02].[db-au-cmdwh].[dbo].[clmName] cn
                where
                    cn.ClaimKey = cl.ClaimKey and
                    cn.isPrimary = 1 and
                    isnull(cn.isThirdParty, 0) = 0
            ) cn
        where
            o.CountryKey = @domain and
            o.GroupCode = @group and
            cl.ClaimKey in
            (
                select 
                    r.ClaimKey
                from
                    [ULDWH02].[db-au-cmdwh].[dbo].[vclmClaimIncurred] r
                where
                    r.IncurredDate >= @start and
                    r.IncurredDate <  dateadd(day, 1, @end)            
            )


        --delete existing data from current batch (just in case)
        delete
        from
            [db-au-cba].[dbo].[cbaClaim]
        where
            BatchID = @batchid

        delete
        from
            [db-au-cba].[dbo].[cbaClaimClaimant]
        where
            BatchID = @batchid

        insert into [db-au-cba].[dbo].[cbaClaim]
        (
            BatchID,
            [claim_number],
            [policy_number],
            [customer_id],
            [channel_reference],
            [claim_register_date],
            [claim_receipt_date],
            [claim_status],
            [first_finalised_date],
            [outstanding],
            [payment],
            [incurred]
        )
        select
            BatchID,
            [claim_number],
            [policy_number],
            [customer_id],
            [channel_reference],
            [claim_register_date],
            [claim_receipt_date],
            [claim_status],
            [first_finalised_date],
            [outstanding],
            [payment],
            [incurred]
        from
            #claim

        insert into [db-au-cba].[dbo].[cbaClaimClaimant]
        (
            BatchID,
            customer_id,
            title,
            first_name,
            last_name,
            dob,
            address_line_1,
            address_line_2,
            post_code,
            suburb,
            state,
            country,
            home_phone,
            work_phone,
            mobile_phone,
            email_address,
            opt_in_contact,
            company_name
        )
        select --top 100 
            @batchid,
            'CMCN_' + convert(nvarchar, cn.NameID) [customer_id],
            cn.Title [title],
            cn.Firstname [first_name],
            cn.Surname [last_name],
            cn.DOB [dob],
            cn.AddressStreet [address_line_1],
            '' [address_line_2],
            cn.AddressPostCode [post_code],
            cn.AddressSuburb [suburb],
            cn.AddressState [state],
            cn.AddressCountry [country],
            cn.HomePhone [home_phone],
            cn.WorkPhone [work_phone],
            '' [mobile_phone],
            cn.Email [email_address],
            case
                when isnull(cn.isEmailOK, 0) = 0 then 'No'
                else 'Yes'
            end [opt_in_contact],
            cn.BusinessName [company_name]
        from
            [ULDWH02].[db-au-cmdwh].[dbo].[clmName] cn
        where
            cn.ClaimKey in
            (
                select
                    ClaimKey
                from
                    #claim
            ) and
            isnull(cn.isThirdParty, 0) = 0


    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbAddress

        --exec syssp_genericerrorhandler 'cbaClaim data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction 
    

end
GO
