USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbCaseServices]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cbCaseServices]
as
begin
/*
20150720, LS, T16930, Carebase 4.6
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('[db-au-cmdwh].dbo.cbCaseServices') is null
    begin

        create table [db-au-cmdwh].dbo.cbCaseServices
        (
            [BIRowID] bigint not null identity(1,1),
            [CaseKey] nvarchar(20) not null,
            [CaseNo] nvarchar(15) not null,
            [ServiceTypeID] int not null,
            [ServiceType] nvarchar(250) not null,
            [ServiceAmount] int null,
            [ServiceFee] money null
        )

        create clustered index idx_cbCaseServices_BIRowID on [db-au-cmdwh].dbo.cbCaseServices(BIRowID)
        create nonclustered index idx_cbCaseServices_CaseKey on [db-au-cmdwh].dbo.cbCaseServices(CaseKey)
        create nonclustered index idx_cbCaseServices_CaseNo on [db-au-cmdwh].dbo.cbCaseServices(CaseNo)

    end

    if object_id('tempdb..#cbCaseServices') is not null
        drop table #cbCaseServices

    select 
        left('AU-' + sp.CASENO, 20) collate database_default CaseKey,
        sp.CaseNo,
        st.ID ServiceTypeID,
        st.Name ServiceType,
        sp.Amount ServiceAmount,
        sf.Fee ServiceFee
    into #cbCaseServices
    from
        carebase_tblCasesServicesProvided_aucm sp
        inner join carebase_tblServiceType_aucm st on
            st.ID = sp.ServiceTypeID
        inner join carebase_tblFinanceGroup_ServiceFees_aucm sf on
            sf.ServiceTypeID = st.ID

    begin transaction

    begin try

        delete from [db-au-cmdwh].dbo.cbCaseServices
        where
            CaseKey in
            (
                select
                    CaseKey
                from
                    #cbCaseServices
            )

        insert into [db-au-cmdwh].dbo.cbCaseServices with(tablock)
        (
            [CaseKey],
            [CaseNo],
            [ServiceTypeID],
            [ServiceType],
            [ServiceAmount],
            [ServiceFee]
        )
        select
            [CaseKey],
            [CaseNo],
            [ServiceTypeID],
            [ServiceType],
            [ServiceAmount],
            [ServiceFee]
        from
            #cbCaseServices

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler 'cbCaseServices data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
