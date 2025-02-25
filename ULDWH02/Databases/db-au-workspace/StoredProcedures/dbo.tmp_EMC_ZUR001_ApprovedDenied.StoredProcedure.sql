USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_EMC_ZUR001_ApprovedDenied]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tmp_EMC_ZUR001_ApprovedDenied] @ClientID int
as

--declare @ClientID int
--select @ClientID = 10616320
--Test Client IDs:	10519087 Covered (A)
--					10587388 NotCovered (DDD)
--					10587336 Policy Denied (DD)
--					10587389 Covered (DDDA)
--					10574494 PolicyDenied (AADDDD)
--					10587420 Covered (Athlete's foot)



OPEN SYMMETRIC KEY EMCSymmetricKey DECRYPTION BY CERTIFICATE EMCCertificate;

select distinct
	e.ClientID,
	e.AssessedDt as AssessedDate,
	e.Destination,
	e.DeptDt as DepartureDate,
	e.RetDt as ReturnDate,
	m.[Counter],
	m.Condition,
	case when e.ApprovalStatus in ('NotCovered','PolicyDenied') then 'D'
		 else m.DeniedAccepted
	end as DeniedAccepted,
	n.Title as ClientTitle,
	n.Firstname as ClientFirstName,
	n.Surname as ClientSurname,
    convert(varchar(255),DecryptByKey(n.Street)) as ClientStreet,
    convert(varchar,DecryptByKey(n.Suburb)) as ClientSuburb,
    convert(varchar,DecryptByKey(n.State)) as ClientState,
    convert(varchar,DecryptByKey(n.PCode)) as ClientPostCode,	   	
	c.Product as BankName,
	p.PolType as CardType,
	c.Phone as CompanyPhone,
	e.ApprovalStatus,
	convert(money,isnull(pay.Premium,0)) as AmountPaid,
	isnull(pay.GST,0) as GST,
	pay.ReceiptNo as TransactionNo,
	e.AgeApproval
from 
	wills.emc.dbo.tblEMCApplications e
	join wills.emc.dbo.tblEMCNames n on e.ClientID = n.ClientID
	left join wills.emc.dbo.Medical m on e.ClientID = m.ClientID
	join wills.emc.dbo.Companies c on e.CompID = c.CompID
	left join wills.emc.dbo.tblPolicyTypes p on e.PolTypeID = p.PolTypeID
	left join wills.emc.dbo.Payment pay on e.ClientID = pay.ClientID
where
	e.ClientID = @ClientID and
	m.DeniedAccepted in ('A', 'D') and
	n.ContType = 'C'
order by
	m.[Counter]
	
CLOSE SYMMETRIC KEY EMCSymmetricKey
GO
