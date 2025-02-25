USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880h]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- Policy Issued with GigyaID
CREATE PROCEDURE [dbo].[rptsp_rpt0880h]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880h
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Data-In Monitoring - MDM Policy Issued with GigyaID
--  Parameters:     N/A
/****************************************************************************************************/
select IssueDate
, PolicyNumber
, AlphaCode
, DistributorCode
, CountryCode
, GroupCode
, SubGroupCode
, PolicyTravellerID
, IsPrimary
, FirstName
, LastName
, DOB
, EmailAddress
, CancelledDate
, PolicyTransactionID
, GigyaId
, ClaimNo
, ClaimCNT
, LastDataQueueStatus
, UpdateDateTime
, DataQueueID
, RetryCount
, Comment
, CommentGroup
, IdentifierID
, PartyID
, PartyCONSOLIDATION_IND
, ClaimantNo
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select p.IssueDate, p.PolicyNumber, p.AlphaCode
, t.Code as DistributorCode, d.CountryCode, g.Code as GroupCode, sg.Code as SubGroupCode
, ptv.ID as PolicyTravellerID, ptv.IsPrimary, ptv.FirstName, ptv.LastName, ptv.DOB, ptv.EmailAddress, p.CancelledDate
, pt.ID as PolicyTransactionID, pt.GigyaId
, c.ClaimNo, c.ClaimCNT
, q.Status as LastDataQueueStatus, q.UpdateDateTime, q.DataQueueID, q.RetryCount, q.Comment
, left(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(q.Comment, ''0'', ''x''), ''1'', ''x''), ''2'', ''x''), ''3'', ''x''), ''4'', ''x''), ''5'', ''x''), ''6'', ''x''), ''7'', ''x''), ''8'', ''x''), ''9'', ''x''), 250) as CommentGroup
, idt.ROWID_OBJECT as IdentifierID, idt.PRTY_FK as PartyID, idt.CONSOLIDATION_IND as PartyCONSOLIDATION_IND
, idtc.IDNTIFR_VAL as ClaimantNo
from [AU_PenguinSharp_Active]..tblPolicy p with (nolock)
inner join [AU_PenguinSharp_Active]..tblDomain d with (nolock) on d.DomainID = p.DomainID 
inner join [AU_PenguinSharp_Active]..tblOutlet o with (nolock) on o.AlphaCode = p.AlphaCode and o.DomainId = p.DomainID
inner join [AU_PenguinSharp_Active]..tblSubGroup sg with (nolock) on sg.ID = o.SubGroupID
inner join [AU_PenguinSharp_Active]..tblGroup g with (nolock) on g.ID = sg.GroupID
inner join [AU_PenguinSharp_Active]..tblDistributor t with (nolock) on t.DistributorId = sg.DistributorId and t.Status = ''Active''
inner join [AU_PenguinSharp_Active]..tblPolicyTraveller ptv with (nolock) on ptv.PolicyID = p.PolicyID and ptv.IsPrimary = 1
inner join [AU_PenguinSharp_Active]..tblPolicyTransaction pt with (nolock) on pt.PolicyID = p.PolicyID
outer apply (select max(clm.KLCLAIM) as ClaimNo, count(1) as ClaimCNT 
	from [Claims]..[KLREG] clm with (nolock)
	where clm.KLDOMAINID = 7 -- AU only
	and clm.KLCREATED >= ''2016-04-19''
	and clm.KLPOLICY = p.PolicyNumber) c
outer apply (select top 1 dque.DataQueueID, dque.Status, dque.UpdateDateTime, dque.RetryCount, dque.Comment
	from [AU_PenguinJob]..tblDataQueue dque with (nolock)
	outer apply DataValue.nodes(''/*[local-name() = "anyType"]'') as T(x)
	where dque.jobid = 177
	and dque.DataQueueTypeID = 110
	and T.x.value(''*[local-name() = "BlModule"][1]'', ''varchar(100)'') = ''CoverMore.PenguinJobs.MyCoverMore.PolicyNewBl,CoverMore.PenguinJobs.MyCoverMore''
	and dque.dataid = p.PolicyNumber
	order by dque.DataQueueID desc) q 
outer apply (select midt.ROWID_OBJECT, midt.PRTY_FK, mp.CONSOLIDATION_IND
	from [MDM_Distributor]..C_PARTY_IDENTIFIER midt with (nolock)
	left join [MDM_Distributor]..C_PARTY mp with (nolock) on mp.ROWID_OBJECT = midt.PRTY_FK
	where midt.LAST_ROWID_SYSTEM = ''PENGUIN''
	and midt.IDNTIFR_SUB_TYP = ''Gigya Username''
	and midt.IDNTIFR_VAL COLLATE Latin1_General_CI_AS = pt.GigyaId) idt
outer apply (select midt.IDNTIFR_VAL
	from [MDM_Distributor]..C_PARTY_IDENTIFIER midt with (nolock)
	where midt.LAST_ROWID_SYSTEM = ''CLAIMS''
	and midt.IDNTIFR_SUB_TYP = ''Source Record ID''
	and midt.PRTY_FK = idt.ROWID_OBJECT) idtc
where p.DomainID = 7 -- AU domain only
and t.Code = ''CMAU'' -- CMAU only
and p.IssueDate >= ''2016-04-19'' -- Post to MDM go live date
and len(pt.GigyaId) > 10
order by p.IssueDate')
GO
