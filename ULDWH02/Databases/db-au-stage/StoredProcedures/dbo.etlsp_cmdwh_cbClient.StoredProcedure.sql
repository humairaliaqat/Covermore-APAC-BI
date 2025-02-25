USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbClient]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cbClient]
as
begin
/*
20150720, LS, T16930, Carebase 4.6
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('[db-au-cmdwh].dbo.cbClient') is null
    begin

        create table [db-au-cmdwh].dbo.cbClient
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(3) not null,
            [ClientCode] nvarchar(2) not null,
            [ClientName] nvarchar(100) null,
            [Email] nvarchar(100) null,
            [EvacDebtorCode] nvarchar(50) null,
            [NonEvacDebtorCode] nvarchar(50) null,
            [CurrencyCode] nvarchar(3) null,
            [IsCovermoreClient] bit null
        )

        create clustered index idx_cbClient_BIRowID on [db-au-cmdwh].dbo.cbClient(BIRowID)
        create nonclustered index idx_cbClient_ClientCode on [db-au-cmdwh].dbo.cbClient(ClientCode,CountryKey)

    end

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.cbClient with(tablock) t
        using carebase_PCL_CLIENT_aucm s on
            s.CLI_CODE collate database_default = t.ClientCode

        when matched then
            update
            set
                CountryKey = isnull(s.DomainCode, 'AU'),
                ClientName = s.CLI_DESC,
                Email = s.Email,
                EvacDebtorCode = s.DebtorCodeEvac,
                NonEvacDebtorCode = s.DebtorCodeNonEvac,
                CurrencyCode = s.CurrencyCode,
                IsCovermoreClient = isnull(s.IsCovermoreClient, 0)

        when not matched by target then 
            insert
            (
                CountryKey,
                ClientCode,
                ClientName,
                Email,
                EvacDebtorCode,
                NonEvacDebtorCode,
                CurrencyCode,
                IsCovermoreClient
            )
            values
            (
                isnull(s.DomainCode, 'AU'),
                s.CLI_CODE,
                s.CLI_DESC,
                s.Email,
                s.DebtorCodeEvac,
                s.DebtorCodeNonEvac,
                s.CurrencyCode,
                isnull(s.IsCovermoreClient, 0)
            )
        ;

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler 'cbClient data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
