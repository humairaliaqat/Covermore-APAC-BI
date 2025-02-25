USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL077_EnterpriseMDM_UpdatedRecords]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL077_EnterpriseMDM_UpdatedRecords]
    @LoadPolicyOnly bit = 0

as
begin

    declare
        @batchid int,
        @start date,
        @end date

    begin try

        exec [db-au-stage]..syssp_getrunningbatch
            @SubjectArea = 'EnterpriseMDM ODS',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out

    end try

    begin catch
    end catch

    select
        @start = isnull(@start, getdate()),
        @end = isnull(@end, getdate())

    --select 
    --    @start,
    --    @end

    if object_id('[db-au-stage]..ent_UPDATED_PARTIES') is not null
        drop table [db-au-stage]..ent_UPDATED_PARTIES

    select 
        ROWID_OBJECT PARTY_FK
    into [db-au-stage]..ent_UPDATED_PARTIES
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )
    
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        PRTY_FK 
    from 
        [db_au_mdmenterprise].[dbo].C_PRTY_IND_DTL 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )
        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        PRTY_FK 
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_EMAIL 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )
        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        PRTY_FK 
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_ADDRESS 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )
        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        PRTY_FK 
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_PHONE 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )
        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        PRTY_FK 
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_PRODUCT_TXN 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        PRTY_FK
    from
        [db_au_mdmenterprise].[dbo].vC_PARTY_PRODUCT_TXN t with(nolock)
    where
        not exists
        (
            select 
                null
            from
                [db-au-cmdwh]..entPolicy r with(nolock)
            where
                r.PolicyKey = t.POLICY_KEY and
                r.Reference = t.PROD_REF_NO
        )

        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        PRTY_FK 
    from 
        [db_au_mdmenterprise].[dbo].C_PARTY_IDENTIFIER 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )
        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ORIG_ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            (
                LAST_UPDATE_DATE >= @start and 
                LAST_UPDATE_DATE <  dateadd(day, 1, @end)
            ) or
		    ROWID_OBJECT in
		    (
			    select 
				    PARTY_FK
			    from
				    [db-au-stage]..ent_UPDATED_PARTIES
		    )
        )

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ORIG_ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_ADDRESS_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            (
                LAST_UPDATE_DATE >= @start and 
                LAST_UPDATE_DATE <  dateadd(day, 1, @end)
            ) or
		    ROWID_OBJECT in
		    (
			    select 
				    PARTY_FK
			    from
				    [db-au-stage]..ent_UPDATED_PARTIES
		    )
        )
        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ROWID_OBJECT
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_ADDRESS_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ORIG_ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_EMAIL_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            (
                LAST_UPDATE_DATE >= @start and 
                LAST_UPDATE_DATE <  dateadd(day, 1, @end)
            ) or
		    ROWID_OBJECT in
		    (
			    select 
				    PARTY_FK
			    from
				    [db-au-stage]..ent_UPDATED_PARTIES
		    )
        )
        
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ROWID_OBJECT
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_EMAIL_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ORIG_ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_IDENTIFIER_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            (
                LAST_UPDATE_DATE >= @start and 
                LAST_UPDATE_DATE <  dateadd(day, 1, @end)
            ) or
		    ROWID_OBJECT in
		    (
			    select 
				    PARTY_FK
			    from
				    [db-au-stage]..ent_UPDATED_PARTIES
		    )
        )
    
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ROWID_OBJECT
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_IDENTIFIER_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        )

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ORIG_ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_PHONE_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            (
                LAST_UPDATE_DATE >= @start and 
                LAST_UPDATE_DATE <  dateadd(day, 1, @end)
            ) or
		    ROWID_OBJECT in
		    (
			    select 
				    PARTY_FK
			    from
				    [db-au-stage]..ent_UPDATED_PARTIES
		    )
        )
    
    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ROWID_OBJECT
    from 
        [db_au_mdmenterprise].[dbo].vC_PARTY_PHONE_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        ) 

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ORIG_ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PRTY_IND_DTL_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            (
                LAST_UPDATE_DATE >= @start and 
                LAST_UPDATE_DATE <  dateadd(day, 1, @end)
            ) or
		    ROWID_OBJECT in
		    (
			    select 
				    PARTY_FK
			    from
				    [db-au-stage]..ent_UPDATED_PARTIES
		    )
        )

    insert into [db-au-stage]..ent_UPDATED_PARTIES (PARTY_FK)
    select 
        ROWID_OBJECT 
    from 
        [db_au_mdmenterprise].[dbo].vC_PRTY_IND_DTL_XREF 
    where 
        @LoadPolicyOnly = 0 and
        (
            LAST_UPDATE_DATE >= @start and 
            LAST_UPDATE_DATE <  dateadd(day, 1, @end)
        ) 

    --select *
    --from
    --    [db-au-stage]..ent_UPDATED_PARTIES

end
GO
