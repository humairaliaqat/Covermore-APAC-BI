USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbAuditCaseServices]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cbAuditCaseServices]
as
begin
/*
20150720, LS, T16930, Carebase 4.6
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('[db-au-cmdwh].dbo.cbAuditCaseServices') is null
    begin

        create table [db-au-cmdwh].dbo.cbAuditCaseServices
        (
            [BIRowID] bigint not null identity(1,1),
            [AuditUser] nvarchar(255) null,
            [AuditDateTime] datetime null,
            [AuditDateTimeUTC] datetime null,
            [AuditAction] nvarchar(10) null,
            [CaseKey] nvarchar(20) not null,
            [CaseNo] nvarchar(15) not null,
            [ServiceTypeID] int not null,
            [ServiceType] nvarchar(250) not null,
            [ServiceAmount] int null,
            [ServiceFee] money null
        )

        create clustered index idx_cbAuditCaseServices_BIRowID on [db-au-cmdwh].dbo.cbAuditCaseServices(BIRowID)
        create nonclustered index idx_cbAuditCaseServices_CaseKey on [db-au-cmdwh].dbo.cbAuditCaseServices(CaseKey)
        create nonclustered index idx_cbAuditCaseServices_CaseNo on [db-au-cmdwh].dbo.cbAuditCaseServices(CaseNo)

    end

    if object_id('tempdb..#cbAuditCaseServices') is not null
        drop table #cbAuditCaseServices

    select
        Audit_UserName collate database_default AuditUser,
        dbo.xfn_ConvertUTCtoLocal(AUDIT_DATETIME, 'AUS Eastern Standard Time') AuditDateTime,
        AUDIT_DATETIME AuditDateTimeUTC,
        Audit_Action collate database_default  AuditAction,
        left('AU-' + sp.CASENO, 20) collate database_default CaseKey,
        sp.CaseNo,
        st.ID ServiceTypeID,
        st.Name ServiceType,
        sp.Amount ServiceAmount,
        sf.Fee ServiceFee
    into #cbAuditCaseServices
    from
        carebase_Audit_tblCasesServicesProvided_aucm sp
        left join carebase_tblServiceType_aucm st on
            st.ID = sp.ServiceTypeID
        left join carebase_tblFinanceGroup_ServiceFees_aucm sf on
            sf.ServiceTypeID = st.ID

    begin transaction

    begin try

        delete t
        from 
            [db-au-cmdwh].dbo.cbAuditCaseServices t
            inner join #cbAuditCaseServices r on
                r.CaseKey = t.CaseKey and
                r.AuditDateTimeUTC = t.AuditDateTimeUTC and
                r.AuditUser = t.AuditUser

        insert into [db-au-cmdwh].dbo.cbAuditCaseServices with(tablock)
        (
            AuditUser,
            AuditDateTime,
            AuditDateTimeUTC,
            AuditAction,
            [CaseKey],
            [CaseNo],
            [ServiceTypeID],
            [ServiceType],
            [ServiceAmount],
            [ServiceFee]
        )
        select
            AuditUser,
            AuditDateTime,
            AuditDateTimeUTC,
            AuditAction,
            [CaseKey],
            [CaseNo],
            [ServiceTypeID],
            [ServiceType],
            [ServiceAmount],
            [ServiceFee]
        from
            #cbAuditCaseServices

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler 'cbAuditCaseServices data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
