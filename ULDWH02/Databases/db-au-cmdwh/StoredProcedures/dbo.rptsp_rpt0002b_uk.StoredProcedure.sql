USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0002b_uk]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[rptsp_rpt0002b_uk]
    @Agencykey varchar(10)

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
--
/****************************************************************************************************/

    select
        br.AgencyCode,
        ChequeNo,
        Amount,
        Op,
        BankDate,
        Account
    from
        BankPayment bp
        inner join BankReturn br on
            bp.ReturnKey = br.ReturnKey
    where
        br.AgencyKey = @Agencykey and
        (
            bp.Allocated is null or
            bp.Allocated = 0
        ) and
        bp.Payer <> 'OFFSET CC TRANSFER'

end


GO
