USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0002b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0002b]
    @Agencykey varchar(41)

as
begin

/****************************************************************************************************/
--  Name:           rptsp_rpt0002b
--  Author:         Leonardus Setyabudi
--  Date Created:   20120820
--  Description:    This stored procedure returns unallocated cheques for specified agency.
--                  This is meant to be used as subreport, called by rptsp_rpt002a only
--  Parameters:     @AgencyKey: Link to main report
--
--  Change History: 20120820 - LS - Migrated from OXLYE.RPTDB.dbo.rptsp_rpt0002b
--                  20130618 - LS - TFS 7664/8556, use Penguin data
--                  20131031 - LS - 19446, bug fix agency key varchar(10) -> 41
--                  20131101 - LS - 19496, exclude DC commision refunds
--                  20131107 - LS - 19496, exclude cancelled transaction
--                                  exclude migrated payments, AR is not going to do anything about it
--
/****************************************************************************************************/

    select
        o.AlphaCode AgencyCode,
        prt.ChequeNumber ChequeNo,
        prt.Amount,
        cu.Initial Op,
        pr.PaymentCreateDateTime BankDate,
        b.AccountCode Account
    from
        penPaymentRegister pr
        inner join penPaymentRegisterTransaction prt on
            prt.PaymentRegisterKey = pr.PaymentRegisterKey
        inner join penOutlet o on
            o.OutletKey = pr.OutletKey and
            o.OutletStatus = 'Current'
        inner join penCRMUser cu on
            cu.CRMUserKey = pr.CRMUserKey
        inner join penBankAccount b on
            b.BankAccountKey = pr.BankAccountKey
    where
        prt.PaymentAllocationKey is null and
        pr.OutletKey = @Agencykey and
        pr.PaymentSource <> 'MIGRATION' and
        prt.Payer <> 'OFFSET CC TRANSFER' and
        prt.Status not in ('COMREFUNDED', 'CANCELLED')

end

GO
