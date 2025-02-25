USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_rptsp_rpt0002b]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[tmp_rptsp_rpt0002b] @alpha varchar(7) = null, @msk int = null

 AS

/****************************************************************************************************/
--	Name:			rptsp_rpt0105b
--	Author:			Sharmila Inbaseelan
--	Date Created:	2010118
--	Description:	This stored procedure returns unallocated cheques that fall within the parameter values
--	Parameters:		@Alpha: Valid agency number
--					@Msk: value is 1 for Banking
--	Parameters:
--	Change History:	
/****************************************************************************************************/


--uncomment to debug
/*
declare @alpha varchar(7),@msk int
*/


if @alpha is null
begin
select 
br.AgencyCode,
bp.ChequeNo,
SUM(bp.Amount)as Amount
from [db-au-cmdwh].dbo.BankPayment bp
inner join [db-au-cmdwh].dbo.BankReturn br on bp.ReturnKey = br.ReturnKey
where
bp.CountryKey = 'NZ' 
and (bp.Allocated is null or bp.Allocated =0)
group by
br.AgencyCode,
bp.ChequeNo
end
else
if @msk = 1 -- Banking only --FROM CRM
begin



select 
 top 20 br.AgencyCode,
 bp.ChequeNo,
 SUM(bp.Amount)as Amount,
 bp.PendRec,
 br.BankDate,
 bp.PaymentID,
 br.Account
 
from [db-au-cmdwh].dbo.BankPayment bp
inner join [db-au-cmdwh].dbo.BankReturn br on bp.ReturnKey = br.ReturnKey

where 
bp.CountryKey = 'AU' 
and (bp.Allocated is null or bp.Allocated =0)
and br.AgencyCode = @alpha

group by 
br.AgencyCode,
bp.ChequeNo, 
bp.PendRec,
 br.BankDate,
 bp.PaymentID,
 br.Account
 
 order by br.BankDate desc
 
 end
 else
 begin
 
 select 
br.AgencyCode,
 bp.ChequeNo,
 SUM(bp.Amount)as  Amount,
 bp.PendRec,
 br.BankDate,
 bp.PaymentID,
 br.Account
 
from [db-au-cmdwh].dbo.BankPayment bp
inner join [db-au-cmdwh].dbo.BankReturn br on bp.ReturnKey = br.ReturnKey

where 
bp.CountryKey = 'AU' 
and (bp.Allocated is null or bp.Allocated =0)
and br.AgencyCode = @alpha
and bp.Payer <> 'OFFSET CC TRANSFER'

group by br.AgencyCode,bp.ChequeNo, bp.PendRec,
 br.BankDate,
 bp.PaymentID,
 br.Account
 end
GO
